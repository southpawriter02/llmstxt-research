#!/usr/bin/env python3
"""
build-archive.py — Content archival script for the Context Collapse benchmark
================================================================================
Traces To:  methodology.md §2.1 (Content Archiving), runner-design-spec.md §4.1
Purpose:    Fetches all content needed by the benchmark runner and stores it in
            an immutable archive with a comprehensive manifest.

This script runs ONCE before any model inference begins. It:
  1. Reads site-list.csv and questions.json to determine all URLs to fetch.
  2. For each site, fetches and parses the llms.txt file.
  3. For each source_url in questions.json, fetches:
     - The HTML version of the page (for Condition A / SmartReader extraction)
     - The Markdown version from llms.txt links (for Condition B / XML wrapping)
  4. Stores all content in benchmark/archive/ with a manifest.json recording
     every fetch attempt, successful or not.

URL-to-content mapping logic:
  - If source_url ends in .md → it IS the Markdown (Condition B). For HTML
    (Condition A), strip .md and fetch the rendered page.
  - If source_url ends in /llms.txt → fetch directly as both conditions
    (the llms.txt file itself is Markdown content).
  - If source_url is an HTML page → fetch directly for Condition A. For
    Condition B, look up the corresponding .md URL in the site's llms.txt.

Requirements:
  pip install requests

Usage:
  cd benchmark/scripts
  python3 build-archive.py [options]

  Options:
    --config PATH     Path to benchmark-config.json (default: ./benchmark-config.json)
    --resume          Skip URLs that already have SUCCESS entries in the manifest
    --site SITE_ID    Only archive a specific site (e.g., --site S001)
    --dry-run         Show what would be fetched without actually fetching
    --verbose         Enable debug logging
================================================================================
"""

import argparse
import csv
import hashlib
import json
import logging
import os
import re
import sys
import time
from dataclasses import dataclass, field, asdict
from datetime import datetime, timezone
from pathlib import Path
from typing import Optional
from urllib.parse import urlparse, urljoin

import requests
from urllib.robotparser import RobotFileParser

# ---------------------------------------------------------------------------
# Configuration
# ---------------------------------------------------------------------------

logger = logging.getLogger("build-archive")

# Default settings (overridden by benchmark-config.json archive_protocol)
DEFAULT_TIMEOUT = 30
DEFAULT_USER_AGENT = "LlmsTxtBenchmark/1.0 (academic research)"
DEFAULT_RATE_LIMIT_MS = 1000


# ---------------------------------------------------------------------------
# Data models
# ---------------------------------------------------------------------------

@dataclass
class ManifestEntry:
    """A single entry in manifest.json, per methodology §2.1."""
    site_id: str
    url: str
    url_hash: str
    condition: str  # "A" (HTML) or "B" (Markdown)
    fetch_timestamp: str = ""
    http_status: int = 0
    content_type: str = ""
    content_length_bytes: int = 0
    last_modified: Optional[str] = None
    etag: Optional[str] = None
    fetch_status: str = "PENDING"  # SUCCESS, HTTP_ERROR, TIMEOUT, DNS_FAILURE, WAF_BLOCKED
    failure_reason: Optional[str] = None
    # Extra fields for the runner's ArchiveEntry model
    html_path: Optional[str] = None
    markdown_path: Optional[str] = None
    llmstxt_section: Optional[str] = None


@dataclass
class SiteInfo:
    """Parsed site metadata from site-list.csv."""
    site_id: str
    domain: str
    llms_txt_url: str
    html_docs_url: str


@dataclass
class QuestionInfo:
    """A question and its source URLs."""
    question_id: str
    site_id: str
    source_urls: list


@dataclass
class LlmsTxtDoc:
    """Minimal parsed llms.txt structure for URL mapping."""
    title: str = ""
    summary: str = ""
    sections: list = field(default_factory=list)  # List of (name, entries)

    def find_section_for_url(self, url: str) -> Optional[str]:
        """Returns the section name containing the given URL, or None."""
        normalized = url.rstrip("/").lower()
        for section_name, entries in self.sections:
            for entry_url, entry_title in entries:
                if entry_url.rstrip("/").lower() == normalized:
                    return section_name
        return None

    def find_url_by_path(self, path_fragment: str) -> Optional[str]:
        """Finds a .md URL in llms.txt whose path contains the given fragment."""
        normalized = path_fragment.rstrip("/").lower()
        for _, entries in self.sections:
            for entry_url, _ in entries:
                if normalized in entry_url.lower():
                    return entry_url
        return None

    def all_urls(self) -> list:
        """Returns all entry URLs across all sections."""
        urls = []
        for _, entries in self.sections:
            for url, _ in entries:
                urls.append(url)
        return urls


