# Benchmark Methodology

**Status:** ✅ Complete — All 7 sections finalized: Corpus Selection Criteria (§1), Content Pair Generation (§2), Question Design (§3), Model Selection (§4), Scoring Protocol (§5, via `corpus/scoring-rubric.md`), Statistical Analysis Plan (§6), Limitations and Threats to Validity (§7)

---

> This document provides the detailed methodology specification for the Context Collapse Mitigation Benchmark, including corpus selection criteria, experimental design, scoring rubric rationale, and statistical analysis plan.
>
> For the study overview, see [README.md](README.md).
> For the full methodology rationale, see the [project proposal](../PROPOSAL.md) (Project 3 § Methodology).
> For the scoring rubric with worked examples, see [`corpus/scoring-rubric.md`](corpus/scoring-rubric.md).

---

## 1. Corpus Selection Criteria

> **Traces To:** Story 4.1, Task 4.1.1
> **Created:** 2026-02-22
> **Last Updated:** 2026-02-22

This section defines what qualifies a site for inclusion in the benchmark corpus, what disqualifies it, and how candidate sites are sourced and verified. These criteria exist to ensure the corpus is large enough for statistical significance, diverse enough to avoid sector bias, and technically suitable for generating paired content under both experimental conditions.

### 1.1 Inclusion Criteria

A site must satisfy **all** of the following minimum requirements to be considered for the corpus:

| # | Requirement | Rationale |
|---|-------------|-----------|
| IC-1 | Site hosts a publicly accessible llms.txt file that parses without error per the [llmstxt.org specification](https://llmstxt.org). | The treatment condition (Condition B) depends on well-formed llms.txt. A file that fails to parse cannot generate valid content pairs. |
| IC-2 | The llms.txt file links to **≥5 distinct Markdown pages** with substantive content. | Fewer than 5 pages limits question diversity. "Substantive" means pages with original documentation content, not redirect stubs or auto-generated index pages. |
| IC-3 | The site also hosts **publicly accessible HTML documentation** covering the same subject matter as the llms.txt-linked pages. | The control condition (Condition A) requires an HTML equivalent for each content pair. If the HTML docs are paywalled, authenticated, or structurally unrelated to the llms.txt content, paired comparison is impossible. |
| IC-4 | Content is primarily in **English**. | This is a single-language study (v1). Multilingual evaluation introduces confounds around tokenization, translation quality, and model capability that are outside scope. |
| IC-5 | Content is **not behind authentication, paywalls, or aggressive bot protection** that would prevent automated retrieval by the data collection runner. | The benchmark must be reproducible. Sites that block automated access cannot be reliably re-tested. |

### 1.2 Exclusion Criteria

A site is excluded from the corpus if **any** of the following conditions apply, even if it satisfies all inclusion criteria:

| # | Exclusion | Rationale |
|---|-----------|-----------|
| EC-1 | The llms.txt file is a **purely auto-generated sitemap** with no link descriptions. | A bare URL list without descriptions represents the lowest-quality llms.txt implementation. Including these would conflate "does llms.txt help?" with "does a bad llms.txt help?"--a different research question. |
| EC-2 | The llms.txt-linked content and the HTML documentation **cover substantially different material**. | Content pairs must represent the same information in two formats. If the llms.txt points to API reference docs while the HTML site is a marketing page, the comparison is invalid. |
| EC-3 | The site's documentation is **predominantly auto-generated** (e.g., Javadoc/Doxygen output with no editorial content). | Auto-generated documentation tends to be structurally uniform, which limits question complexity and may not represent the kind of content where format differences matter. |
| EC-4 | The site's llms.txt file was **created or substantially modified after the corpus selection date**. | Including sites that change their llms.txt in response to being studied introduces observer effects. The corpus is frozen at selection time. |
| EC-5 | The site is **operated by the researcher or contributors to this study**. | Self-authored content introduces familiarity bias in question authoring and scoring. DocStratum's own documentation, for instance, is excluded. |

### 1.3 Sector Diversity Requirements

The corpus must span **at least 3 sectors beyond developer documentation** to avoid the most obvious selection bias: that llms.txt is disproportionately adopted by developer tools companies, and any observed benefit might be specific to that content type.

**Sector taxonomy:**

| Sector | Description | Examples |
|--------|-------------|---------|
| Developer Tools & APIs | SDKs, API references, CLI documentation | Stripe, Vercel, Cloudflare |
| AI & ML Platforms | Model hosting, training platforms, AI frameworks | Anthropic, Hugging Face, Google ADK |
| Cloud Infrastructure | Hosting, deployment, DevOps tooling | AWS, GCP, DigitalOcean |
| SaaS Product Documentation | End-user documentation for SaaS products | Notion, Linear, Figma |
| Open Source Projects | Community-maintained project documentation | FastHTML, various GitHub projects |
| Enterprise Software | Business software, ERP, CRM documentation | Salesforce, ServiceNow |
| Education & Learning | Tutorials, courses, educational platforms | freeCodeCamp, MDN Web Docs |
| Other | Anything not fitting the above categories | Government, healthcare, finance |

**Distribution constraints:**

- No single sector may comprise more than **40%** of the final corpus.
- The "Developer Tools & APIs" sector is expected to be the largest (reflecting actual llms.txt adoption patterns), but must remain under the 40% cap.
- At least **4 sectors** must be represented (developer tools + 3 others minimum).
- If the 30-50 site target proves difficult to fill with adequate diversity, the minimum site count takes priority over perfect sector balance. Document any deviation in the methodology write-up.

**Known deviation (documented 2026-02-23):**

The Developer Tools & APIs sector comprises 30% of the final corpus (11 of 37 sites), which satisfies the 40% cap. The corpus spans 8 sectors — all categories in the taxonomy are now represented. However, the concentration is documented here because earlier corpus iterations exceeded 40% before non-tech sites were sourced, and the margin required exhaustive effort to achieve. The concentration persists despite sourcing efforts that included: direct llms.txt probes against 28+ non-tech domains spanning government (.gov), education (.edu), news, healthcare, legal, e-commerce, hospitality, and real estate sectors; scraping of the llmstxt.site and directory.llmstxt.cloud directories for non-tech entries; and targeted web searches for llms.txt adoption outside the technology industry.

The results are unambiguous: llms.txt adoption outside the developer tools and technology ecosystem is near-zero. Of dozens of non-tech domains probed, only two education platforms (Coursera, edX) returned valid llms.txt files. Every government site, news outlet, healthcare provider, and consumer-facing platform tested returned 404 or 403. Even financial services companies that have adopted llms.txt (Mastercard, Plaid, Square) did so exclusively on their developer-facing documentation subdomains, not their consumer or institutional content.

This concentration is itself a significant finding. The llms.txt specification was designed as a general-purpose mechanism for helping LLMs understand website content, but adoption has been almost entirely confined to audiences already comfortable with Markdown and developer tooling. As AI assistants increasingly serve non-programming tasks--research, education, healthcare navigation, government services--the sector gap identified here represents a substantial untapped audience for the standard. The benchmark's sector skew reflects reality, not selection bias.

### 1.4 Candidate Sourcing

Candidates are sourced from three tiers, evaluated in order of priority:

**Tier 1 — Directories (primary):**
- [llmstxt.site](https://llmstxt.site) — the most comprehensive community-maintained directory
- [directory.llmstxt.cloud](https://directory.llmstxt.cloud) — supplementary directory

These directories are the most efficient starting point because they aggregate sites that already have llms.txt files. However, directory listings are not verified--each candidate must pass the inclusion criteria independently.

**Tier 2 — Known adopters (secondary):**
- Sites identified during the evidence inventory for the analytical paper (see `paper/evidence-inventory.md`)
- Confirmed adopters from the llms.txt reference repository
- Notable examples: Anthropic, Cloudflare, Stripe, Vercel, Coinbase, FastHTML, Google developer documentation properties (ai.google.dev, firebase.google.com, developer.chrome.com, web.dev, google.github.io/adk-docs)

**Tier 3 — Discovery (tertiary):**
- Sites discovered through web search, community forums, or social media discussion about llms.txt
- Sites identified by examining llms.txt files that cross-reference other llms.txt-hosting sites

### 1.5 Verification Protocol

Every candidate site must be manually verified before inclusion. Verification is performed by the primary researcher and recorded in `site-list.csv`.

**Verification checklist:**

- [ ] llms.txt file is publicly accessible at the documented URL
- [ ] llms.txt file parses without error (test with LlmsTxtKit parser or manual inspection against the spec)
- [ ] llms.txt contains ≥5 links to distinct Markdown pages
- [ ] At least 5 linked pages resolve and contain substantive content (not stubs or redirects)
- [ ] Equivalent HTML documentation exists and is publicly accessible
- [ ] HTML content covers the same subject matter as llms.txt-linked pages
- [ ] Site does not trigger any exclusion criteria (EC-1 through EC-5)
- [ ] Sector classification assigned

**Verification is a point-in-time assessment.** The verification date is recorded in `site-list.csv`. If a site's llms.txt file or HTML documentation changes after verification, the corpus record reflects the state at verification time. Content pairs are generated from archived snapshots, not live fetches.

### 1.6 site-list.csv Schema

The corpus manifest is stored as a CSV file at `benchmark/corpus/site-list.csv` with the following columns:

| Column | Type | Required | Description |
|--------|------|----------|-------------|
| `site_id` | String | Yes | Unique identifier, format: `S001`, `S002`, etc. |
| `domain` | String | Yes | Primary domain (e.g., `docs.stripe.com`) |
| `llms_txt_url` | URL | Yes | Full URL to the site's llms.txt file |
| `html_docs_url` | URL | Yes | URL to the root of the HTML documentation |
| `sector` | String | Yes | Sector from the taxonomy in §1.3 |
| `llms_txt_page_count` | Integer | Yes | Number of Markdown pages linked from llms.txt |
| `has_llms_full` | Boolean | Yes | Whether the site also hosts an llms-full.txt |
| `verification_date` | Date | Yes | ISO 8601 date of manual verification |
| `verification_status` | Enum | Yes | `PASS`, `FAIL`, or `EXCLUDED` |
| `exclusion_reason` | String | No | If EXCLUDED, which exclusion criterion (e.g., `EC-1`) |
| `notes` | String | No | Free-text notes from verification |

**Sorting:** By `site_id` (insertion order). No implicit ordering by sector or quality.

**File encoding:** UTF-8, LF line endings, double-quoted string fields.

---

## 2. Content Pair Generation

> **Traces To:** Story 4.1, Task 4.1.2 (corpus), Task 4.1.7 (data collection runner)
> **Created:** 2026-02-25
> **Last Updated:** 2026-02-25
> **Depends On:** LlmsTxtKit `llmstxt_compare` tool (Project 2)

This section specifies how the benchmark generates paired content for each experimental condition. Every (site, question) tuple produces two content inputs — one derived from HTML documentation (Condition A, the control) and one derived from llms.txt-linked Markdown (Condition B, the treatment). The model receives identical prompts for both conditions; only the source content differs. The observed difference in response quality is the experimental signal.

The pipeline has three stages: content archiving (§2.1), content extraction (§2.2–§2.3), and content assembly (§2.4). A pre-fetch archive ensures all models see identical content, and per-question scoping ensures each model receives only the pages relevant to the question being asked.

### 2.1 Content Archiving

All content is fetched once during a dedicated archival phase that runs before any model inference begins. This decouples content retrieval from model evaluation and guarantees that every model sees byte-identical input for the same (site, question, condition) tuple, even if site content changes during the evaluation window.

**Archive structure:**

```
benchmark/archive/
├── manifest.json          # Timestamp, fetch status, and metadata for every page
├── html/
│   └── {site_id}/
│       └── {url_hash}.html    # Raw HTML as fetched (complete response body)
└── markdown/
    └── {site_id}/
        └── {url_hash}.md      # Raw Markdown as fetched from llms.txt-linked URL
```

**`manifest.json` schema:**

Each entry in the manifest records the outcome of a single page fetch:

| Field | Type | Required | Description |
|-------|------|----------|-------------|
| `site_id` | String | Yes | Site identifier from `site-list.csv` |
| `url` | String | Yes | The URL that was fetched |
| `url_hash` | String | Yes | SHA-256 of the URL, used as the filename (avoids path-length and encoding issues) |
| `condition` | Enum | Yes | `A` (HTML) or `B` (Markdown) |
| `fetch_timestamp` | DateTime | Yes | ISO 8601 timestamp of the fetch |
| `http_status` | Integer | Yes | HTTP response status code |
| `content_type` | String | Yes | HTTP `Content-Type` header value |
| `content_length_bytes` | Integer | Yes | Size of the saved file in bytes |
| `last_modified` | DateTime | No | HTTP `Last-Modified` header, if present |
| `etag` | String | No | HTTP `ETag` header, if present |
| `fetch_status` | Enum | Yes | `SUCCESS`, `HTTP_ERROR`, `TIMEOUT`, `DNS_FAILURE`, `WAF_BLOCKED`, `JS_ONLY` |
| `failure_reason` | String | No | Human-readable explanation if `fetch_status` is not `SUCCESS` |

**Archival protocol:**

1. For each site in `site-list.csv`, fetch all unique URLs that appear in `questions.json` `source_urls` arrays for that site's questions.
2. For each URL, perform two fetches:
   - **Condition A fetch:** Fetch the HTML documentation page at the URL (or its HTML equivalent if the URL points to Markdown).
   - **Condition B fetch:** Fetch the llms.txt-linked Markdown page that covers the same content. The mapping from HTML URL to Markdown URL is derived from the site's llms.txt file — each linked Markdown page has a corresponding HTML documentation page, and this mapping is recorded in `site-list.csv` or discovered by LlmsTxtKit's `llmstxt_compare` tool.
3. Record the fetch result in `manifest.json` regardless of outcome. Failed fetches are logged, not retried automatically, so the manifest is a complete record of what was attempted.
4. After the archival phase completes, validate that every `source_url` in `questions.json` has a corresponding archive entry for both conditions. Missing entries are flagged for manual review.

**Timing:** The archival phase runs once, ideally within a single 24-hour window, to minimize the chance that site content changes between fetches of different pages on the same site. The archive is immutable after creation — no subsequent fetches update it.

**Implementation:** `scripts/build-archive.py` — a standalone Python script that reads `benchmark-config.json`, `site-list.csv`, and `questions.json`, fetches all content, and writes the archive directory and `manifest.json`. Supports `--resume` for crash recovery, `--dry-run` for planning, and `--site` for single-site debugging. Respects `robots.txt` per the `archive_protocol.respect_robots_txt` config setting and detects JavaScript-only pages (`JS_ONLY` status) via content heuristics.

### 2.2 Condition A: HTML Content Extraction

Condition A represents the control — how an AI system would typically ingest web documentation today. The pipeline uses **readability-style content extraction** to isolate the main documentation body from navigation chrome, sidebars, footers, cookie banners, and other boilerplate. This reflects the current state of production RAG pipelines and AI search backends, which generally apply some form of content extraction rather than feeding raw HTML to models.

**Why readability extraction (not naive innerText, not HTML-to-Markdown conversion):**

The choice of extraction method directly determines what the study measures. A naive `innerText` dump (which includes navigation, footers, and all visible text) would make Condition A artificially bad and inflate the apparent benefit of llms.txt — but almost no production system does this. Conversely, a full HTML-to-Markdown conversion (which preserves structure, headings, and links while stripping markup) would produce output close in quality to Condition B, potentially masking a real effect — but this level of cleanup is also uncommon in typical retrieval pipelines.

Readability extraction sits in the middle: it identifies and extracts the "main content" region of the page (the article body, the documentation section) while discarding structural boilerplate. This is the approach used by Mozilla Firefox's Reader Mode, Jina AI's reader API, and most document-processing libraries used in RAG systems. It produces text that is clean enough to be useful but retains the noise characteristics of real-world HTML-derived content — inline links may be stripped or flattened, table formatting may degrade, code blocks may lose syntax highlighting context.

**Extraction pipeline (Condition A):**

```
Raw HTML (from archive)
  → Readability content extraction (isolate main content region)
  → Strip <script> and <style> elements (if not already removed by readability)
  → Normalize whitespace (collapse runs of whitespace, normalize line endings to LF)
  → Trim leading/trailing whitespace
  → Output: plain text with basic structure preserved
```

**Library selection (.NET):**

The data collection runner is C#/.NET (see `scripts/run-benchmark.cs`). The recommended library for readability extraction in .NET is **SmartReader**, a .NET port of Mozilla's Readability.js. SmartReader extracts the main content area, page title, and metadata from an HTML page, producing cleaned text output.

Alternative .NET options considered:

| Library | Approach | Pros | Cons |
|---------|----------|------|------|
| **SmartReader** (recommended) | Mozilla Readability port | Well-maintained, battle-tested algorithm, NuGet package | May strip tables or code blocks in some edge cases |
| **AngleSharp** + custom extraction | DOM parsing + heuristic selectors | Full DOM access, highly configurable | Requires writing custom extraction logic per-site or per-template |
| **HtmlAgilityPack** + custom XPath | XPath-based content selection | Mature, widely used in .NET | Same custom-logic problem as AngleSharp; no readability heuristics |
| **Process-hosted Python (Trafilatura)** | Shell out to Python Trafilatura | Best-in-class extraction quality, academic validation | Cross-runtime dependency, adds complexity, slower |

**Decision:** SmartReader is the primary extraction library. If SmartReader fails to extract meaningful content from a page (returns empty or trivially short text), the failure is logged in `manifest.json` with `fetch_status: JS_ONLY` or an appropriate failure code, and that page is handled per the retrieval failure protocol (§2.5).

### 2.3 Condition B: llms.txt Markdown Retrieval

Condition B represents the treatment — the content a model would receive if the site's llms.txt file were used to locate and serve curated Markdown. The pipeline replicates the behavior of the reference implementation's `create_ctx()` function from the canonical `AnswerDotAI/llms-txt` repository.

**Why replicate `create_ctx()` behavior:**

The reference implementation is the ground truth for how llms.txt content is intended to be consumed by AI systems. Using a different assembly method would introduce a confound — the study would be testing "our custom Markdown pipeline vs. HTML extraction" rather than "the llms.txt-prescribed consumption model vs. HTML extraction." Ecological validity requires that Condition B represent the actual intended use of llms.txt.

**Retrieval pipeline (Condition B):**

```
Raw Markdown (from archive)
  → Strip HTML comments (<!-- ... -->)
  → Strip base64-encoded images (data:image/... URIs)
  → Normalize whitespace (collapse excessive blank lines to maximum 2, normalize to LF)
  → Wrap in XML context structure per reference implementation format
  → Output: XML-wrapped Markdown content
```

**XML context structure:**

Following the reference implementation's output format, each page's content is wrapped in a `<doc>` element within a section element:

```xml
<project title="{site_title}" summary="{site_summary}">
  <section_name>
    <doc title="{page_title}" url="{page_url}">
      {markdown_content}
    </doc>
  </section_name>
</project>
```

Where `section_name` is the H2 section heading from the site's llms.txt file under which the page is linked. This structure mirrors how Claude and other XML-aware models are designed to process llms.txt-derived context.

**Reference implementation behavioral requirements:**

The following behaviors are replicated from the canonical `AnswerDotAI/llms-txt` Python implementation (documented in `docs/project/llms-txt-reference-repo-analysis.md`):

| Behavior | Reference Implementation | Benchmark Replication |
|----------|--------------------------|----------------------|
| Optional section handling | `optional=False` by default (excluded) | Exclude Optional sections unless a question's `source_urls` explicitly reference content from an Optional section |
| HTML comment stripping | Stripped from fetched Markdown | Stripped during preprocessing |
| Base64 image stripping | Stripped from fetched Markdown | Stripped during preprocessing |
| Section identification | H2-only splitting (`^##\s*`) | H2-only; H3+ treated as content within parent section |
| Link parsing | Dash-prefixed, description optional | Same regex pattern |
| Blockquote handling | Single-line only | Single-line only |

### 2.4 Content Assembly (Per-Question Scoping)

Each question in the benchmark targets specific pages within a site's documentation. Rather than feeding the model the entire site's content (which would overwhelm smaller models and dilute the signal for per-question analysis), the content input is scoped to **only the pages identified in the question's `source_urls` array**.

**Assembly rules:**

1. For a given (site, question) tuple, look up the question's `source_urls` in `questions.json`.
2. For **Condition A**, concatenate the readability-extracted text for each source URL, separated by a double newline and a horizontal rule (`---`). Pages are concatenated in the order they appear in the `source_urls` array.
3. For **Condition B**, assemble the XML context structure containing only the `<doc>` elements corresponding to the source URLs. The `<project>` wrapper and section groupings are preserved — if two source URLs belong to different sections, both section elements appear in the output.
4. If a source URL has no corresponding archive entry (or the archive entry indicates a fetch failure), that URL is omitted from the assembled content. If this reduces the available content below the threshold needed to answer the question (e.g., all source URLs failed for one condition), the question is excluded from that condition per §2.5.

**Single-fact questions** typically have one source URL, producing a single page of content per condition. **Multi-section-synthesis** and **conceptual-relationship questions** have two or more source URLs, producing multi-page content. This natural variation in content size is itself a data point — the token efficiency metric captures how much content was required per condition.

**Prompt template:**

The assembled content is inserted into a standardized prompt template. The template is identical for both conditions — only the content block differs:

```
System: You are a factual question-answering system. Answer the following question
using only the provided documentation content. If the content does not contain
enough information to answer the question, say so explicitly.

Content:
{assembled_content}

Question: {question_text}
```

The system prompt, content label, and question framing are constant across all experimental runs. No condition-specific language (e.g., "this is Markdown" or "this was extracted from HTML") appears in the prompt, to avoid priming the model.

### 2.5 Retrieval Failure Handling

When content cannot be retrieved for one or both conditions, the affected (site, question, model, condition) tuple is **excluded from analysis** rather than scored as a failure. This prevents retrieval infrastructure issues from contaminating response quality metrics.

**Failure classification:**

| Failure Mode | Detection | Handling |
|--------------|-----------|----------|
| HTTP error (4xx, 5xx) | Archive manifest `http_status` | Exclude affected tuples; log in raw-data.csv with `exclusion_reason: HTTP_{status}` |
| Timeout | Archive manifest `fetch_status: TIMEOUT` | Exclude; log with `exclusion_reason: TIMEOUT` |
| WAF/bot block | Archive manifest `fetch_status: WAF_BLOCKED` | Exclude; log with `exclusion_reason: WAF_BLOCKED` |
| JS-only rendering | SmartReader returns empty/trivial text (<50 chars) | Exclude Condition A tuples; Condition B may still be usable if Markdown was fetchable. Log with `exclusion_reason: JS_ONLY` |
| DNS failure | Archive manifest `fetch_status: DNS_FAILURE` | Exclude; log with `exclusion_reason: DNS_FAILURE` |
| Markdown not available | No llms.txt-linked Markdown corresponds to the HTML URL | Exclude Condition B tuples; log with `exclusion_reason: NO_MARKDOWN_MAPPING` |

**Exclusion accounting:**

The analysis notebook (Phase 2) reports exclusion statistics in Section 1 (Data Loading and Validation):

- Total (site, question, model, condition) tuples attempted
- Total tuples excluded, broken down by failure mode
- Per-site exclusion rates (to identify problematic sites like S032/UBC)
- Per-condition exclusion rates (to identify whether one condition systematically fails more often — which is itself a finding)

If a site's exclusion rate exceeds 50% of its questions under either condition, the site is flagged in the write-up as having limited data. It is not removed from the corpus (partial data is still useful), but its contribution to aggregate statistics is noted.

**Known issue — S032 (UBC):**

During gold-standard answer verification (Task 4.1.5), all 8 questions for S032 (students.ubc.ca) were flagged as unverifiable because the site renders content via JavaScript only. Condition A extraction is expected to fail for this site. Condition B (Markdown from llms.txt) may succeed if the llms.txt-linked pages are static Markdown files. If Condition B succeeds but Condition A fails, S032 provides a natural case study for the write-up: a site where llms.txt is the *only* viable path to clean content for AI consumption.

### 2.6 Tokenization

Token efficiency is a primary metric that measures the input cost of each condition. Because different model families use different tokenizers, the same text produces different token counts depending on which model will consume it. The benchmark reports **both** per-model-family counts and a standardized reference count.

**Per-model-family tokenization (primary metric):**

For each assembled content block, compute the token count using the actual tokenizer for the model family that will consume it. This is done programmatically using the `transformers` library's `AutoTokenizer` (or equivalent) for each model family under test:

| Model Family | Tokenizer Source | Notes |
|--------------|------------------|-------|
| Llama 3.x | `meta-llama/Llama-3.3-*` HuggingFace tokenizer | BPE-based, ~128K vocab |
| Qwen 3 | `Qwen/Qwen3-*` HuggingFace tokenizer | BPE-based, ~150K vocab |
| Gemma 3 | `google/gemma-3-*` HuggingFace tokenizer | SentencePiece-based, ~256K vocab |
| Mistral | `mistralai/Mistral-Small-3.1-*` HuggingFace tokenizer | BPE-based, ~32K vocab |

See §4 (Model Selection) for the specific models, sizes, and rationale behind the family choices.

The per-model token count is recorded in `raw-data.csv` as `input_token_count` and reflects what the model actually processes.

**Reference tokenizer (standardized comparison):**

In addition to per-model counts, every content block is tokenized with a single reference tokenizer — **Llama 3's tokenizer** (`meta-llama/Llama-3.1-8B`) — to produce a model-independent "content size" measure. This standardized count is recorded as `ref_token_count` in `raw-data.csv` and used in cross-model comparisons where a consistent unit is needed (e.g., "Condition B was on average X% fewer tokens than Condition A").

The choice of Llama 3 as the reference tokenizer is pragmatic: it is the most widely used open-weights model family, its tokenizer is publicly available, and its BPE vocabulary produces counts that are broadly representative of modern tokenizers.

**Token count recording:**

For each (site, question, model, condition) tuple, `raw-data.csv` records:

| Column | Description |
|--------|-------------|
| `input_token_count` | Token count using the actual model family's tokenizer |
| `ref_token_count` | Token count using the Llama 3 reference tokenizer |
| `output_token_count` | Token count of the model's response (using the model family's tokenizer) |
| `content_chars` | Character count of the assembled content (a tokenizer-independent size measure) |

Input token counts and reference counts are pre-computed during content assembly (before any model inference begins), since they depend only on the assembled content. Output token counts are measured during inference by the data collection runner and recorded alongside the response — they cannot be known in advance because they depend on what the model generates.

**Analysis framework:**

The analysis notebook (Phase 2, Section 2) uses these counts for three levels of analysis:

1. **Per-site token comparison:** For each site, compute the mean token reduction (Condition A − Condition B) using reference tokenizer counts. This answers "how much smaller is the llms.txt content?"
2. **Cross-model token variation:** For each content block, compare per-model token counts to identify whether certain tokenizers are more or less sensitive to the HTML vs. Markdown format difference.
3. **Token-quality correlation:** Plot the token reduction against the accuracy delta to test whether larger token savings predict larger quality improvements (or whether there's a diminishing-returns threshold).

---

## 3. Question Design

> **Traces To:** Story 4.1, Tasks 4.1.3, 4.1.4, 4.1.5
> **Created:** 2026-02-23
> **Last Updated:** 2026-02-23

This section defines what constitutes a well-formed benchmark question, the complexity taxonomy used to classify questions, and the schemas for `questions.json` and `gold-answers.json`. These rules are written before question authoring begins so that every question in the corpus has a documented standard to comply with.

### 3.1 Complexity Levels

Every question is classified into exactly one of three complexity levels. The levels describe the cognitive demand placed on the model -- how much content it must locate, integrate, and reason about to produce a correct answer.

| Level | ID | Definition | Example Framing |
|-------|----|------------|-----------------|
| **Single-Fact** | `single-fact` | Answerable from a single paragraph, table row, or localized section. The model must locate the relevant passage and extract one discrete piece of information. | "What authentication method does the X API use?" / "What is the default port for Y?" |
| **Multi-Section Synthesis** | `multi-section-synthesis` | Requires combining information from two or more distinct sections or pages. No single passage contains the complete answer; the model must integrate material from different locations in the documentation. | "What are the prerequisites for deploying X, including both authentication setup and environment configuration?" / "How do webhooks and API keys work together in the Z authentication flow?" |
| **Conceptual Relationship** | `conceptual-relationship` | Requires understanding how two or more concepts relate to each other -- trade-offs, dependencies, distinctions, or conditional applicability. The answer is not a fact retrieval but a structural understanding of how the documentation's concepts connect. | "When should you use X instead of Y?" / "What is the difference between X and Y, and when does it matter?" / "Why does changing X require also updating Y?" |

### 3.2 Distribution Requirements

Each site's question set must include representation from all three complexity levels. The minimum distribution per site is:

| Complexity | Minimum | Rationale |
|------------|---------|-----------|
| `single-fact` | 2 | Baseline capability -- can the model extract a simple fact from the content? |
| `multi-section-synthesis` | 2 | Integration capability -- can the model combine information across sections? |
| `conceptual-relationship` | 1 | Reasoning capability -- can the model understand structural relationships? |

The remaining questions (up to the 5-10 total) may be distributed based on the site's content richness. Sites with deeply structured documentation (many sections, cross-references, configuration trade-offs) should lean toward more synthesis and relationship questions. Sites with flatter structures (fewer sections, simpler content) may have a higher proportion of single-fact questions.

**Statistical rationale:** The analysis notebook (Phase 2) will perform per-complexity-level breakdowns to test whether synthesis questions show larger effects than single-fact questions. Maintaining at least 2 questions per level across 37 sites yields 74+ data points per level per model -- sufficient for meaningful subgroup analysis.

### 3.3 Question Authoring Guidelines

These rules govern what makes a question suitable for the benchmark. Questions that violate any of these rules must be revised or replaced before inclusion.

**QG-1. Answerable from site content alone.** The question must be definitively answerable using only the content available through the site's llms.txt-linked pages and their HTML equivalents. No external knowledge, prior experience with the product, or information from other sites should be required.

**QG-2. Specific enough to avoid generic answers.** The question must engage the site's specific content deeply enough that a generic answer (one that could apply to any product in the same category) would score no higher than 1 on the factual accuracy scale. "What does Stripe do?" is too generic. "What authentication method does Stripe require for server-to-server API calls?" is specific.

**QG-3. Has a definitive correct answer.** The question must have a factual answer that can be verified against the site's content. Opinion questions ("Is X a good choice for Y?"), subjective questions ("How easy is X to use?"), and open-ended questions ("What are some things you can do with X?") are excluded.

**QG-4. Not trivially answerable from metadata alone.** The question should not be answerable solely from the page title, URL, or llms.txt link description without reading the actual content. These are the facts a model could guess from context rather than demonstrate comprehension.

**QG-5. Tests content comprehension, not model knowledge.** The question should be designed so that a model answering from the provided content would outperform a model answering from general training knowledge. If a model's pre-training is likely to contain the answer regardless of the provided context, the question has limited discriminative value for this benchmark.

**QG-6. Source sections are documented.** Every question must record which section(s) or page(s) of the site's content contain the answer. For single-fact questions, this is one section. For synthesis and relationship questions, this is two or more sections. This metadata enables traceability during scoring and supports the gold-standard answer authoring process (Task 4.1.5).

### 3.4 Gold-Standard Answer Criteria

Gold-standard answers are authored by the researcher for Task 4.1.5. They are stored in `gold-answers.json` and serve as the reference against which all model responses are scored. The following criteria govern gold-standard answer quality:

**GA-1. Sourced directly from site content.** Every claim in the gold-standard answer must be traceable to a specific passage in the site's documentation. The source page URL is recorded alongside the answer.

**GA-2. Written in complete prose.** Answers are written as 1-3 complete sentences, not bullet points or sentence fragments. This mirrors the expected format of a model response and makes scoring comparison straightforward.

**GA-3. Contains all material facts.** The answer must include every fact that a score-3 response would need to contain. If a question asks "What authentication method does X use for server-to-server calls?", the gold-standard answer should include the method name, how credentials are passed, and where they're obtained -- all the facts that distinguish a score-3 from a score-2.

**GA-4. Contains no facts beyond what the site provides.** The gold-standard answer must not supplement the site's content with external knowledge, even if the researcher knows additional relevant information. The benchmark tests what the model can extract from the provided content, not what a knowledgeable human could add.

**GA-5. Verified against live content at authoring time.** The researcher must verify that the gold-standard answer is consistent with the site's content on the date it is authored. The verification date is recorded in `gold-answers.json`.

### 3.5 questions.json Schema

The question corpus is stored as a JSON array of site objects. Each site object contains the site identifier and an array of question objects.

```json
[
  {
    "site_id": "S001",
    "domain": "docs.stripe.com",
    "questions": [
      {
        "question_id": "S001-Q01",
        "text": "What authentication method does the Stripe API use for server-to-server calls?",
        "complexity": "single-fact",
        "source_sections": ["Authentication"],
        "source_urls": ["https://docs.stripe.com/api/authentication"]
      },
      {
        "question_id": "S001-Q02",
        "text": "How do webhook signatures and API keys work together in the Stripe integration security model?",
        "complexity": "multi-section-synthesis",
        "source_sections": ["Authentication", "Webhooks"],
        "source_urls": [
          "https://docs.stripe.com/api/authentication",
          "https://docs.stripe.com/webhooks"
        ]
      },
      {
        "question_id": "S001-Q03",
        "text": "When should a Stripe integration use restricted API keys instead of secret keys?",
        "complexity": "conceptual-relationship",
        "source_sections": ["Authentication", "API Keys"],
        "source_urls": [
          "https://docs.stripe.com/api/authentication",
          "https://docs.stripe.com/keys"
        ]
      }
    ]
  }
]
```

**Field definitions:**

| Field | Type | Required | Description |
|-------|------|----------|-------------|
| `site_id` | String | Yes | Site identifier from `site-list.csv` (e.g., `S001`) |
| `domain` | String | Yes | Domain for human readability |
| `questions` | Array | Yes | Array of question objects (5-10 per site) |
| `question_id` | String | Yes | Unique identifier: `{site_id}-Q{nn}` (zero-padded, e.g., `S001-Q01`) |
| `text` | String | Yes | The question text, phrased as a complete question ending with `?` |
| `complexity` | Enum | Yes | One of: `single-fact`, `multi-section-synthesis`, `conceptual-relationship` |
| `source_sections` | Array[String] | Yes | Section name(s) containing the answer. Single-element for `single-fact`, multi-element for synthesis/relationship. |
| `source_urls` | Array[String] | Yes | URL(s) of the specific page(s) from which the answer is sourced. Must be URLs that appear in the site's llms.txt file. |

**Naming convention:** Question IDs use zero-padded two-digit numbering (`Q01` through `Q99`) to maintain sort order.

### 3.6 gold-answers.json Schema

Gold-standard answers are stored as a JSON array of site objects, paralleling the structure of `questions.json`.

```json
[
  {
    "site_id": "S001",
    "domain": "docs.stripe.com",
    "answers": [
      {
        "question_id": "S001-Q01",
        "gold_answer": "The Stripe API uses API key authentication for server-to-server calls. Secret keys or restricted keys are passed in the Authorization header using the Bearer scheme. Keys can be generated in the Stripe Dashboard under Developers > API Keys.",
        "source_urls": ["https://docs.stripe.com/api/authentication"],
        "verified_date": "2026-02-23"
      }
    ]
  }
]
```

**Field definitions:**

| Field | Type | Required | Description |
|-------|------|----------|-------------|
| `site_id` | String | Yes | Site identifier (must match `questions.json`) |
| `domain` | String | Yes | Domain for human readability |
| `answers` | Array | Yes | Array of answer objects (one per question) |
| `question_id` | String | Yes | Question identifier (must match `questions.json`) |
| `gold_answer` | String | Yes | The definitive correct answer in 1-3 complete sentences |
| `source_urls` | Array[String] | Yes | URL(s) from which the answer was sourced |
| `verified_date` | Date | Yes | ISO 8601 date when the answer was verified against live content |

---

## 4. Model Selection

> **Traces To:** Story 4.1, Task 4.1.7 (data collection runner)
> **Created:** 2026-02-25
> **Last Updated:** 2026-02-25
> **Depends On:** Ollama or LM Studio installed on the test machine

This section specifies which models are tested, at what sizes and quantization levels, and with what inference parameters. The selections are designed to answer the study's core secondary question: **does the llms.txt effect vary with model capability?** By testing multiple families at multiple sizes under identical conditions, the study can identify whether smaller models benefit disproportionately from cleaner input (the primary hypothesis) or whether the effect is uniform across capability tiers.

### 4.1 Hardware and Inference Platform

**Test machine:** Mac Studio with Apple M3 Ultra chip, 512GB unified memory.

Apple Silicon's unified memory architecture means the CPU and GPU share a single memory pool. A model loaded into memory is fully available to the GPU without the VRAM/RAM split that constrains NVIDIA-based setups. The 512GB capacity comfortably accommodates any single open-weights model up to ~350GB (the remaining memory is reserved for macOS, the KV cache, and inference framework overhead), and can serve multiple smaller models sequentially without reloading.

**Inference engines:** Models are served locally via **Ollama** or **LM Studio**, both of which use `llama.cpp` as the backend inference engine on Apple Silicon. Both expose a local HTTP API (Ollama on port 11434 by default, LM Studio on a configurable port) that the data collection runner (`scripts/run-benchmark.cs`) calls to submit prompts and receive responses.

The choice between Ollama and LM Studio is operationally interchangeable for this benchmark — both consume the same GGUF model files, support the same quantization formats, and expose OpenAI-compatible chat completion endpoints. The data collection runner abstracts the endpoint behind a configurable base URL in `scripts/benchmark-config.json`, so either engine can be used without code changes. The specific engine used for each model run is recorded in `raw-data.csv` for reproducibility.

**Why local inference (not cloud APIs):**

The study requires full control over the model, its parameters, and its input processing. Cloud APIs introduce confounds that local inference avoids: opaque system prompts, undisclosed context window management, request batching, and server-side caching. Local inference guarantees that the model receives exactly the prompt specified in §2.4, with no intermediary processing.

### 4.2 Model Families

Four model families are selected to represent the major open-weights ecosystems. Each family has distinct training data, architecture decisions, and tokenization strategies, which provides diversity in how the benchmark inputs are processed. The families are ordered by release recency of the versions under test.

**Llama 3.3 (Meta)**

The most widely deployed open-weights family. Llama 3.3 uses a dense transformer architecture with grouped-query attention (GQA) and a BPE tokenizer with ~128K vocabulary. It is available in multiple sizes and has the largest downstream ecosystem (fine-tunes, quantizations, tooling). The Llama family serves as the baseline against which other families are compared, and the Llama 3.1 8B tokenizer is the reference tokenizer for cross-model comparisons (§2.6).

**Qwen 3 (Alibaba)**

Currently the strongest-performing open-weights family for its size class. Qwen 3 uses a BPE tokenizer with ~150K vocabulary and offers both dense models (0.6B through 32B) and Mixture-of-Experts (MoE) variants. The dense models are used in this benchmark to avoid the active-vs-total parameter ambiguity introduced by MoE architectures. Qwen3 4B has been benchmarked as competitive with Qwen2.5 72B on several tasks, making it an outlier candidate for the "does smaller model benefit more?" analysis.

**Gemma 3 (Google)**

Google's open-weights family, built on a SentencePiece tokenizer with ~256K vocabulary — the largest vocabulary among the four families. This tokenizer difference is itself a data point: a larger vocabulary tends to produce fewer tokens for the same text, which could interact with the token efficiency metric in interesting ways. Gemma 3 is available in four dense sizes (1B, 4B, 12B, 27B), providing the most granular size ladder of any family in the benchmark.

**Mistral (Mistral AI)**

Mistral Small 3.1 (24B dense) is included as a single-size representative. It uses a BPE tokenizer with ~32K vocabulary — the smallest among the four families — which provides a useful contrast point for tokenization analysis. At 24B parameters, Mistral Small 3.1 has been benchmarked as competitive with Llama 3.3 70B while being over 3× faster on the same hardware. The previous-generation Mistral Large (123B dense) is included as the largest dense model in the benchmark, fitting on the test machine at Q8_0 quantization (~69GB).

### 4.3 Model Matrix

The following table lists every (family, size) combination included in the benchmark. The matrix is designed around three capability tiers — Small (~4-8B parameters), Medium (~12-27B), and Large (~70-123B) — to enable the capability-curve analysis described in §4.2. Not every family has a model at every tier; gaps reflect what is available as GGUF on Ollama/LM Studio.

| Model ID | Family | Parameters | Tier | Ollama Tag | Approx. Q8_0 Size | Notes |
|----------|--------|-----------|------|------------|-------------------|-------|
| `llama-3.3-8b-q8_0` | Llama | 8B | Small | `llama3.3:8b-instruct-q8_0` | ~8 GB | Reference tokenizer family |
| `llama-3.3-70b-q8_0` | Llama | 70B | Large | `llama3.3:70b-instruct-q8_0` | ~74 GB | Largest dense Llama; GQA architecture |
| `qwen3-8b-q8_0` | Qwen 3 | 8B | Small | `qwen3:8b-q8_0` | ~9 GB | Strong for size; thinking mode disabled |
| `qwen3-14b-q8_0` | Qwen 3 | 14B | Medium | `qwen3:14b-q8_0` | ~16 GB | Mid-range dense Qwen |
| `qwen3-32b-q8_0` | Qwen 3 | 32B | Large | `qwen3:32b-q8_0` | ~35 GB | Top dense Qwen; strong reasoning |
| `gemma3-4b-q8_0` | Gemma 3 | 4B | Small | `gemma3:4b-it-q8_0` | ~5 GB | Smallest multimodal Gemma; 256K vocab tokenizer |
| `gemma3-12b-q8_0` | Gemma 3 | 12B | Medium | `gemma3:12b-it-q8_0` | ~13 GB | Mid-range Gemma |
| `gemma3-27b-q8_0` | Gemma 3 | 27B | Large | `gemma3:27b-it-q8_0` | ~29 GB | Largest Gemma 3 |
| `mistral-small-3.1-24b-q8_0` | Mistral | 24B | Medium | `mistral-small3.1:24b-instruct-q8_0` | ~26 GB | Apache 2.0; 128K context |
| `mistral-large-123b-q8_0` | Mistral | 123B | Large | `mistral-large:123b-instruct-q8_0` | ~130 GB | Largest dense model in benchmark |

**Total: 10 models** (3 Small, 3 Medium, 4 Large)

**Ollama tag availability:** The tags listed above reflect expected naming conventions as of February 2026. Before running the benchmark, verify tag availability with `ollama list` or the [Ollama library](https://ollama.com/library). If a tag has changed (e.g., version suffix, quantization naming), update `scripts/benchmark-config.json` and record the actual tag used in `raw-data.csv`.

**Tier distribution rationale:**

- **Small tier (3 models: 4B, 8B, 8B):** These models have the tightest effective context windows and the least robust reasoning. If the llms.txt effect is driven by reducing noise in the input, small models should show the largest benefit — they have the least capacity to "filter out" irrelevant content on their own.
- **Medium tier (3 models: 12B, 14B, 24B):** The practical sweet spot for local deployment. Most users running local models for real work use this size range. If the effect is present here, it has immediate practical relevance.
- **Large tier (4 models: 27B, 32B, 70B, 123B):** These models have strong reasoning and large effective context. If the llms.txt effect diminishes at this tier, it suggests that model capability can compensate for noisy input — an important finding for the llms.txt cost-benefit argument.

### 4.4 Excluded Models and Rationale

The following model types are deliberately excluded from the benchmark. Each exclusion is documented to prevent the appearance of cherry-picking.

| Excluded Category | Examples | Rationale |
|-------------------|----------|-----------|
| **Mixture-of-Experts (MoE) models** | Llama 4 Scout (17B active / 109B total), Qwen3 MoE variants, Mixtral | MoE models report two parameter counts (active and total). Plotting "effect size vs. model size" becomes ambiguous — do you use active parameters (17B, suggesting it belongs in the Small tier) or total parameters (109B, suggesting Large)? Excluding MoE keeps the capability axis clean. A follow-up study could examine MoE specifically. |
| **Reasoning/thinking models** | DeepSeek-R1, QwQ | These models produce extended chain-of-thought before answering. The benchmark's prompt template (§2.4) asks for direct factual answers. A thinking model would generate hundreds of reasoning tokens before the answer, inflating `output_token_count` and making completeness/accuracy scoring ambiguous (do you score the reasoning chain or just the final answer?). |
| **Cloud-only models** | Mistral Large 3 (675B MoE), proprietary APIs | Cloud models cannot be served locally with controlled parameters. The study requires deterministic inference with known quantization, fixed seeds, and no server-side processing. |
| **Fine-tuned/specialized variants** | Code-specific models, domain-adapted models | The benchmark tests general-purpose instruction-following. Specialized models might perform anomalously well on developer documentation questions but poorly on other content types, introducing a confound. |
| **Models below 4B parameters** | Qwen3 0.6B, Qwen3 1.7B, Gemma3 1B | Models this small are unlikely to produce coherent multi-sentence answers to the benchmark's questions, particularly synthesis and relationship questions. Including them would inflate the failure rate without contributing meaningful signal about the format effect. |

### 4.5 Quantization

All models are quantized to **Q8_0** (8-bit integer quantization). This is fixed across the entire benchmark to eliminate quantization level as a confound.

**Why Q8_0:**

Q8_0 is effectively lossless for inference quality — published perplexity evaluations show a degradation of approximately +0.0004 perplexity compared to FP16, which is well below the noise floor of this benchmark's scoring resolution. It reduces memory footprint by roughly 50% compared to FP16, which provides faster model loading and more headroom for KV cache (important for the larger content blocks in multi-section-synthesis questions).

The 512GB test machine could accommodate most models at FP16, but Q8_0 is chosen for consistency: the largest model in the matrix (Mistral Large 123B at ~130GB in Q8_0) fits comfortably, whereas FP16 would push it to ~246GB and leave less room for KV cache at large context sizes.

**Quantization alternatives considered:**

| Level | Perplexity Delta vs. FP16 | Memory Savings | Reason Not Selected |
|-------|--------------------------|----------------|---------------------|
| FP16 | Baseline (0.0000) | 0% | Unnecessary given hardware; inconsistent with Mistral Large 123B memory budget |
| Q8_0 **(selected)** | ~+0.0004 | ~50% | Near-lossless; fits all models with headroom |
| Q6_K | ~+0.001 | ~60% | Slightly more aggressive; chosen only if Q8_0 proves too slow |
| Q4_K_M | ~+0.01 | ~75% | Measurable quality loss; common for deployment but introduces a confound for benchmarking |

**Recording:** The quantization level is recorded in `raw-data.csv` as part of the `model_id` string (e.g., `llama-3.3-70b-q8_0`). If a model must be run at a different quantization for technical reasons (e.g., GGUF Q8_0 not available for a specific checkpoint), the deviation is documented in `scoring_notes` and flagged in the analysis.

### 4.6 Inference Parameters

All models are run with identical inference parameters. These parameters are locked before data collection begins and recorded in `scripts/benchmark-config.json`.

| Parameter | Value | Rationale |
|-----------|-------|-----------|
| `temperature` | `0.0` | Greedy decoding. Selects the highest-probability token at each step. Produces deterministic output for the same input, eliminating sampling variance. Standard for factual QA benchmarks. |
| `seed` | `42` | Fixed random seed. Provides a second layer of determinism beyond temperature 0. Some quantized inference backends introduce minor floating-point nondeterminism; a fixed seed makes results as reproducible as the backend allows. |
| `top_p` | `1.0` | Disabled (no nucleus sampling). At temperature 0, sampling is not invoked, but setting `top_p` to 1.0 ensures no filtering occurs if the backend interprets these parameters differently. |
| `top_k` | `0` | Disabled (no top-k filtering). Same rationale as `top_p`. |
| `repeat_penalty` | `1.0` | Disabled (no repetition penalty). Repetition penalties can alter factual recall by penalizing tokens the model has already generated, which could suppress correct repeated terminology. |
| `num_predict` | `512` | Maximum output tokens. Generous ceiling for 1-3 sentence factual answers (gold-standard answers average ~60 tokens). Prevents runaway generation while allowing the model room for longer responses if it produces them. Responses exceeding 512 tokens are truncated and flagged in `scoring_notes`. |
| `num_ctx` | Dynamic | Context window size, set per-run to the minimum of: (a) the model's maximum supported context length, and (b) `input_token_count + num_predict + 128` (the 128 provides overhead for system prompt tokens and formatting). This avoids allocating unnecessarily large KV caches for short inputs while ensuring the full content fits. |

**Qwen 3 thinking mode:**

Qwen 3 models support an optional "thinking" mode that generates internal reasoning before producing a response. For this benchmark, thinking mode is **disabled** by including `/no_think` in the prompt or setting the appropriate Ollama parameter. The benchmark measures factual answer quality, not reasoning process, and thinking mode would inflate output token counts and complicate scoring (see §4.4 exclusion rationale for reasoning models).

### 4.7 Run Protocol

Each (site, question, model, condition) tuple is run **exactly once**. At temperature 0 with a fixed seed, the output is deterministic — running the same input through the same model produces the same output. Multiple runs would produce identical results and waste compute time.

**Total experiment scale:**

```
286 questions × 2 conditions × 10 models = 5,720 inference runs
```

**Estimated wall-clock time:**

Inference speed varies by model size. Conservative estimates based on published Apple Silicon benchmarks for Q8_0 GGUF models:

| Tier | Models | Avg. Tokens/sec (generation) | Avg. Response Time (est.) | Subtotal Runs | Subtotal Time |
|------|--------|------------------------------|--------------------------|---------------|---------------|
| Small (4-8B) | 3 | ~60-80 tok/s | ~5-10 sec | 1,716 | ~3-5 hours |
| Medium (12-27B) | 3 | ~30-50 tok/s | ~10-20 sec | 1,716 | ~5-10 hours |
| Large (27-123B) | 4 | ~10-25 tok/s | ~20-60 sec | 2,288 | ~13-38 hours |
| **Total** | **10** | | | **5,720** | **~21-53 hours** |

The total estimated range of 21-53 hours is well within a single weekend of continuous operation on the Mac Studio. Model loading time (loading the GGUF file into memory) adds overhead between models but not between runs of the same model — the data collection runner processes all questions for a given model before loading the next one.

**Run ordering:**

The data collection runner processes models sequentially (one model loaded at a time) but interleaves conditions within each model's run. For each loaded model, the runner iterates through all 286 questions, and for each question, runs both Condition A and Condition B back-to-back before moving to the next question. This ordering:

1. Minimizes model loading overhead (each model is loaded once).
2. Keeps paired comparisons temporally adjacent (reducing the chance that transient system state affects one condition differently than the other).
3. Produces a natural checkpoint granularity — if the run is interrupted, it can resume from the last completed model.

**Warm-up:** Before recording data for each newly loaded model, the runner sends 3 warm-up prompts (not recorded in results) to stabilize inference speed. The first few inferences after loading a model can be slower due to KV cache initialization and memory paging.

---

## 6. Statistical Analysis Plan

> **Traces To:** Story 4.1, Phase 2 (analysis notebook)
> **Created:** 2026-02-26
> **Last Updated:** 2026-02-26
> **Implemented In:** `results/analysis.ipynb` (Sections 2–8)

This section pre-registers the statistical tests, effect size measures, correction procedures, and decision criteria that the analysis notebook applies to the raw experimental data. Every test described here is specified before data collection begins, eliminating the temptation to shop for tests that produce favorable results after the fact.

The study's experimental design is a **within-subjects paired comparison**: for each (site, question, model) triple, two responses exist — one from Condition A (HTML-derived content) and one from Condition B (llms.txt Markdown). The paired structure allows each question to serve as its own control, with the condition as the sole independent variable. All scoring is performed under the blinding protocol defined in `corpus/scoring-rubric.md` §7 — the scorer does not know which condition produced a given response at the time of scoring, and condition labels are assigned only after all scoring is complete.

### 6.1 Hypotheses

The following hypotheses are stated directionally where prior reasoning supports a direction, and two-tailed where the direction is genuinely uncertain. All hypotheses are tested at **α = 0.05**.

**Primary hypotheses (tested on the full dataset):**

| ID | Hypothesis | Direction | Metric | Rationale |
|----|-----------|-----------|--------|-----------|
| H1 | Condition B produces higher factual accuracy scores than Condition A | One-tailed (B > A) | Factual Accuracy (0-3) | Cleaner, curated Markdown should reduce noise that causes the model to misinterpret or miss facts |
| H2 | Condition B produces fewer hallucinations per response than Condition A | One-tailed (B < A) | Hallucination Rate (count) | Noisy HTML-derived content provides more surface for the model to confabulate from irrelevant text fragments |
| H3 | Condition B requires fewer input tokens than Condition A | One-tailed (B < A) | Token Efficiency (input tokens) | llms.txt-linked Markdown excludes navigation chrome, boilerplate, and non-content markup by design |

**Secondary hypotheses (exploratory, tested on subgroups):**

| ID | Hypothesis | Direction | Subgroup | Rationale |
|----|-----------|-----------|----------|-----------|
| H4 | The accuracy improvement from Condition B is larger for small models than for large models | One-tailed (interaction) | By capability tier (§4.3) | Smaller models have less capacity to filter input noise internally; cleaner input compensates for this limitation |
| H5 | The accuracy improvement is larger for multi-section-synthesis and conceptual-relationship questions than for single-fact questions | One-tailed (interaction) | By complexity level (§3.1) | Complex questions require integrating more content; reducing noise in that content has a proportionally larger effect |
| H6 | Condition B produces equal or higher completeness than Condition A | Two-tailed | Full dataset | No strong prior — llms.txt Markdown could omit content present in the HTML version, reducing completeness |

### 6.2 Primary Statistical Tests

The test for each metric is selected based on the metric's scale type and the paired structure of the data. Non-parametric tests are preferred because ordinal metrics (factual accuracy, citation fidelity) violate the interval-scale assumption required by parametric tests, and hallucination counts are unlikely to be normally distributed.

**Test selection by metric:**

| Metric | Scale | Test | Justification |
|--------|-------|------|---------------|
| Factual Accuracy | 0-3 ordinal | **Wilcoxon signed-rank test** | Non-parametric paired test for ordinal data. Does not assume normality or equal intervals between scale points. Tests whether the distribution of paired differences is symmetric around zero. |
| Hallucination Rate | Count (≥0) | **Wilcoxon signed-rank test** | Count data is discrete and typically right-skewed (many zeros, occasional high counts). Wilcoxon handles this without distributional assumptions. |
| Token Efficiency | Continuous (integer token counts) | **Paired t-test** with normality check | Token counts are continuous and likely approximately normal across 286 pairs. If the Shapiro-Wilk test rejects normality at α = 0.05, fall back to Wilcoxon signed-rank. |
| Completeness | Binary (0/1) | **McNemar's test** | Standard test for paired binary outcomes. Tests whether the proportion of discordant pairs (A=complete, B=incomplete vs. A=incomplete, B=complete) differs significantly from 50/50. |
| Citation Fidelity | 0-2 ordinal | **Wilcoxon signed-rank test** | Same rationale as factual accuracy. Applied only to the subset of responses where citation fidelity is applicable (not N/A). |

**Pairing structure:**

Each statistical test operates on **paired differences**. For the Wilcoxon tests, the paired difference for each (site, question, model) triple is:

```
Δ = score(Condition B) − score(Condition A)
```

For token efficiency, the direction is reversed because lower is better:

```
Δ_tokens = tokens(Condition A) − tokens(Condition B)
```

A positive Δ indicates Condition B outperformed Condition A on the given metric.

**Sample size:**

With 286 questions × 10 models = 2,860 paired observations per metric, the study has substantial statistical power. Even modest effects should be detectable. However, the pairs are not fully independent — questions within the same site share content characteristics, and responses from the same model share capability limitations. §6.5 addresses this clustering.

### 6.3 Effect Size Measures

Statistical significance alone is insufficient — a p-value tells you whether an effect exists, not whether it matters. Each primary metric reports an effect size measure alongside the test result.

| Metric | Effect Size Measure | Interpretation Scale | Why This Measure |
|--------|--------------------|--------------------|------------------|
| Factual Accuracy | **Cliff's delta (δ)** | negligible (<0.147), small (0.147-0.33), medium (0.33-0.474), large (>0.474) | Non-parametric effect size for ordinal paired data. Represents the probability that a randomly selected Condition B score exceeds a randomly selected Condition A score, minus the reverse probability. |
| Hallucination Rate | **Cliff's delta (δ)** | Same as above | Count data is treated as ordinal for effect size purposes. |
| Token Efficiency | **Cohen's d (paired)** | negligible (<0.2), small (0.2-0.5), medium (0.5-0.8), large (>0.8) | Continuous data with approximately normal differences supports the parametric effect size. If normality fails, report Cliff's delta instead. |
| Completeness | **Odds ratio** from McNemar's test | Reported as OR with 95% CI | Natural effect size for paired binary data. An OR of 2.0 means Condition B is twice as likely to be complete when conditions disagree. |
| Citation Fidelity | **Cliff's delta (δ)** | Same as factual accuracy | Ordinal data, same rationale. |

**Reporting format:**

Every primary test result is reported as: test statistic, p-value, effect size with 95% confidence interval, and sample size (n pairs). For example:

> Wilcoxon signed-rank: W = 1,234, p = 0.003, Cliff's δ = 0.28 [0.15, 0.41], n = 2,860 pairs

### 6.4 Multiple Comparisons Correction

The study tests multiple hypotheses across multiple metrics and subgroups. Without correction, the probability of at least one false positive increases with each test.

**Correction strategy: Benjamini-Hochberg (BH) procedure for false discovery rate (FDR) control at q = 0.05.**

Benjamini-Hochberg is preferred over Bonferroni because:

1. Bonferroni is overly conservative when tests are correlated (as ours are — all metrics are measured on the same responses, and subgroup tests overlap with the full-dataset tests).
2. BH controls the expected proportion of false discoveries among rejected hypotheses, which is more useful than controlling the family-wise error rate when the goal is to identify which effects are real rather than to avoid any single false alarm.
3. The study's 6 primary and secondary hypotheses plus ~15-20 subgroup tests constitute a moderate testing burden — BH handles this well without sacrificing too much power.

**Correction groups:**

Tests are corrected within groups, not across all tests globally:

| Group | Tests Included | Rationale |
|-------|---------------|-----------|
| **Primary hypotheses** | H1, H2, H3 (3 tests) | These are the headline findings; corrected together |
| **Subgroup: by model tier** | H4 + per-tier accuracy tests (3 tiers × 3 primary metrics = 9 tests) | Related comparisons sharing the same data partition |
| **Subgroup: by complexity** | H5 + per-complexity accuracy tests (3 complexity levels × 3 primary metrics = 9 tests) | Same rationale |
| **Secondary metrics** | H6 + completeness + citation fidelity tests (3 tests) | Lower-priority metrics, corrected within their own group |

**Reporting:** Both raw p-values and BH-adjusted p-values are reported for every test. The write-up discusses results in terms of adjusted p-values, while the analysis notebook makes raw values available for readers who prefer different correction methods. Effect sizes and their confidence intervals are **not** adjusted by the multiple comparisons procedure — only p-values are corrected. This follows standard practice: effect sizes describe the magnitude of an observed difference, which is independent of the number of tests conducted.

### 6.5 Clustering and Non-Independence

The 2,860 paired observations are not fully independent. Two sources of clustering exist:

1. **Within-site clustering:** Questions from the same site share the same source content, so their responses are correlated. Site S001 (Stripe) has 8 questions; the model's performance on Q01 is not independent of its performance on Q02 because both draw from the same documentation.

2. **Within-model clustering:** Responses from the same model share capability characteristics. If Llama 3.3 8B struggles with noisy input, it will likely struggle across many questions, producing correlated Δ values.

**Approach: Two-level analysis.**

- **Primary tests (§6.2)** treat each (site, question, model) triple as one observation. This maximizes statistical power and produces the headline p-values. The tests are valid under the assumption that paired differences are exchangeable — a weaker assumption than full independence.
- **Robustness check: Site-level aggregation.** For each (site, model) pair, compute the mean Δ across questions for that site. Then run the Wilcoxon test on these site-level means (37 sites × 10 models = 370 pairs). If the site-level test confirms the observation-level result, the finding is robust to within-site clustering.
- **Robustness check: Model-level aggregation.** For each model, compute the mean Δ across all questions. This produces 10 data points (one per model) — too few for a formal test, but sufficient for a descriptive "does every model show the same direction of effect?" summary.

Both robustness checks are reported in the analysis notebook alongside the primary tests. If the site-level or model-level checks diverge from the primary results, the write-up discusses the discrepancy and its implications.

### 6.6 Subgroup Analyses

Two planned subgroup analyses decompose the primary effects along dimensions specified in the hypotheses.

**Subgroup 1: By model capability tier (H4)**

Partition the data into three groups by §4.3 tier assignment (Small: 4-8B, Medium: 12-27B, Large: 27-123B). Run the primary tests (§6.2) within each tier. Then test for an interaction: is the effect size in the Small tier significantly larger than in the Large tier?

The interaction is tested by computing Δ for each (site, question) pair within each tier, then comparing the distribution of Δ values between tiers using a Kruskal-Wallis test (non-parametric one-way ANOVA). If significant, follow up with pairwise Mann-Whitney U tests between tiers.

**Subgroup 2: By question complexity (H5)**

Partition the data into three groups by §3.1 complexity level (single-fact, multi-section-synthesis, conceptual-relationship). Run the primary tests within each complexity group. Test for an interaction using the same Kruskal-Wallis → Mann-Whitney procedure.

**Subgroup 3: By sector (exploratory)**

Partition by §1.3 sector taxonomy. This is exploratory — no directional hypothesis is pre-registered. The analysis reports per-sector effect sizes to identify whether certain content types (e.g., developer documentation vs. SaaS product docs) show systematically different effects. Given the uneven sector distribution (developer tools at 30%), this analysis is descriptive rather than inferential.

### 6.7 Token-Quality Correlation Analysis

A key question beyond the paired comparisons is whether the magnitude of token reduction predicts the magnitude of quality improvement. This is tested with a correlation analysis:

For each (site, question, model) triple, compute:

- `Δ_tokens` = tokens(Condition A) − tokens(Condition B)
- `Δ_accuracy` = accuracy(Condition B) − accuracy(Condition A)

Then compute **Spearman's rank correlation** between Δ_tokens and Δ_accuracy across all triples. Spearman's is appropriate because both variables may be non-linear and Δ_accuracy is ordinal.

**Interpretation:**

- A significant positive correlation (larger token savings → larger accuracy gains) would suggest that the llms.txt benefit is driven by noise reduction, and sites with more HTML bloat benefit most.
- A non-significant correlation would suggest that the benefit (if any) is driven by content curation quality rather than mere size reduction — the Markdown is better organized, not just shorter.
- A significant negative correlation (larger token savings → smaller accuracy gains) would be surprising but could indicate that aggressive content pruning in llms.txt actually removes useful context.

This analysis is reported as Figure 4 in the analysis notebook (scatter plot of Δ_tokens vs. Δ_accuracy with regression line and Spearman's ρ).

### 6.8 Freshness Analysis

For sites where both the HTML page and the llms.txt-linked Markdown have `Last-Modified` headers recorded in the archive manifest (§2.1), compute the staleness delta:

```
staleness_days = Last-Modified(HTML) − Last-Modified(Markdown)
```

A positive value means the Markdown is older (staler) than the HTML. Correlate `staleness_days` with `Δ_accuracy` using Spearman's rank correlation to test whether stale Markdown degrades the benefit.

This is a secondary analysis (no pre-registered hypothesis) but addresses a practical concern: if organizations let their llms.txt-linked content go stale, does it eventually hurt more than it helps?

### 6.9 Analysis Software and Reproducibility

All statistical tests are implemented in the analysis notebook (`results/analysis.ipynb`) using standard Python libraries:

| Library | Version | Use |
|---------|---------|-----|
| `pandas` | ≥2.0 | Data loading, manipulation, aggregation |
| `scipy.stats` | ≥1.11 | Wilcoxon signed-rank, paired t-test, McNemar's, Kruskal-Wallis, Mann-Whitney U, Shapiro-Wilk |
| `statsmodels` | ≥0.14 | Benjamini-Hochberg correction (`multipletests`), confidence intervals |
| `matplotlib` / `seaborn` | ≥3.8 / ≥0.13 | All figures |
| `numpy` | ≥1.25 | Cliff's delta computation, numerical operations |

**Cliff's delta implementation:**

Cliff's delta is not built into scipy. It is computed directly as:

```python
def cliffs_delta(x, y):
    """Cliff's delta for paired ordinal data."""
    n = len(x)
    dominance = sum(1 if xi > yi else -1 if xi < yi else 0 for xi, yi in zip(x, y))
    return dominance / n
```

The 95% confidence interval is computed via bootstrap (10,000 resamples with replacement, percentile method). The implementation is included in the notebook's utility cell and verified against known test cases.

**Reproducibility:** The notebook includes a `requirements.txt` cell that pins exact library versions. All random operations (bootstrap resampling) use `numpy.random.seed(42)` for determinism. The notebook is tested on Google Colab to verify that it runs without modification on a free-tier instance.

### 6.10 Decision Criteria and Interpretation Guide

To prevent post-hoc rationalization, the following interpretation framework is committed to before data collection:

| Outcome | Interpretation | Implication for llms.txt |
|---------|---------------|--------------------------|
| H1 significant, medium+ effect | llms.txt Markdown produces meaningfully better factual responses | Strong practical case for llms.txt adoption |
| H1 significant, small effect | Statistically detectable improvement but practically marginal | llms.txt helps, but the benefit may not justify the maintenance cost for all organizations |
| H1 not significant | No detectable accuracy difference between conditions | Modern LLMs handle HTML-derived content effectively; llms.txt does not measurably improve factual accuracy |
| H3 significant (as expected) | llms.txt content is measurably smaller in tokens | Confirms the theoretical basis (less noise) but token savings alone don't justify adoption unless quality metrics also improve |
| H4 significant (interaction) | Small models benefit more from llms.txt than large models | Suggests llms.txt is most valuable when deploying smaller, cheaper models — relevant for cost-sensitive applications |
| H5 significant (interaction) | Complex questions benefit more | Suggests llms.txt's value scales with task difficulty — relevant for sophisticated AI applications |
| Δ_tokens correlates with Δ_accuracy | Token reduction predicts quality gain | The mechanism is noise removal; sites with more HTML bloat benefit most |
| Δ_tokens does NOT correlate with Δ_accuracy | Token reduction does not predict quality gain | The mechanism is content curation quality, not just size reduction |

**What the study does not test:** This framework addresses only the *empirical* question ("does it help?"), not the *economic* question ("is it worth the effort?") or the *strategic* question ("should providers adopt it?"). Those questions require additional data about maintenance costs, content drift rates, and platform integration feasibility that are outside the scope of this study.

---

## 7. Limitations and Threats to Validity

> **Traces To:** Story 4.1 (methodology documentation)
> **Created:** 2026-02-26
> **Last Updated:** 2026-02-26

Every experimental design involves trade-offs. This section documents the study's known limitations, categorized by the standard validity taxonomy: internal validity (did the treatment cause the observed effect?), external validity (does the finding generalize?), construct validity (are we measuring what we claim to measure?), and statistical conclusion validity (are the statistical inferences sound?). Each limitation includes the design decision that produced it, the potential impact on results, and any mitigation already built into the methodology.

Pre-registering limitations before data collection is not a confession of weakness — it is a commitment to honesty. A study that acknowledges its constraints is more credible than one that pretends it has none.

### 7.1 Internal Validity

Internal validity asks whether the observed difference between Condition A and Condition B is actually caused by the format difference, or by some confounding variable.

**L-IV-1. Content asymmetry between conditions.**

Condition A (HTML readability extraction) and Condition B (llms.txt Markdown with XML wrapping) do not just differ in format — they may differ in *content*. The readability extractor may strip tables, code blocks, or navigation elements that happen to contain relevant information. Conversely, the llms.txt-linked Markdown may be a curated subset that omits content present in the HTML documentation. Any observed quality difference could be partially attributable to information availability rather than format clarity.

*Design decision:* §2.2 and §2.3 specify per-question scoping (§2.4) to align the content as closely as possible, but perfect alignment is impossible because the two pipelines start from different source material. *Mitigation:* The content archiving protocol (§2.1) preserves both raw inputs for post-hoc analysis. The analysis notebook can compare character counts and keyword overlap between conditions to quantify the information asymmetry. If the asymmetry is large for specific sites, those sites can be flagged in the write-up.

**L-IV-2. SmartReader extraction quality varies by site.**

The readability extraction library (SmartReader, §2.2) applies a general-purpose heuristic to identify the "main content" region of an HTML page. This heuristic works well for blog-style layouts but can fail on complex documentation sites with tabbed navigation, multi-pane layouts, or heavily JavaScript-rendered content. When SmartReader degrades, Condition A looks artificially bad — not because HTML documentation is inherently worse for LLMs, but because the extraction pipeline failed.

*Design decision:* §2.2 chose SmartReader over custom per-site extraction to maintain a realistic pipeline that reflects what production RAG systems actually use. *Mitigation:* The retrieval failure protocol (§2.5) drops tuples where extraction produces fewer than 50 characters, which catches complete failures. Near-failures (SmartReader returns content but misses a critical section) are harder to detect automatically. The write-up should note that Condition A's performance is an upper bound on HTML extraction quality — a better extractor would narrow the gap, and the study measures the *current* state of HTML-to-text pipelines, not the theoretical best case.

**L-IV-3. XML wrapping in Condition B introduces structural cues.**

Condition B wraps content in `<project>/<section>/<doc>` XML tags (§2.3), which provide structural information absent from Condition A's plain text output. Models trained on XML-structured context (notably Claude, but potentially others through instruction-tuning on XML-heavy datasets) may benefit from these tags independently of the Markdown content quality. The observed effect could partially reflect "XML structure helps models organize information" rather than "llms.txt Markdown is better than HTML-derived text."

*Design decision:* §2.3 replicates the reference implementation's output format for ecological validity — this is how llms.txt content is actually consumed. *Mitigation:* This is an inherent limitation of testing the llms.txt *system* (spec + implementation + consumption format) rather than isolating the Markdown content alone. The write-up should frame the comparison as "the llms.txt pipeline vs. the HTML extraction pipeline," not "Markdown vs. HTML." A follow-up study could test Condition B with and without XML wrapping to isolate the structural contribution.

**L-IV-4. Prompt template may not be neutral.**

The standardized prompt (§2.4) uses the label "Content:" for both conditions. However, Condition A inserts plain text while Condition B inserts XML-structured Markdown. If models have been fine-tuned to expect XML context blocks (as Claude has), the prompt may inadvertently favor Condition B by aligning with that training distribution.

*Mitigation:* The prompt deliberately avoids condition-specific language ("this is Markdown" or "this is HTML"). The system prompt instructs the model to answer from "the provided documentation content" without format hints. This is the most neutral framing available, but complete neutrality is unachievable when the content itself reveals its format.

### 7.2 External Validity

External validity asks whether the findings generalize beyond the specific conditions of this study.

**L-EV-1. Corpus is skewed toward developer documentation.**

The sector distribution analysis (§1.3) documents that 30% of the corpus is developer tools and APIs, and the broader technology sector accounts for the majority of sites. This reflects the real-world adoption landscape — llms.txt was designed by and for the developer community — but it means the study's findings may not generalize to non-technical content domains.

*Impact:* If llms.txt performs well on developer documentation but poorly on, say, healthcare or government content, the aggregate result would overstate the benefit for non-technical domains that might adopt the standard in the future. *Mitigation:* The per-sector subgroup analysis (§6.6, Subgroup 3) reports effect sizes separately by sector. Readers evaluating llms.txt for non-tech applications should weight the sector-specific findings rather than the aggregate.

**L-EV-2. Local open-weights models may not predict proprietary model behavior.**

The study uses 10 local open-weights models (§4.3) served via Ollama/LM Studio. The most widely used LLMs in production — GPT-4o, Claude 3.5 Sonnet, Gemini 1.5 Pro — are proprietary cloud services with undisclosed architectures, context window management, and system prompts. The llms.txt effect observed on Llama 3.3 70B may not transfer to GPT-4o.

*Design decision:* §4.1 chose local inference for experimental control (deterministic parameters, no server-side processing). *Impact:* Proprietary models generally perform better than comparably-sized open models, so the "larger models benefit less" finding (if observed via H4) might mean proprietary models benefit even less — or their superior instruction-following might cause them to benefit more. The direction is genuinely uncertain. *Mitigation:* The study explicitly scopes its claims to open-weights models. The write-up should note that a cloud-API replication study would be valuable but introduces confounds this study was designed to avoid.

**L-EV-3. Q8_0 quantization may not represent typical deployment.**

All models are tested at Q8_0 quantization (§4.5), which is near-lossless. In practice, many users deploy models at Q4_K_M or lower to fit on consumer hardware. Lower quantization degrades model capability, which could amplify the llms.txt effect (weaker models benefit more from cleaner input) or dampen it (if quantization noise overwhelms the format signal).

*Impact:* The study's effect sizes represent an optimistic estimate of model capability at each parameter count. Real-world deployments at lower quantization may see different magnitudes. *Mitigation:* Documenting the quantization level precisely (§4.5) allows replication studies to test at different quantization points. The capability-tier analysis (§6.6, Subgroup 1) provides indirect evidence — if smaller models at Q8_0 benefit more, even smaller effective models at Q4_K_M would likely benefit more still.

**L-EV-4. English-only study.**

The corpus is restricted to English-language content (IC-4 in §1.1). Tokenization efficiency, extraction quality, and model capability all vary across languages. Languages with logographic scripts (Chinese, Japanese) interact differently with BPE tokenizers, and HTML boilerplate patterns differ across language communities.

*Mitigation:* The study scopes its claims to English documentation. A multilingual extension would be valuable but requires careful attention to tokenizer selection, gold-standard answer authoring in each language, and scorer qualification.

**L-EV-5. Single hardware configuration.**

All inference runs on a single Mac Studio M3 Ultra (§4.1). Apple Silicon's unified memory architecture and Metal GPU acceleration produce different performance characteristics than NVIDIA CUDA GPUs. While the inference outputs should be identical (same model weights, same parameters), timing data and any edge cases related to memory management or numerical precision could differ on other hardware.

*Mitigation:* The study's primary metrics (accuracy, hallucination, completeness, citation fidelity) are scored on response content, not timing. Token efficiency is a function of the content and tokenizer, not the hardware. The hardware dependency is relevant only to reproducibility of exact timing benchmarks reported in §4.7, not to the quality findings.

### 7.3 Construct Validity

Construct validity asks whether the metrics actually measure what we claim they measure.

**L-CV-1. Factual accuracy scale conflates precision with completeness.**

The 0–3 factual accuracy scale (scoring rubric §2) captures a blend of correctness and thoroughness. A response that contains one correct fact and nothing else scores differently from one that contains three correct facts and one wrong one, but the scale doesn't cleanly separate these dimensions. The completeness metric (scoring rubric §5) partially addresses this, but the two metrics are correlated by construction.

*Mitigation:* The scoring rubric's decision rules and worked examples (§2 of `scoring-rubric.md`) provide detailed guidance on how to handle mixed-quality responses. The 10 pre-populated edge case precedents (§9 of `scoring-rubric.md`) reduce ambiguity for common borderline scenarios. Acknowledging the correlation, the statistical analysis (§6) treats factual accuracy and completeness as separate metrics with separate tests rather than combining them.

**L-CV-2. Hallucination counting is subjective at the margins.**

The hallucination categories (H-FAB, H-SRC, H-EXT, H-TMP in scoring rubric §3) are well-defined at the extremes: a model inventing a nonexistent API endpoint is clearly H-FAB, while rephrasing source material is clearly not a hallucination. But the boundary between reasonable inference (not a hallucination) and extrapolation-as-fact (H-EXT) depends on the scorer's judgment. Two scorers might disagree on whether "this API supports authentication" is a reasonable inference from documentation that describes an API key header but never uses the word "authentication."

*Mitigation:* The hallucination-details.json companion format (scoring rubric §8) records the specific text span and category for every counted hallucination, creating a full audit trail. The inter-rater reliability protocol (scoring rubric §6) measures Cohen's weighted kappa specifically on hallucination counts. If kappa falls below 0.6, the write-up reports the disagreement and discusses its impact.

**L-CV-3. Token efficiency measures input size, not processing difficulty.**

The token efficiency metric (§2.6) counts how many input tokens each condition requires. Fewer tokens is framed as "more efficient," but this conflates size with quality. A 500-token Condition B input that omits a critical paragraph is more "efficient" than a 1,200-token Condition A input that includes it — but the shorter input is worse. Token efficiency is meaningful only in conjunction with accuracy: if both conditions produce equal accuracy, fewer tokens is genuinely better. If the shorter condition is also less accurate, the "efficiency" gain is misleading.

*Mitigation:* §6.7 (Token-Quality Correlation) directly tests whether token savings predict quality gains. If the correlation is negative or absent, the write-up must be careful not to cite token efficiency as an independent benefit. The interpretation guide (§6.10) pre-registers that token savings "alone don't justify adoption unless quality metrics also improve."

### 7.4 Statistical Conclusion Validity

Statistical conclusion validity asks whether the statistical inferences are sound.

**L-SC-1. Single-rater scoring.**

All 5,720 responses (or more precisely, all non-excluded tuples) are scored by a single researcher. Scorer drift (gradual changes in scoring standards over a multi-day scoring session), scorer fatigue, and individual bias are uncontrolled.

*Design decision:* The study is conducted by a solo researcher without budget for additional raters. *Mitigation:* The blinding protocol (scoring rubric §7) prevents the scorer from knowing which condition produced a response, which controls for directional bias (e.g., unconsciously favoring Condition B). Randomized scoring order across conditions further reduces order effects. The inter-rater reliability protocol (scoring rubric §6) specifies that a 10-15% subset should be rescored by a second rater if available — but this is aspirational. If single-rater only, the write-up explicitly acknowledges this as the study's most significant threat to scoring reliability and recommends multi-rater replication.

**L-SC-2. Non-independence of observations.**

As discussed in §6.5, the 2,860 paired observations cluster by site and by model. The primary Wilcoxon tests treat all observations as exchangeable pairs, which may understate standard errors and overstate significance. If 8 questions from the same site all show the same direction of effect, this represents more like 1 independent observation than 8.

*Mitigation:* The two-level robustness checks (§6.5) — site-level aggregation (370 pairs) and model-level aggregation (10 points) — test whether the primary result survives when clustering is explicitly accounted for. If the primary test is significant but the site-level test is not, the write-up reports the primary result as potentially inflated by within-site correlation.

**L-SC-3. Multiple comparisons increase false positive risk.**

The study conducts approximately 24 statistical tests across primary hypotheses, subgroup analyses, and exploratory analyses. At α = 0.05 without correction, the expected number of false positives is ~1.2 tests.

*Mitigation:* §6.4 specifies Benjamini-Hochberg FDR correction at q = 0.05, grouped by analysis family. This controls the expected proportion of false discoveries among significant results. Exploratory analyses (per-sector breakdown, freshness correlation) are clearly labeled as exploratory and their p-values are interpreted with appropriate caution.

**L-SC-4. Effect sizes may be inflated by the measurement instrument.**

Cliff's delta (§6.3) measures the probability that a Condition B score exceeds a Condition A score. On a 4-point ordinal scale (0–3), a systematic 1-point improvement across all pairs produces a Cliff's delta of 1.0 (the maximum). This is technically correct but potentially misleading — a 1-point improvement on a 4-point scale sounds large as "delta = 1.0" but is more modest than it appears. The scale's coarseness amplifies measured effect sizes.

*Mitigation:* The write-up reports effect sizes alongside the raw score distributions (medians, interquartile ranges, frequency tables at each scale point) so readers can judge practical significance from the data, not just from the effect size statistic. The interpretation guide (§6.10) frames results in terms of concrete score improvements ("Condition B scored 3 where Condition A scored 2 in X% of pairs") rather than relying solely on effect size labels.

### 7.5 Study-Level Limitations

These limitations apply to the study as a whole rather than to a specific validity category.

**L-SL-1. Point-in-time snapshot.**

Both the llms.txt content and the HTML documentation are archived at a single point in time (§2.1). Websites update their documentation continuously. The study measures the state of these sites during the archival window, not their state at any other time. If a site updates its llms.txt Markdown to fix errors one week after archiving, the study uses the pre-fix version. Conversely, if a site's HTML documentation degrades after archiving, the study does not reflect that degradation.

*Mitigation:* The archival manifest records exact timestamps and content hashes for every page. The freshness analysis (§6.8) tests whether content age correlates with accuracy, providing indirect evidence about temporal sensitivity.

**L-SL-2. No longitudinal dimension.**

The study is a cross-sectional comparison, not a longitudinal study of how llms.txt content quality evolves over time. The "maintenance burden" argument — that llms.txt files go stale faster than HTML documentation — is not empirically tested. The freshness analysis (§6.8) provides a one-time snapshot of relative staleness but cannot measure drift rates.

*Mitigation:* The write-up should explicitly note that maintenance sustainability is a critical open question that this study does not address. A follow-up study could re-archive the same corpus 6-12 months later and measure content drift.

**L-SL-3. Researcher familiarity with the llms.txt ecosystem.**

The primary researcher is a contributor to the llms.txt ecosystem (through the LlmsTxtKit and DocStratum projects). While the self-authored content exclusion (EC-5 in §1.2) prevents scoring bias from familiarity with the test sites themselves, the researcher's domain expertise and investment in the ecosystem may introduce unconscious bias in study design — for instance, in how questions are framed (favoring question types where llms.txt excels) or how gold-standard answers are authored (drawing on knowledge of how llms.txt organizes content).

*Mitigation:* The docs-first methodology and pre-registration of hypotheses, tests, and interpretation criteria (§6.1, §6.10) constrain the researcher's degrees of freedom after data collection. The blinding protocol prevents condition knowledge from affecting scoring. The gold-standard answers are sourced directly from site content with documented verification dates. Full transparency about the researcher's ecosystem involvement allows readers to assess potential bias independently.

**L-SL-4. The study tests the best case for llms.txt.**

The corpus selection criteria (§1.1) require sites with well-formed llms.txt files linking to substantive Markdown content. Sites with broken, minimal, or poorly maintained llms.txt files are excluded. This means the study tests "does a good llms.txt help?" — not "does the average llms.txt help?" The real-world distribution of llms.txt quality is likely worse than the corpus average, which means the study's effect sizes may overestimate the benefit of llms.txt adoption in general.

*Mitigation:* This is explicitly documented in the exclusion criteria rationale (EC-1). The write-up should frame the findings as "the benefit of well-maintained llms.txt files" and note that the population-level benefit depends on adoption quality, which is outside the study's scope.

---

<!-- TODO: Write remaining methodology sections. Sections to include:

  2. Content Pair Generation — COMPLETE (2026-02-25)
     - §2.1 Content Archiving: Pre-fetch archive with manifest.json, immutable after creation
     - §2.2 Condition A: SmartReader readability extraction from HTML
     - §2.3 Condition B: Reference implementation create_ctx() replication with XML wrapping
     - §2.4 Content Assembly: Per-question scoping using source_urls, standardized prompt template
     - §2.5 Retrieval Failure Handling: Drop-and-document protocol, S032/UBC known issue
     - §2.6 Tokenization: Per-model-family + Llama 3 reference tokenizer, three-level analysis framework

  4. Model Selection — COMPLETE (2026-02-25)
     - §4.1 Hardware and Inference Platform: Mac Studio M3 Ultra 512GB, Ollama/LM Studio
     - §4.2 Model Families: Llama 3.3, Qwen 3, Gemma 3, Mistral (4 families)
     - §4.3 Model Matrix: 10 models across 3 capability tiers (Small/Medium/Large)
     - §4.4 Excluded Models: MoE, reasoning/thinking, cloud-only, specialized, <4B
     - §4.5 Quantization: Q8_0 fixed across all models (~+0.0004 perplexity vs FP16)
     - §4.6 Inference Parameters: temperature=0, seed=42, deterministic greedy decoding
     - §4.7 Run Protocol: Single run per tuple, 5,720 total runs, ~21-53 hours estimated

  5. Scoring Protocol — COMPLETE, see corpus/scoring-rubric.md (v2, refined 2026-02-25)
     - Factual accuracy (0–3 scale) with worked examples from actual corpus Q+A pairs
     - Complexity-specific scoring guidance for single-fact, synthesis, and relationship questions
     - Hallucination counting with H-FAB/H-SRC/H-EXT/H-TMP categories and text span recording
     - Completeness with complexity-aware guidance
     - Citation fidelity (0–2 ordinal) with applicability rules
     - Inter-rater reliability protocol (Cohen's weighted kappa ≥ 0.6 threshold)
     - 10 pre-populated edge case precedents (EC-01 through EC-10)
     - Scoring automation opportunities for high-volume response sets
     - Companion hallucination-details.json for full audit trail

  6. Statistical Analysis Plan — COMPLETE (2026-02-26)
     - §6.1 Hypotheses: 3 primary (H1-H3, directional) + 3 secondary (H4-H6, subgroup/exploratory)
     - §6.2 Primary Tests: Wilcoxon signed-rank (ordinal/count), paired t-test (continuous), McNemar's (binary)
     - §6.3 Effect Sizes: Cliff's delta (ordinal), Cohen's d (continuous), odds ratio (binary), all with 95% CI
     - §6.4 Multiple Comparisons: Benjamini-Hochberg FDR correction at q=0.05, grouped by analysis family
     - §6.5 Clustering: Two-level analysis with site-level and model-level robustness checks
     - §6.6 Subgroup Analyses: By model tier, by complexity, by sector (exploratory)
     - §6.7 Token-Quality Correlation: Spearman's ρ between Δ_tokens and Δ_accuracy
     - §6.8 Freshness Analysis: Staleness delta vs. accuracy delta correlation
     - §6.9 Software: scipy, statsmodels, pandas; Cliff's delta implemented directly; Colab-verified
     - §6.10 Decision Criteria: Pre-registered interpretation framework for each outcome scenario

  7. Limitations and Threats to Validity — COMPLETE (2026-02-26)
     - §7.1 Internal Validity: Content asymmetry (L-IV-1), SmartReader variability (L-IV-2), XML wrapping confound (L-IV-3), prompt neutrality (L-IV-4)
     - §7.2 External Validity: Sector skew (L-EV-1), proprietary model generalization (L-EV-2), Q8_0 deployment gap (L-EV-3), English-only (L-EV-4), single hardware (L-EV-5)
     - §7.3 Construct Validity: Accuracy scale conflation (L-CV-1), hallucination subjectivity (L-CV-2), token efficiency interpretation (L-CV-3)
     - §7.4 Statistical Conclusion Validity: Single-rater (L-SC-1), non-independence (L-SC-2), multiple comparisons (L-SC-3), effect size inflation (L-SC-4)
     - §7.5 Study-Level: Point-in-time snapshot (L-SL-1), no longitudinal dimension (L-SL-2), researcher familiarity (L-SL-3), best-case corpus (L-SL-4)

  ALL SECTIONS COMPLETE. Methodology document finalized 2026-02-26.
-->