# ---------------------------------------------------------------------------
# llms.txt parser (minimal, aligned with LlmsTxtKit.Core.Parsing)
# ---------------------------------------------------------------------------

def parse_llms_txt(content: str) -> LlmsTxtDoc:
    """
    Parses an llms.txt file into a minimal document structure.
    Behavioral parity with LlmsTxtKit.Core.Parsing.LlmsDocumentParser:
      - H1 = title, blockquote = summary
      - H2 = section delimiter
      - Dash-prefixed links = entries within sections
      - "Optional" section (case-sensitive) is flagged
    """
    doc = LlmsTxtDoc()
    lines = content.split("\n")

    h1_re = re.compile(r"^#\s+(.+)$")
    h2_re = re.compile(r"^##\s+(.+)$")
    bq_re = re.compile(r"^>\s*(.+)$")
    entry_re = re.compile(r"^-\s*\[([^\]]+)\]\(([^)]+)\)(?::\s*(.*))?$")

    found_title = False
    found_summary = False
    current_section = None
    current_entries = []

    for line in lines:
        line = line.rstrip("\r")

        # H1 title
        m = h1_re.match(line)
        if m and not found_title:
            doc.title = m.group(1).strip()
            found_title = True
            continue

        # Blockquote summary
        if not found_summary and current_section is None:
            m = bq_re.match(line)
            if m and found_title:
                doc.summary = m.group(1).strip()
                found_summary = True
                continue

        # H2 section delimiter
        m = h2_re.match(line)
        if m:
            # Finalize previous section
            if current_section is not None:
                doc.sections.append((current_section, current_entries))
                current_entries = []
            current_section = m.group(1).strip()
            continue

        # Entry links within sections
        if current_section is not None:
            m = entry_re.match(line)
            if m:
                entry_url = m.group(2).strip()
                entry_title = m.group(1).strip()
                current_entries.append((entry_url, entry_title))

    # Finalize last section
    if current_section is not None:
        doc.sections.append((current_section, current_entries))

    return doc


# ---------------------------------------------------------------------------
# URL utilities
# ---------------------------------------------------------------------------

def url_hash(url: str) -> str:
    """
    SHA-256 hash of a URL, truncated to 16 hex chars (64 bits), used as
    the filename. Per methodology §2.1.

    Truncation rationale: With ~700 total URLs in the corpus, the birthday
    paradox probability of a collision at 64 bits is ~2.7e-15. Safe enough
    for filesystem naming while keeping paths readable.
    """
    return hashlib.sha256(url.encode("utf-8")).hexdigest()[:16]


def derive_html_url(md_url: str) -> str:
    """
    Given a .md URL, derive the likely HTML page URL.
    Strategy: strip the .md extension. Most doc sites serve the HTML
    at the same path without the extension.
    Examples:
      https://docs.stripe.com/connect/charges.md → https://docs.stripe.com/connect/charges
      https://docs.pinecone.io/gRPC/streaming.md → https://docs.pinecone.io/gRPC/streaming
    """
    if md_url.endswith(".md"):
        return md_url[:-3]
    return md_url


def derive_markdown_url(html_url: str, llms_doc: Optional[LlmsTxtDoc],
                        site_info: SiteInfo) -> Optional[str]:
    """
    Given an HTML URL, find the corresponding Markdown URL from llms.txt.

    Strategy:
    1. Check if the HTML URL is directly listed in llms.txt (some sites
       list HTML URLs, not .md URLs).
    2. Try appending .md to the URL path.
    3. Try matching the URL path against llms.txt entries by path fragment.
    4. Return None if no mapping found.
    """
    if llms_doc is None:
        return None

    # Strategy 1: Direct match in llms.txt
    all_urls = llms_doc.all_urls()
    normalized_html = html_url.rstrip("/").lower()

    for entry_url in all_urls:
        if entry_url.rstrip("/").lower() == normalized_html:
            return entry_url

    # Strategy 2: Try appending .md
    md_candidate = html_url.rstrip("/") + ".md"
    for entry_url in all_urls:
        if entry_url.rstrip("/").lower() == md_candidate.rstrip("/").lower():
            return entry_url

    # Strategy 3: Path fragment matching
    parsed = urlparse(html_url)
    path = parsed.path.rstrip("/")
    if path:
        # Try matching the last path segments
        segments = path.split("/")
        for depth in range(1, min(4, len(segments) + 1)):
            fragment = "/".join(segments[-depth:])
            match = llms_doc.find_url_by_path(fragment)
            if match:
                return match

    # Strategy 4: Try with index.md for directory-style URLs
    index_candidate = html_url.rstrip("/") + "/index.md"
    for entry_url in all_urls:
        if entry_url.rstrip("/").lower() == index_candidate.rstrip("/").lower():
            return entry_url

    logger.debug("No Markdown mapping found for HTML URL: %s", html_url)
    return None


# ---------------------------------------------------------------------------
# HTTP fetching with retries and rate limiting
# ---------------------------------------------------------------------------

class Fetcher:
    """HTTP fetcher with rate limiting, timeout, robots.txt, and error handling."""

    def __init__(self, user_agent: str, timeout: int, rate_limit_ms: int,
                 respect_robots: bool = True):
        self.session = requests.Session()
        self.session.headers.update({
            "User-Agent": user_agent,
            "Accept": "text/html,text/markdown,text/plain,*/*",
            "Accept-Language": "en-US,en;q=0.9",
        })
        self.user_agent = user_agent
        self.timeout = timeout
        self.rate_limit_seconds = rate_limit_ms / 1000.0
        self.respect_robots = respect_robots
        self._last_fetch_time = 0.0
        # Cache of RobotFileParser instances per domain
        self._robots_cache: dict[str, Optional[RobotFileParser]] = {}

    def _check_robots(self, url: str) -> bool:
        """
        Checks robots.txt for the given URL. Returns True if allowed, False
        if disallowed. Per config: respect_robots_txt = true.

        Caches the robots.txt per domain to avoid repeated fetches.
        If robots.txt is unreachable, we assume allowed (standard behavior).
        """
        if not self.respect_robots:
            return True

        parsed = urlparse(url)
        domain = f"{parsed.scheme}://{parsed.netloc}"

        if domain not in self._robots_cache:
            robots_url = f"{domain}/robots.txt"
            rp = RobotFileParser()
            rp.set_url(robots_url)
            try:
                rp.read()
                self._robots_cache[domain] = rp
                logger.debug("Loaded robots.txt for %s", domain)
            except Exception as e:
                logger.debug("Could not fetch robots.txt for %s: %s", domain, e)
                self._robots_cache[domain] = None  # Assume allowed

        rp = self._robots_cache.get(domain)
        if rp is None:
            return True
        return rp.can_fetch(self.user_agent, url)

    def fetch(self, url: str) -> tuple:
        """
        Fetches a URL and returns (content_bytes, response_headers, error_info).
        Returns (None, None, error_dict) on failure.

        Checks robots.txt before fetching (per config respect_robots_txt).
        Detects JS-only pages via heuristic content inspection (§2.1 JS_ONLY status).
        """
        # robots.txt check (per benchmark-config.json archive_protocol)
        if not self._check_robots(url):
            logger.info("  Blocked by robots.txt: %s", url)
            return (None, None, {
                "fetch_status": "WAF_BLOCKED",
                "failure_reason": "Disallowed by robots.txt",
                "http_status": 0,
            })

        # Rate limiting
        elapsed = time.time() - self._last_fetch_time
        if elapsed < self.rate_limit_seconds:
            time.sleep(self.rate_limit_seconds - elapsed)

        self._last_fetch_time = time.time()

        try:
            response = self.session.get(url, timeout=self.timeout, allow_redirects=True)

            if response.status_code == 200:
                headers_dict = {
                    "status_code": response.status_code,
                    "content_type": response.headers.get("Content-Type", ""),
                    "content_length": len(response.content),
                    "last_modified": response.headers.get("Last-Modified"),
                    "etag": response.headers.get("ETag"),
                }

                # JS_ONLY detection heuristic (methodology §2.1):
                # If the response is HTML but has very little visible text
                # content relative to its size, it's likely a JS-rendered SPA
                # that requires a browser to render actual content.
                content_type = headers_dict["content_type"].lower()
                if "text/html" in content_type:
                    text = response.content.decode("utf-8", errors="replace")
                    # Strip HTML tags for a rough text-content estimate
                    stripped = re.sub(r"<[^>]+>", " ", text)
                    stripped = re.sub(r"\s+", " ", stripped).strip()
                    # Heuristic: if the HTML is >5KB but stripped text is <200
                    # chars, it's probably a JS-only shell
                    if len(response.content) > 5000 and len(stripped) < 200:
                        logger.warning("  JS_ONLY detected (HTML=%d bytes, "
                                        "text=%d chars): %s",
                                        len(response.content), len(stripped), url)
                        return (None, headers_dict, {
                            "fetch_status": "JS_ONLY",
                            "failure_reason": (
                                f"Page appears to require JavaScript rendering "
                                f"(HTML={len(response.content)} bytes, "
                                f"extracted text={len(stripped)} chars)"
                            ),
                            "http_status": response.status_code,
                        })

                return (response.content, headers_dict, None)
            else:
                return (
                    None,
                    {"status_code": response.status_code},
                    {
                        "fetch_status": "HTTP_ERROR",
                        "failure_reason": f"HTTP {response.status_code}",
                        "http_status": response.status_code,
                    }
                )

        except requests.exceptions.Timeout:
            return (None, None, {
                "fetch_status": "TIMEOUT",
                "failure_reason": f"Request timed out after {self.timeout}s",
                "http_status": 0,
            })
        except requests.exceptions.ConnectionError as e:
            error_msg = str(e)
            if "NameResolutionError" in error_msg or "DNS" in error_msg.upper():
                return (None, None, {
                    "fetch_status": "DNS_FAILURE",
                    "failure_reason": f"DNS resolution failed: {error_msg[:200]}",
                    "http_status": 0,
                })
            return (None, None, {
                "fetch_status": "HTTP_ERROR",
                "failure_reason": f"Connection error: {error_msg[:200]}",
                "http_status": 0,
            })
        except Exception as e:
            return (None, None, {
                "fetch_status": "HTTP_ERROR",
                "failure_reason": f"Unexpected error: {str(e)[:200]}",
                "http_status": 0,
            })

    def close(self):
        self.session.close()


# ---------------------------------------------------------------------------
# Archive builder
# ---------------------------------------------------------------------------

class ArchiveBuilder:
    """
    Orchestrates the full archival process per methodology §2.1.
    """

    def __init__(self, config_path: str, resume: bool = False,
                 site_filter: Optional[str] = None, dry_run: bool = False):
        self.config_path = Path(config_path).resolve()
        self.config_dir = self.config_path.parent
        self.resume = resume
        self.site_filter = site_filter
        self.dry_run = dry_run

        # Load config
        with open(self.config_path) as f:
            self.config = json.load(f)

        archive_proto = self.config.get("archive_protocol", {})
        self.timeout = archive_proto.get("fetch_timeout_seconds", DEFAULT_TIMEOUT)
        self.user_agent = archive_proto.get("user_agent", DEFAULT_USER_AGENT)
        self.rate_limit_ms = archive_proto.get("rate_limit_ms", DEFAULT_RATE_LIMIT_MS)

        # Resolve paths relative to config directory
        paths = self.config["paths"]
        self.questions_path = self.config_dir / paths["questions"]
        self.site_list_path = self.config_dir / paths["site_list"]
        self.archive_dir = self.config_dir / paths["archive_dir"]
        self.manifest_path = self.config_dir / paths["archive_manifest"]

        # Archive subdirectories
        self.html_dir = self.archive_dir / "html"
        self.markdown_dir = self.archive_dir / "markdown"

        # State
        self.manifest_entries: list[ManifestEntry] = []
        self.sites: dict[str, SiteInfo] = {}
        self.questions: dict[str, list[QuestionInfo]] = {}  # site_id → questions
        self.llms_docs: dict[str, LlmsTxtDoc] = {}  # site_id → parsed llms.txt
        self.fetcher: Optional[Fetcher] = None

        # Resume state
        self.existing_manifest: dict[str, ManifestEntry] = {}  # key: url+condition

    def run(self):
        """Main entry point."""
        logger.info("=" * 70)
        logger.info("  Context Collapse Benchmark — Content Archive Builder")
        logger.info("=" * 70)
        logger.info("")

        self._load_corpus_data()
        self._setup_directories()

        if self.resume:
            self._load_existing_manifest()

        if self.dry_run:
            self._print_dry_run_summary()
            return

        respect_robots = self.config.get("archive_protocol", {}).get(
            "respect_robots_txt", True)
        self.fetcher = Fetcher(
            self.user_agent, self.timeout, self.rate_limit_ms,
            respect_robots=respect_robots)

        try:
            self._fetch_all_llms_txt()
            self._fetch_all_content()
            self._validate_coverage()
            self._write_manifest()
            self._print_summary()
        finally:
            if self.fetcher:
                self.fetcher.close()

    # ------------------------------------------------------------------
    # Data loading
    # ------------------------------------------------------------------

    def _load_corpus_data(self):
        """Loads site-list.csv and questions.json."""
        # Load sites
        with open(self.site_list_path, newline="", encoding="utf-8") as f:
            reader = csv.DictReader(f)
            for row in reader:
                site = SiteInfo(
                    site_id=row["site_id"],
                    domain=row["domain"],
                    llms_txt_url=row["llms_txt_url"],
                    html_docs_url=row["html_docs_url"],
                )
                if self.site_filter and site.site_id != self.site_filter:
                    continue
                self.sites[site.site_id] = site

        logger.info("Loaded %d sites from site-list.csv", len(self.sites))

        # Load questions
        with open(self.questions_path, encoding="utf-8") as f:
            raw = json.load(f)

        for site_block in raw:
            site_id = site_block["site_id"]
            if site_id not in self.sites:
                continue
            site_questions = []
            for q in site_block["questions"]:
                site_questions.append(QuestionInfo(
                    question_id=q["question_id"],
                    site_id=site_id,
                    source_urls=q["source_urls"],
                ))
            self.questions[site_id] = site_questions

        total_q = sum(len(qs) for qs in self.questions.values())
        logger.info("Loaded %d questions across %d sites",
                     total_q, len(self.questions))

    def _setup_directories(self):
        """Creates archive directory structure."""
        self.archive_dir.mkdir(parents=True, exist_ok=True)
        self.html_dir.mkdir(parents=True, exist_ok=True)
        self.markdown_dir.mkdir(parents=True, exist_ok=True)

        for site_id in self.sites:
            (self.html_dir / site_id).mkdir(exist_ok=True)
            (self.markdown_dir / site_id).mkdir(exist_ok=True)

        logger.info("Archive directory: %s", self.archive_dir)

    def _load_existing_manifest(self):
        """Loads existing manifest for resume support."""
        if not self.manifest_path.exists():
            logger.info("No existing manifest found. Starting fresh.")
            return

        try:
            with open(self.manifest_path, encoding="utf-8") as f:
                data = json.load(f)

            for entry_data in data.get("entries", []):
                entry = ManifestEntry(**{k: v for k, v in entry_data.items()
                                         if k in ManifestEntry.__dataclass_fields__})
                key = f"{entry.url}|{entry.condition}"
                if entry.fetch_status == "SUCCESS":
                    self.existing_manifest[key] = entry

            logger.info("Loaded %d SUCCESS entries from existing manifest (resume mode).",
                         len(self.existing_manifest))
        except Exception as e:
            logger.warning("Failed to load existing manifest: %s. Starting fresh.", e)

    # ------------------------------------------------------------------
    # Phase 1: Fetch and parse all llms.txt files
    # ------------------------------------------------------------------

    def _fetch_all_llms_txt(self):
        """Fetches and parses the llms.txt file for every site."""
        logger.info("")
        logger.info("--- Phase 1: Fetching llms.txt files ---")

        for site_id, site in sorted(self.sites.items()):
            llms_url = site.llms_txt_url
            logger.info("[%s] Fetching llms.txt: %s", site_id, llms_url)

            content, headers, error = self.fetcher.fetch(llms_url)

            if error:
                logger.warning("[%s] Failed to fetch llms.txt: %s",
                                site_id, error.get("failure_reason", "unknown"))
                # Record the failure but continue — Condition B will fall back
                self._record_fetch(site_id, llms_url, "B", None, headers, error)
                continue

            # Save the raw llms.txt
            h = url_hash(llms_url)
            md_path = self.markdown_dir / site_id / f"{h}.md"
            md_path.write_bytes(content)

            # Parse the llms.txt
            text = content.decode("utf-8", errors="replace")
            llms_doc = parse_llms_txt(text)
            self.llms_docs[site_id] = llms_doc

            logger.info("[%s] Parsed llms.txt: title='%s', %d sections, %d total entries",
                         site_id, llms_doc.title, len(llms_doc.sections),
                         sum(len(entries) for _, entries in llms_doc.sections))

            # Record success in manifest
            self._record_fetch(site_id, llms_url, "B", content, headers, None,
                               md_rel_path=f"{site_id}/{h}.md")

        logger.info("llms.txt fetch complete: %d/%d successful",
                     len(self.llms_docs), len(self.sites))

    # ------------------------------------------------------------------
    # Phase 2: Fetch all content for each source_url
    # ------------------------------------------------------------------

    def _fetch_all_content(self):
        """Fetches HTML and Markdown for every source_url in questions.json."""
        logger.info("")
        logger.info("--- Phase 2: Fetching content for all source URLs ---")

        # Collect all unique (site_id, url) pairs
        fetch_plan: list[tuple[str, str]] = []
        seen = set()

        for site_id, questions in sorted(self.questions.items()):
            for q in questions:
                for url in q.source_urls:
                    key = (site_id, url)
                    if key not in seen:
                        seen.add(key)
                        fetch_plan.append(key)

        logger.info("Total unique (site, URL) pairs to fetch: %d", len(fetch_plan))

        for idx, (site_id, source_url) in enumerate(fetch_plan, 1):
            site = self.sites[site_id]
            llms_doc = self.llms_docs.get(site_id)

            progress = f"[{idx}/{len(fetch_plan)}]"

            # Determine the URLs to fetch for each condition
            html_url, md_url = self._determine_fetch_urls(
                source_url, llms_doc, site)

            # --- Condition A: HTML fetch ---
            if html_url:
                resume_key = f"{html_url}|A"
                if self.resume and resume_key in self.existing_manifest:
                    entry = self.existing_manifest[resume_key]
                    self.manifest_entries.append(entry)
                    logger.debug("%s Skipping Condition A (resume): %s",
                                  progress, html_url)
                else:
                    logger.info("%s [%s] Condition A: %s",
                                 progress, site_id, html_url)
                    self._fetch_and_store(
                        site_id, html_url, "A", source_url, llms_doc)
            else:
                logger.warning("%s [%s] No HTML URL derivable for: %s",
                                progress, site_id, source_url)
                self._record_fetch(site_id, source_url, "A", None, None, {
                    "fetch_status": "HTTP_ERROR",
                    "failure_reason": "Cannot derive HTML URL from source URL",
                    "http_status": 0,
                })

            # --- Condition B: Markdown fetch ---
            if md_url:
                resume_key = f"{md_url}|B"
                if self.resume and resume_key in self.existing_manifest:
                    entry = self.existing_manifest[resume_key]
                    self.manifest_entries.append(entry)
                    logger.debug("%s Skipping Condition B (resume): %s",
                                  progress, md_url)
                else:
                    logger.info("%s [%s] Condition B: %s",
                                 progress, site_id, md_url)
                    self._fetch_and_store(
                        site_id, md_url, "B", source_url, llms_doc)
            else:
                logger.warning("%s [%s] No Markdown URL found for: %s",
                                progress, site_id, source_url)
                self._record_fetch(site_id, source_url, "B", None, None, {
                    "fetch_status": "HTTP_ERROR",
                    "failure_reason": "No corresponding Markdown URL found in llms.txt",
                    "http_status": 0,
                })

            # Write incremental manifest every 50 URLs (crash safety)
            if idx % 50 == 0:
                self._write_manifest()
                logger.info("  (incremental manifest save at %d/%d)",
                             idx, len(fetch_plan))

    def _determine_fetch_urls(self, source_url: str,
                               llms_doc: Optional[LlmsTxtDoc],
                               site: SiteInfo) -> tuple:
        """
        Returns (html_url, markdown_url) for a given source_url.

        Logic:
          - .md URL → html_url = strip .md; md_url = the URL itself
          - /llms.txt URL → html_url = None (or the URL); md_url = the URL
          - HTML URL → html_url = the URL; md_url = lookup in llms.txt
        """
        if source_url.endswith("/llms.txt"):
            # The llms.txt file is both conditions (but HTML version is
            # less meaningful — just fetch it for completeness)
            return (source_url, source_url)

        if source_url.endswith(".md"):
            html_url = derive_html_url(source_url)
            return (html_url, source_url)

        # Regular HTML URL
        md_url = derive_markdown_url(source_url, llms_doc, site)
        return (source_url, md_url)

    def _fetch_and_store(self, site_id: str, url: str, condition: str,
                          original_source_url: str,
                          llms_doc: Optional[LlmsTxtDoc]):
        """Fetches a URL and stores the content in the archive."""
        content, headers, error = self.fetcher.fetch(url)

        if error:
            logger.warning("  FAILED: %s — %s",
                            url, error.get("failure_reason", "unknown"))
            self._record_fetch(site_id, url, condition, None, headers, error)
            return

        # Determine storage path
        h = url_hash(url)
        if condition == "A":
            file_path = self.html_dir / site_id / f"{h}.html"
            rel_path = f"{site_id}/{h}.html"
        else:
            file_path = self.markdown_dir / site_id / f"{h}.md"
            rel_path = f"{site_id}/{h}.md"

        # Write content to disk
        file_path.write_bytes(content)

        # Determine llms.txt section for this URL (Condition B only)
        section_name = None
        if condition == "B" and llms_doc:
            section_name = llms_doc.find_section_for_url(url)

        # Record in manifest
        self._record_fetch(
            site_id, url, condition, content, headers, None,
            html_rel_path=rel_path if condition == "A" else None,
            md_rel_path=rel_path if condition == "B" else None,
            section_name=section_name,
        )

    # ------------------------------------------------------------------
    # Manifest management
    # ------------------------------------------------------------------

    def _record_fetch(self, site_id: str, url: str, condition: str,
                       content: Optional[bytes], headers: Optional[dict],
                       error: Optional[dict], *,
                       html_rel_path: Optional[str] = None,
                       md_rel_path: Optional[str] = None,
                       section_name: Optional[str] = None):
        """Records a fetch result in the manifest entries list."""
        entry = ManifestEntry(
            site_id=site_id,
            url=url,
            url_hash=url_hash(url),
            condition=condition,
            fetch_timestamp=datetime.now(timezone.utc).isoformat(),
        )

        if error:
            entry.fetch_status = error.get("fetch_status", "HTTP_ERROR")
            entry.failure_reason = error.get("failure_reason")
            entry.http_status = error.get("http_status", 0)
        elif content is not None and headers:
            entry.fetch_status = "SUCCESS"
            entry.http_status = headers.get("status_code", 200)
            entry.content_type = headers.get("content_type", "")
            entry.content_length_bytes = headers.get("content_length", len(content))
            entry.last_modified = headers.get("last_modified")
            entry.etag = headers.get("etag")

        entry.html_path = html_rel_path
        entry.markdown_path = md_rel_path
        entry.llmstxt_section = section_name

        self.manifest_entries.append(entry)

    def _write_manifest(self):
        """Writes the manifest to disk."""
        manifest_data = {
            "fetched_at": datetime.now(timezone.utc).isoformat(),
            "archive_protocol": {
                "user_agent": self.user_agent,
                "timeout_seconds": self.timeout,
                "rate_limit_ms": self.rate_limit_ms,
            },
            "entries": [asdict(e) for e in self.manifest_entries],
        }

        # Atomic write via temp file
        tmp_path = self.manifest_path.with_suffix(".json.tmp")
        with open(tmp_path, "w", encoding="utf-8") as f:
            json.dump(manifest_data, f, indent=2, ensure_ascii=False)
        tmp_path.rename(self.manifest_path)

        logger.debug("Manifest written: %d entries", len(self.manifest_entries))

    # ------------------------------------------------------------------
    # Post-archival validation (methodology §2.1, step 4)
    # ------------------------------------------------------------------

    def _validate_coverage(self):
        """
        Validates that every source_url in questions.json has a corresponding
        archive entry for both conditions (A and B). Per methodology §2.1:
        'After the archival phase completes, validate that every source_url
        has a corresponding archive entry for both conditions. Missing entries
        are flagged for manual review.'
        """
        logger.info("")
        logger.info("--- Post-archival coverage validation ---")

        # Build a lookup: (site_id, source_url) → set of conditions with SUCCESS
        coverage: dict[tuple[str, str], dict[str, str]] = {}
        for entry in self.manifest_entries:
            key = (entry.site_id, entry.url)
            if key not in coverage:
                coverage[key] = {}
            coverage[key][entry.condition] = entry.fetch_status

        # Check every source_url in every question
        missing_a = []
        missing_b = []
        failed_a = []
        failed_b = []

        for site_id, questions in self.questions.items():
            for q in questions:
                for source_url in q.source_urls:
                    # Find what we fetched for this URL (may be under a
                    # derived URL, e.g., .md stripped for HTML condition)
                    found_a = False
                    found_b = False

                    for (s_id, url), conditions in coverage.items():
                        if s_id != site_id:
                            continue
                        # Check if this manifest entry relates to our source_url
                        # Match if same URL, or if it's a derived URL
                        if (url == source_url or
                            url == derive_html_url(source_url) or
                            source_url.endswith(".md") and url == source_url[:-3]):
                            if "A" in conditions:
                                found_a = True
                                if conditions["A"] != "SUCCESS":
                                    failed_a.append((site_id, source_url, conditions["A"]))
                            if "B" in conditions:
                                found_b = True
                                if conditions["B"] != "SUCCESS":
                                    failed_b.append((site_id, source_url, conditions["B"]))

                    if not found_a:
                        missing_a.append((site_id, source_url))
                    if not found_b:
                        missing_b.append((site_id, source_url))

        # Report findings
        total_urls = sum(
            len(url) for q_list in self.questions.values()
            for q in q_list for url in [q.source_urls])

        if not missing_a and not missing_b and not failed_a and not failed_b:
            logger.info("Coverage validation PASSED: all source_urls have both "
                         "conditions archived successfully.")
        else:
            if missing_a:
                logger.warning("MISSING Condition A entries for %d source URLs:",
                                len(missing_a))
                for sid, url in missing_a[:10]:
                    logger.warning("  [%s] %s", sid, url)
                if len(missing_a) > 10:
                    logger.warning("  ... and %d more", len(missing_a) - 10)

            if missing_b:
                logger.warning("MISSING Condition B entries for %d source URLs:",
                                len(missing_b))
                for sid, url in missing_b[:10]:
                    logger.warning("  [%s] %s", sid, url)
                if len(missing_b) > 10:
                    logger.warning("  ... and %d more", len(missing_b) - 10)

            if failed_a:
                logger.warning("FAILED Condition A fetches for %d source URLs:",
                                len(failed_a))
                for sid, url, status in failed_a[:10]:
                    logger.warning("  [%s] %s — %s", sid, url, status)

            if failed_b:
                logger.warning("FAILED Condition B fetches for %d source URLs:",
                                len(failed_b))
                for sid, url, status in failed_b[:10]:
                    logger.warning("  [%s] %s — %s", sid, url, status)

            logger.warning("Manual review recommended for flagged entries above.")

    # ------------------------------------------------------------------
    # Summary and dry-run
    # ------------------------------------------------------------------

    def _print_summary(self):
        """Prints a summary of the archival results."""
        total = len(self.manifest_entries)
        success = sum(1 for e in self.manifest_entries if e.fetch_status == "SUCCESS")
        failed = total - success

        cond_a_success = sum(1 for e in self.manifest_entries
                             if e.condition == "A" and e.fetch_status == "SUCCESS")
        cond_b_success = sum(1 for e in self.manifest_entries
                             if e.condition == "B" and e.fetch_status == "SUCCESS")

        logger.info("")
        logger.info("=" * 70)
        logger.info("  Archive Complete")
        logger.info("=" * 70)
        logger.info("  Total fetches:      %d", total)
        logger.info("  Successful:         %d (%.1f%%)",
                     success, 100.0 * success / total if total else 0)
        logger.info("  Failed:             %d", failed)
        logger.info("  Condition A (HTML): %d successful", cond_a_success)
        logger.info("  Condition B (MD):   %d successful", cond_b_success)
        logger.info("")
        logger.info("  Manifest: %s", self.manifest_path)
        logger.info("  Archive:  %s", self.archive_dir)
        logger.info("")

        # Report failures by type
        if failed > 0:
            failure_types: dict[str, int] = {}
            for e in self.manifest_entries:
                if e.fetch_status != "SUCCESS":
                    failure_types[e.fetch_status] = failure_types.get(e.fetch_status, 0) + 1

            logger.info("  Failures by type:")
            for ftype, count in sorted(failure_types.items()):
                logger.info("    %-20s %d", ftype, count)

    def _print_dry_run_summary(self):
        """Shows what would be fetched without actually fetching."""
        fetch_plan = []
        seen = set()

        for site_id, questions in sorted(self.questions.items()):
            for q in questions:
                for url in q.source_urls:
                    key = (site_id, url)
                    if key not in seen:
                        seen.add(key)
                        fetch_plan.append(key)

        logger.info("")
        logger.info("DRY RUN — Would fetch:")
        logger.info("  Sites: %d", len(self.sites))
        logger.info("  llms.txt files: %d", len(self.sites))
        logger.info("  Unique source URLs: %d", len(fetch_plan))
        logger.info("  Total fetches (2 per URL + llms.txt): ~%d",
                     len(fetch_plan) * 2 + len(self.sites))
        logger.info("  Estimated time at %dms rate limit: ~%d minutes",
                     self.rate_limit_ms,
                     (len(fetch_plan) * 2 + len(self.sites)) * self.rate_limit_ms / 60000)
        logger.info("")

        for site_id, url in fetch_plan[:20]:
            logger.info("  [%s] %s", site_id, url)
        if len(fetch_plan) > 20:
            logger.info("  ... and %d more", len(fetch_plan) - 20)


# ---------------------------------------------------------------------------
# CLI entry point
# ---------------------------------------------------------------------------

def main():
    parser = argparse.ArgumentParser(
        description="Build the content archive for the Context Collapse benchmark.",
        formatter_class=argparse.RawDescriptionHelpFormatter,
        epilog="""
Examples:
  python3 build-archive.py                              # Full archive
  python3 build-archive.py --dry-run                    # See what would be fetched
  python3 build-archive.py --site S001                  # Single site only
  python3 build-archive.py --resume                     # Skip already-fetched URLs
  python3 build-archive.py --verbose --site S001        # Debug single site
""")

    parser.add_argument("--config", default="./benchmark-config.json",
                        help="Path to benchmark-config.json")
    parser.add_argument("--resume", action="store_true",
                        help="Skip URLs with existing SUCCESS entries")
    parser.add_argument("--site", metavar="SITE_ID",
                        help="Only archive a specific site (e.g., S001)")
    parser.add_argument("--dry-run", action="store_true",
                        help="Show plan without fetching")
    parser.add_argument("--verbose", action="store_true",
                        help="Enable debug logging")

    args = parser.parse_args()

    # Configure logging
    level = logging.DEBUG if args.verbose else logging.INFO
    logging.basicConfig(
        level=level,
        format="%(asctime)s %(levelname)-5s %(message)s",
        datefmt="%H:%M:%S",
    )

    # Validate config path
    config_path = Path(args.config)
    if not config_path.exists():
        logger.error("Config file not found: %s", config_path)
        sys.exit(1)

    # Run the builder
    builder = ArchiveBuilder(
        config_path=str(config_path),
        resume=args.resume,
        site_filter=args.site,
        dry_run=args.dry_run,
    )

    try:
        builder.run()
    except KeyboardInterrupt:
        logger.info("\nInterrupted by user. Writing manifest with current progress...")
        builder._write_manifest()
        logger.info("Partial manifest saved. Re-run with --resume to continue.")
        sys.exit(130)
    except Exception as e:
        logger.error("Fatal error: %s", e, exc_info=True)
        # Save whatever we have
        try:
            builder._write_manifest()
            logger.info("Partial manifest saved.")
        except Exception:
            pass
        sys.exit(1)


if __name__ == "__main__":
    main()
