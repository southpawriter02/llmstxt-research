# llms.txt Research & Tooling Initiative — Project Management Blueprint

**Author:** Ryan (with Claude)
**Version:** 2.0
**Created:** February 14, 2026
**Last Updated:** February 14, 2026
**Status:** Proposal — Pending Review
**Scope:** GitHub Project structure, lane-based epic/story/task breakdown, dependency mapping, and acceptance criteria for the full llms.txt research initiative across all repositories.

---

## Purpose

This document defines the **operational layer** for the llms.txt Research & Tooling Initiative — the structured breakdown of what needs to be done, in what order, and how progress is tracked. It bridges the gap between the existing design documentation (proposals, specs, roadmaps) and the day-to-day work of building, writing, and publishing.

The initiative has two navigational documents that work together:

- **The Lane-Based Roadmap** (`llmstxt-lane-roadmap.docx`) — A high-level orientation guide that separates the initiative into six mentally containable lanes. Use it when you need to see the big picture, identify what's parallelizable, or figure out where to focus next.
- **This Blueprint** — The detailed operational document that decomposes each lane into trackable epics, stories, and tasks with acceptance criteria, dependencies, and point estimates. Use it when you need to know exactly what a work item entails, what's blocking it, and when it's done.

The blueprint organizes its content by lane. Each lane section contains the epic(s) that belong to that lane, and each epic contains its full story and task breakdown. The lane structure mirrors the roadmap, so you can jump from a high-level roadmap lane to its detailed blueprint section without mental translation.

---

## How to Use This Document

**Focus rule:** Pick one lane. Work its current phase to completion. Move to the next phase. Switch lanes only at phase boundaries or when blocked by a cross-lane dependency.

**Dependency rule:** If a work item says it depends on another lane, check the Cross-Lane Dependency Map (§14). If the upstream item isn't done yet, move to a different work item in your current lane or switch to the upstream lane to unblock yourself.

**Status tracking:** Use the GitHub Projects board described in §1, or track against the roadmap's checkboxes for a lighter-weight view.

**Epic/story/task hierarchy:** Epics are top-level work buckets (one or two per lane). Stories are user-facing chunks of value within an epic. Tasks are individual work items within a story — most are tracked as checkboxes within their parent story issue rather than as separate GitHub issues.

---

## Table of Contents

1. [GitHub Project Architecture](#1-github-project-architecture)
2. [Label Taxonomy](#2-label-taxonomy)
3. [Custom Fields](#3-custom-fields)
4. [Lane-Based Epic Index](#4-lane-based-epic-index)
5. [Lane 1: Research Paper](#lane-1-research-paper)
6. [Lane 2: LlmsTxtKit](#lane-2-llmstxtkit)
7. [Lane 3: DocStratum](#lane-3-docstratum)
8. [Lane 4: Benchmark](#lane-4-benchmark)
9. [Lane 5: Blog & Content](#lane-5-blog--content)
10. [Lane 6: Cross-Cutting](#lane-6-cross-cutting)
11. [Cross-Lane Dependency Map](#11-cross-lane-dependency-map)
12. [Milestone Definitions](#12-milestone-definitions)
13. [Where to Start Right Now](#13-where-to-start-right-now)
14. [Implementation Plan for This Blueprint](#14-implementation-plan-for-this-blueprint)

---

## 1. GitHub Project Architecture

### Project Location

GitHub Projects V2 supports **user-level projects** (no organization required). The project will be created under Ryan's personal GitHub account and will pull issues from all four repositories:

| Repository | Role | Issue Types |
|---|---|---|
| `llmstxt-research` | Research hub (paper, benchmark, blog) | Paper tasks, benchmark tasks, blog tasks, cross-repo dependency trackers |
| `LlmsTxtKit` | Software product (C#/.NET library + MCP) | Spec tasks, implementation tasks, test tasks, packaging tasks |
| `docstratum` | Validator (Python) | Design backlog, implementation tasks, test tasks |
| `southpawriter-blog` | Publishing venue (Docusaurus site) | Blog publishing tasks, site infrastructure, llms.txt dogfooding |
| `llms-txt` (external, read-only) | Reference implementation — canonical behavioral ground truth | No issues created here. This is the `AnswerDotAI/llms-txt` repo containing the official Python parser, XML context generator, and spec source. Used to validate parsing behavior, inform design decisions, and source the benchmark corpus list (`nbs/domains.md`). See `llms-txt-reference-repo-analysis.md`. |

### Project Board Views

The project should have multiple views to serve different purposes:

| View | Type | Purpose | Grouping | Filtering |
|---|---|---|---|---|
| **Backlog** | Table | Full task inventory | Grouped by Lane | All open items |
| **Sprint Board** | Board (Kanban) | Current work in progress | Columns: To Do, In Progress, In Review, Done | Current iteration only |
| **Dependency Tracker** | Table | Cross-repo blockers | Grouped by Blocked By | Items with `blocked` label |
| **Timeline** | Roadmap | Phase-level progress | Grouped by Milestone | Epics and stories only |
| **By Lane** | Table | Lane-focused work view | Grouped by Lane | Filterable by lane |
| **By Repository** | Table | Per-repo work view | Grouped by Repository | Filterable by repo |

---

## 2. Label Taxonomy

Labels are applied to GitHub Issues within each repository. The taxonomy is consistent across all four repos.

### Type Labels (Mutually Exclusive — Every Issue Gets Exactly One)

| Label | Color | Description |
|---|---|---|
| `type:epic` | `#6A0DAD` (purple) | Top-level work bucket. Contains stories. |
| `type:story` | `#1D76DB` (blue) | User-facing chunk of value. Contains tasks. |
| `type:task` | `#0E8A16` (green) | Individual work item. Assignable and completable. |
| `type:spike` | `#FBCA04` (yellow) | Research or investigation needed before a task can be defined. |
| `type:bug` | `#D93F0B` (red) | Defect in existing functionality. |

### Lane Labels (One Per Issue)

| Label | Color | Description |
|---|---|---|
| `lane:paper` | `#1B4F72` (deep blue) | Lane 1: Research Paper |
| `lane:toolkit` | `#6C3483` (deep purple) | Lane 2: LlmsTxtKit |
| `lane:validator` | `#117A65` (deep teal) | Lane 3: DocStratum |
| `lane:benchmark` | `#B9770E` (deep gold) | Lane 4: Benchmark Study |
| `lane:blog` | `#922B21` (deep red) | Lane 5: Blog & Content |
| `lane:crosscut` | `#566573` (slate gray) | Lane 6: Cross-Cutting |

### Domain Labels (One or More Per Issue)

| Label | Description |
|---|---|
| `domain:paper` | Analytical paper work |
| `domain:benchmark` | Benchmark study work |
| `domain:blog` | Blog post drafting/publishing |
| `domain:kit-core` | LlmsTxtKit.Core library |
| `domain:kit-mcp` | LlmsTxtKit.Mcp server |
| `domain:kit-spec` | LlmsTxtKit specification documents |
| `domain:ds-design` | DocStratum design specifications |
| `domain:ds-impl` | DocStratum implementation |
| `domain:ds-test` | DocStratum testing |
| `domain:site` | Blog site infrastructure |
| `domain:ops` | CI/CD, GitHub Actions, project management |

### Status Labels

| Label | Description |
|---|---|
| `blocked` | Waiting on a dependency (cross-repo or intra-repo) |
| `needs-spec` | Cannot proceed until a specification is written |
| `needs-review` | Work is complete but requires review before closing |
| `deferred` | Explicitly moved to a later phase |

### Priority Labels

| Label | Description |
|---|---|
| `priority:critical` | Blocks multiple other items. Must be resolved first. |
| `priority:high` | Important for the current phase. |
| `priority:medium` | Should be done in the current phase if time permits. |
| `priority:low` | Nice to have. Can slip to next phase. |

---

## 3. Custom Fields

GitHub Projects V2 supports custom fields on project items. These fields provide the structured metadata that turns a flat issue list into a navigable project.

| Field | Type | Values / Description |
|---|---|---|
| **Lane** | Single Select | Paper, LlmsTxtKit, DocStratum, Benchmark, Blog & Content, Cross-Cutting |
| **Epic** | Single Select | Paper, DocStratum, LlmsTxtKit, Benchmark, Blog Series, Blog Dogfooding, Infrastructure |
| **Story Points** | Number | Relative effort estimate (1 = trivial, 2 = small, 3 = medium, 5 = large, 8 = very large, 13 = epic-sized — should be decomposed) |
| **Lane Phase** | Single Select | Gather, Analyze, Write, Review, Spec, Build, Test, Ship, Design, Collect, Run, Calibrate, Post, Infra, Setup, Ongoing |
| **Phase** | Single Select | Phase 0 (Setup), Phase 1 (Foundations), Phase 2 (Implementation), Phase 3 (Experimentation), Phase 4 (Synthesis) |
| **Blocked By** | Text | Issue URL(s) of blocking items. Free text to support cross-repo links. |
| **Target Week** | Number | Week number (1–18) from the consolidated timeline. |
| **Repository** | Single Select | Auto-populated. `llmstxt-research`, `LlmsTxtKit`, `docstratum`, `southpawriter-blog` |
| **Iteration** | Iteration | 2-week iterations aligned with the blog cadence. |

---

## 4. Lane-Based Epic Index

| Lane | # | Epic | Repository | Lane Phases | Stories | Est. Total Points |
|---|---|---|---|---|---|---|
| **1: Paper** | E1 | Analytical Paper | llmstxt-research | Gather → Analyze → Write → Review | 6 | 49 |
| **2: Toolkit** | E3 | LlmsTxtKit | LlmsTxtKit | Spec → Build → Test → Ship | 7 | 63 |
| **3: Validator** | E2 | DocStratum Validator | docstratum | Design → Build → Test → Calibrate | 8 | 84 |
| **4: Benchmark** | E4 | Empirical Benchmark | llmstxt-research | Design → Collect → Run → Analyze | 6 | 60 |
| **5: Blog** | E5 | Blog Series | llmstxt-research + southpawriter-blog | Post 1 → Post 2 → ... → Post 8 | 8 | 49 |
| **5: Blog** | E6 | Blog Dogfooding | southpawriter-blog + docstratum | Baseline → Field Test → Observe | 3 | 13 |
| **6: Cross-Cut** | E7 | Infrastructure | All repos | Setup → Ongoing | 5 | 26 |
| | | | | **Totals** | **44 stories** | **~349 points** |

---

## Lane 1: Research Paper

> **Epic 1: Analytical Paper — "The llms.txt Access Paradox"**
> **Repository:** `llmstxt-research` | **Lane Phases:** Gather → Analyze → Write → Review
> **Lane color:** Deep Blue (`#1B4F72`)

Produce a 6,000–10,000 word analytical paper documenting the gap between llms.txt's design intent, the infrastructure reality, and actual AI system behavior. The paper covers four threads: the inference gap, the infrastructure paradox, the trust architecture, and standards fragmentation.

**Epic-Level Acceptance Criteria:**

- Paper published as Markdown source and rendered PDF
- All four analytical threads substantiated with cited evidence
- Data appendix includes adoption statistics with source provenance
- At least 3 external reviewers have provided feedback (and feedback addressed)
- Paper is cross-referenced by the benchmark study and at least 2 blog posts

**Lane-specific guidance:** The paper is the intellectual backbone but the last thing to finish. Its final sections depend on benchmark data. Front-load the Gather and Analyze phases — those are independent and can start immediately.

---

### Story 1.1: Research Consolidation and Evidence Gathering

**Description:** Consolidate all existing research sources, verify citations, identify gaps in evidence, and produce a structured evidence inventory that maps each claim in the paper outline to its supporting source.
**Lane Phase:** Gather | **Target Weeks:** 1–2 | **Points:** 8
**Dependencies:** None (this is the starting point)
**Acceptance Criteria:**
- Evidence inventory document exists mapping every major claim to a source
- All sources verified as accessible (URLs checked, PDFs saved locally)
- Gaps identified where claims lack sufficient sourcing
- At least 10 primary sources cataloged (not secondary blog posts citing each other)

**Tasks:**

| # | Task | Points | Description |
|---|---|---|---|
| 1.1.1 | Create evidence inventory template | 1 | Define the structure: claim → source → source type (primary/secondary) → verification status → notes |
| 1.1.2 | Catalog Thread 1 sources (inference gap) | 2 | Collect and verify sources for server log evidence, platform statements, training vs. inference distinction. Key sources: Yoast analysis, Mintlify data, Profound data, developer screenshots. |
| 1.1.3 | Catalog Thread 2 sources (infrastructure paradox) | 2 | Collect WAF documentation, Cloudflare policy posts, AI Crawl Control documentation, firsthand blocking experience data. |
| 1.1.4 | Catalog Thread 3 sources (trust architecture) | 1 | Collect Google statements (Mueller, Illyes), keywords meta tag comparison analysis, cloaking concerns, LLM manipulation research (2.5× recommendation study). |
| 1.1.5 | Catalog Thread 4 sources (standards fragmentation) | 1 | Collect spec documents for llms.txt, Content Signals, CC Signals, IETF aipref, robots.txt history. |
| 1.1.6 | Gap analysis and source acquisition | 1 | For each gap identified, either locate a source, plan primary data collection, or document why the gap exists and how the paper handles it. |
| 1.1.7 | Cross-reference ref repo `domains.md` with adoption stats | — | Cross-reference the curated domain list from `AnswerDotAI/llms-txt/nbs/domains.md` against directory listings and Majestic Million data. *(New — from reference repo analysis)* |
| 1.1.8 | Analyze reference parser behavior for §2 claims 2.6–2.7 | — | Document the reference parser's minimalism (~20 lines) and the XML context format's Claude orientation as evidence items. *(New — from reference repo analysis)* |

---

### Story 1.2: Paper Outline and Structure

**Description:** Produce the detailed section-by-section outline with completion tracking, argument flow annotations, and placeholder text for each section indicating what evidence supports it.
**Lane Phase:** Analyze | **Target Weeks:** 1–2 | **Points:** 5
**Dependencies:** Story 1.1 (evidence inventory informs what can be argued)
**Acceptance Criteria:**
- `paper/outline.md` exists with all 10 sections from the proposal
- Each section has: thesis statement, key evidence references (by inventory ID), estimated word count, and completion status
- Argument flow between sections is annotated (how each section sets up the next)
- Outline reviewed against the proposal's paper description for completeness

**Tasks:**

| # | Task | Points | Description |
|---|---|---|---|
| 1.2.1 | Draft section-level outline | 2 | Create `paper/outline.md` with all 10 sections, thesis statements, and evidence mappings. |
| 1.2.2 | Annotate argument flow | 1 | Add transition notes between sections showing how each builds on the previous. |
| 1.2.3 | Estimate word counts per section | 1 | Target 6,000–10,000 total. Allocate budget per section based on evidence density. |
| 1.2.4 | Self-review against proposal | 1 | Verify the outline covers all four threads, all three target audiences, and the "future work" framing for the benchmark. |

---

### Story 1.3: First Draft

**Description:** Write the complete first draft of the paper in `paper/draft.md`.
**Lane Phase:** Write | **Target Weeks:** 3–4 | **Points:** 13
**Dependencies:** Stories 1.1, 1.2
**Acceptance Criteria:**
- `paper/draft.md` exists with all 10 sections written
- Word count is within the 6,000–10,000 target range
- Every factual claim has a citation (inline or footnote)
- The "future work" section explicitly frames the benchmark study and LlmsTxtKit
- Draft is committed to a feature branch for review

**Tasks:**

| # | Task | Points | Description |
|---|---|---|---|
| 1.3.1 | Write Abstract (Section 1) | 1 | 200-word summary. Write last (after all other sections), but it appears first. |
| 1.3.2 | Write Introduction (Section 2) | 2 | The promise of llms.txt. Howard's original context, FastHTML, spec design intent. Include reference implementation evidence (claims 2.6–2.7). |
| 1.3.3 | Write Adoption Landscape (Section 3) | 2 | Quantitative data: directory counts, Majestic Million, notable adopters, sector distribution. Include ref repo `domains.md` cross-reference (claim 3.6). |
| 1.3.4 | Write Inference Gap (Section 4) | 2 | Server log evidence, platform non-confirmation, training vs. inference distinction. |
| 1.3.5 | Write Infrastructure Paradox (Section 5) | 2 | WAF mechanics, Cloudflare defaults, three-way misalignment, firsthand experience. |
| 1.3.6 | Write Trust Architecture (Section 6) | 1 | Google's comparison, cloaking, validation absence, what platforms would need. |
| 1.3.7 | Write Standards Fragmentation (Section 7) | 1 | Comparative analysis of all standards. Permission vs. discovery. |
| 1.3.8 | Write GEO Implications (Section 8) | 1 | Evidence-based recommendations for practitioners. |
| 1.3.9 | Write Research Gaps / Future Work (Section 9) | 1 | Explicit framing for the benchmark study and LlmsTxtKit. |

---

### Story 1.4: Review, Revision, and Data Verification

**Description:** Revise the first draft based on self-review and external feedback. Verify all data points. Produce the data appendix and optional aggregation notebook.
**Lane Phase:** Review | **Target Weeks:** 5–8 | **Points:** 13
**Dependencies:** Story 1.3 (first draft complete)
**Acceptance Criteria:**
- All factual claims verified against primary sources
- Adoption statistics cross-referenced and discrepancies documented
- Data appendix (`paper/data/`) populated with raw data and source provenance
- At least 2 external reviewers solicited with specific feedback requests
- Reviewer feedback incorporated or explicitly declined with rationale
- Optional aggregation notebook documents how statistics were compiled

**Tasks:**

| # | Task | Points | Description |
|---|---|---|---|
| 1.4.1 | Self-review pass: factual accuracy | 2 | Verify every statistic, every quote, every date against its source. |
| 1.4.2 | Self-review pass: argument coherence | 2 | Read the paper as a skeptical reviewer. Identify weaknesses. |
| 1.4.3 | Compile data appendix | 2 | Populate `paper/data/` with adoption stats CSV, server log samples, config examples. |
| 1.4.4 | Create adoption analysis notebook (optional) | 3 | `paper/data/adoption-analysis.ipynb` documenting how aggregate statistics were derived. Colab-compatible. |
| 1.4.5 | Solicit external feedback (2–3 reviewers) | 1 | Identify and contact reviewers per the Roadmap's feedback solicitation guidelines. |
| 1.4.6 | Incorporate feedback | 2 | Address reviewer comments. Document any declined suggestions with rationale. |
| 1.4.7 | Final copyedit pass | 1 | Grammar, consistency, citation format, tone. |

---

### Story 1.5: Paper Publication

**Description:** Finalize the paper, render to PDF, and publish.
**Lane Phase:** Review | **Target Week:** 9 | **Points:** 5
**Dependencies:** Story 1.4
**Acceptance Criteria:**
- `paper/draft.md` is final
- `paper/draft.pdf` rendered and committed
- README.md status updated from 🔲 to ✅ with link
- Paper linked from the blog site (research section or dedicated page)
- Shared on 2–3 relevant platforms per the community engagement strategy

**Tasks:**

| # | Task | Points | Description |
|---|---|---|---|
| 1.5.1 | Final formatting pass | 1 | Ensure Markdown renders correctly, all links work, figures display properly. |
| 1.5.2 | Render to PDF | 1 | Use pandoc or equivalent to produce a clean PDF. Verify rendering. |
| 1.5.3 | Update README status indicators | 1 | Update `llmstxt-research/README.md` paper status. |
| 1.5.4 | Publish and announce | 2 | Link from blog site. Share on target platforms. Create GitHub Discussion for feedback. |

---

### Story 1.6: Benchmark-Informed Revision

**Description:** After the benchmark study produces results, revise the paper to incorporate empirical findings and cross-references.
**Lane Phase:** Review | **Target Weeks:** 15–16 | **Points:** 5
**Dependencies:** Lane 4, Stories 4.4, 4.5 (Benchmark analysis complete)
**Acceptance Criteria:**
- Paper's "Research Gaps" section updated to reference benchmark findings
- Cross-references to specific benchmark metrics added where relevant
- Revised PDF published alongside original (original preserved)
- Revision noted in CHANGELOG

**Tasks:**

| # | Task | Points | Description |
|---|---|---|---|
| 1.6.1 | Identify revision points | 1 | Map benchmark findings to specific paper sections that should reference them. |
| 1.6.2 | Write revision content | 2 | Add cross-references, update "future work" to "completed work," incorporate key metrics. |
| 1.6.3 | Re-render and publish revised PDF | 1 | Publish as v2 alongside original v1. |
| 1.6.4 | Update status and announce | 1 | Note revision in README, CHANGELOG. Brief social announcement. |

---

## Lane 2: LlmsTxtKit

> **Epic 3: LlmsTxtKit — C#/.NET Library & MCP Server**
> **Repository:** `LlmsTxtKit` | **Lane Phases:** Spec → Build → Test → Ship
> **Lane color:** Deep Purple (`#6C3483`)

Build the open-source C#/.NET library and MCP server for llms.txt-aware content retrieval, parsing, validation, and caching. Fills the complete absence of .NET tooling in the llms.txt ecosystem. Provides the `llmstxt_compare` tool needed by the benchmark study (Lane 4).

**Epic-Level Acceptance Criteria:**

- PRS, Design Spec, User Stories, and Test Plan complete and reviewed
- LlmsTxtKit.Core implements all 5 components (Parsing, Fetching, Validation, Caching, Context)
- LlmsTxtKit.Mcp exposes all 5 MCP tools
- All success criteria from the PRS (SC-1 through SC-11) met
- NuGet packages build and are publishable
- Real-world test corpus includes ≥10 production llms.txt files
- `llmstxt_compare` tool functional for benchmark data collection

**Lane-specific guidance:** The Spec phase must be completed before any Build work. The reference repo's `miniparse.py` is your behavioral test oracle — every parsing decision in LlmsTxtKit should produce equivalent output for well-formed inputs. The `llmstxt_compare` tool is a hard dependency for Lane 4 (Benchmark).

---

### Story 3.1: Complete Specification Documents

**Description:** Write the User Stories and Test Plan documents that are currently stubbed. The PRS and Design Spec are already drafted (v1.0) but should be reviewed for completeness.
**Lane Phase:** Spec | **Target Weeks:** 3–4 | **Points:** 8
**Dependencies:** None (PRS and Design Spec drafts exist)
**Acceptance Criteria:**
- `specs/user-stories.md` fully written with all library consumer and MCP agent consumer stories
- Each user story has specific acceptance criteria mappable to test cases
- `specs/test-plan.md` fully written with coverage targets, unit test scenarios, integration scenarios, MCP protocol tests, and test data corpus definition
- PRS and Design Spec reviewed; any gaps addressed
- All spec documents reviewed for internal consistency

**Tasks:**

| # | Task | Points | Description |
|---|---|---|---|
| 3.1.1 | Write Library Consumer user stories | 2 | Stories for: parsing, fetching, validation, caching, context generation. Each with acceptance criteria per the TODO outline in the stub. |
| 3.1.2 | Write MCP Agent Consumer user stories | 2 | Stories for: discover, fetch section, validate, context, compare. Each with acceptance criteria. |
| 3.1.3 | Write Test Plan: coverage targets and unit scenarios | 2 | Define per-component coverage targets. List unit test scenarios for Parser, Validator, Fetcher, Cache, Context per the TODO outline. |
| 3.1.4 | Write Test Plan: integration and MCP protocol scenarios | 1 | List mock HTTP scenarios (7 categories from the stub). Define MCP protocol compliance tests. |
| 3.1.5 | Review PRS and Design Spec for completeness | 1 | Cross-reference PRS success criteria against Design Spec components. Verify reference implementation alignment (per the v1.1 updates from the ref repo analysis). |

---

### Story 3.2: Implement Parser and Fetcher (Core Foundation)

**Description:** Implement the `LlmsDocumentParser` (spec-compliant parsing with lenient diagnostics) and `LlmsTxtFetcher` (infrastructure-aware HTTP fetching with `FetchStatus` enum).
**Lane Phase:** Build | **Target Weeks:** 5–6 | **Points:** 13
**Dependencies:** Story 3.1 (specs complete)
**Acceptance Criteria:**
- `LlmsDocumentParser.Parse()` correctly handles all spec-compliant llms.txt files
- Parser produces equivalent results to the reference Python parser (`miniparse.py`) for all well-formed inputs
- `LlmsDocument` model is immutable with `ParseDiagnostics` collection
- `LlmsTxtFetcher.FetchAsync()` distinguishes 7 outcome categories (Success, NotFound, Blocked, RateLimited, DnsFailure, Timeout, Error)
- WAF block detection heuristics populate `BlockReason`
- `IHttpClientFactory` integration works
- Real-world test corpus of ≥10 files parses correctly
- Unit test coverage ≥90% for both components

**Tasks:**

| # | Task | Points | Description |
|---|---|---|---|
| 3.2.1 | Implement `LlmsDocument`, `LlmsSection`, `LlmsEntry` models | 2 | Immutable types per Design Spec §2.1. Include `RawContent` preservation. |
| 3.2.2 | Implement `LlmsDocumentParser` | 3 | Targeted string processing (no Markdig dependency). Lenient parsing with `ParseDiagnostics`. Handle: H1, blockquote (single-line per ref impl), freeform content, H2 sections (H2-only splitting per ref impl), link lists (canonical regex pattern), Optional section (case-sensitive exact match per ref impl). |
| 3.2.3 | Implement `FetchResult`, `FetchStatus`, `FetcherOptions` | 1 | Models per Design Spec §2.2. Enum for 7 outcome categories. |
| 3.2.4 | Implement `LlmsTxtFetcher` | 3 | HTTP GET with configurable UA, timeout, retries. WAF detection heuristics (Cloudflare headers). `IHttpClientFactory` support. |
| 3.2.5 | Curate real-world test corpus | 1 | Collect ≥10 production llms.txt files (Anthropic, Cloudflare, Stripe, FastHTML, Vercel, etc.). Source candidates from ref repo `nbs/domains.md`. Store in `tests/TestData/valid/`. |
| 3.2.6 | Write parser unit tests | 2 | Spec-compliant inputs, edge cases (missing sections, malformed links, Unicode, very large, empty). Verify behavioral equivalence with reference parser for well-formed inputs. |
| 3.2.7 | Write fetcher unit tests with mock HTTP | 1 | Mock handler for: 200 OK, 403 Cloudflare, 429 rate limit, 404, DNS failure, timeout. |

---

### Story 3.3: Implement Validator, Cache, and Context Generator

**Description:** Complete the remaining three LlmsTxtKit.Core components.
**Lane Phase:** Build | **Target Weeks:** 7–8 | **Points:** 13
**Dependencies:** Story 3.2 (parser and fetcher operational)
**Acceptance Criteria:**
- All 10 validation rules from Design Spec §2.3 implemented
- Rule-based architecture allows independent testing per rule
- Cache with configurable TTL, stale-while-revalidate, domain-keyed
- `ICacheBackingStore` abstraction with in-memory default and file-backed option
- Context generator with token budgeting, Optional section excluded by default (matching reference implementation), XML wrapping
- HTML comments and base64 images stripped from fetched content (matching reference implementation)
- Unit test coverage ≥90%

**Tasks:**

| # | Task | Points | Description |
|---|---|---|---|
| 3.3.1 | Implement `IValidationRule` interface and rule runner | 1 | Per Design Spec §2.3. Independent, testable rules. |
| 3.3.2 | Implement all 10 validation rules | 3 | `REQUIRED_H1_MISSING` through `CONTENT_OUTSIDE_STRUCTURE`. Include `CheckLinkedUrls` and `CheckFreshness` optional rules. |
| 3.3.3 | Implement `CacheEntry`, `CacheOptions`, `ICacheBackingStore` | 2 | Domain-keyed cache. TTL management. Stale-while-revalidate. In-memory + file-backed. |
| 3.3.4 | Implement `ContextGenerator` | 3 | Fetch linked Markdown, strip HTML comments and base64 images (per ref impl), XML section wrapping (`<section name="...">`), Optional section excluded by default (`IncludeOptional=false`), token budgeting with graceful truncation. |
| 3.3.5 | Write validator unit tests (per-rule) | 2 | Test each rule independently against crafted inputs. |
| 3.3.6 | Write cache unit tests | 1 | TTL expiry, eviction, stale-while-revalidate, serialization round-trip. |
| 3.3.7 | Write context generator unit tests | 1 | Section expansion, Optional handling (excluded by default), token budget truncation, failed-fetch placeholders, content stripping. |

---

### Story 3.4: Implement MCP Server

**Description:** Build the MCP server that wraps LlmsTxtKit.Core and exposes 5 tools for AI agent consumption.
**Lane Phase:** Build | **Target Weeks:** 9–10 | **Points:** 8
**Dependencies:** Story 3.3 (all Core components operational)
**Acceptance Criteria:**
- All 5 MCP tools operational: `llmstxt_discover`, `llmstxt_fetch_section`, `llmstxt_validate`, `llmstxt_context`, `llmstxt_compare`
- Tool definitions have clear names, descriptions, and parameter schemas
- Structured JSON responses for all success and error cases
- MCP protocol compliance verified
- `llmstxt_compare` tested against ≥5 sites

**Tasks:**

| # | Task | Points | Description |
|---|---|---|---|
| 3.4.1 | Set up MCP server scaffold | 1 | `Program.cs`, DI configuration, MCP protocol handling, transport layer. |
| 3.4.2 | Implement `llmstxt_discover` tool | 1 | Delegates to `FetchAsync`. Returns structure summary or error status. |
| 3.4.3 | Implement `llmstxt_fetch_section` tool | 1 | Cache-aware. Fetches section content. |
| 3.4.4 | Implement `llmstxt_validate` tool | 1 | Delegates to validator. Returns structured report. |
| 3.4.5 | Implement `llmstxt_context` tool | 1 | Delegates to context generator. Returns context with metadata. |
| 3.4.6 | Implement `llmstxt_compare` tool | 2 | Fetch HTML + Markdown versions. Compare size, tokens, freshness. Critical for Lane 4 (Benchmark). |
| 3.4.7 | Write MCP protocol compliance tests | 1 | Verify tool response structure, error handling, parameter validation. |

---

### Story 3.5: Integration Testing

**Description:** End-to-end integration tests using a local mock HTTP server that simulates real-world scenarios.
**Lane Phase:** Test | **Target Weeks:** 11–12 | **Points:** 8
**Dependencies:** Stories 3.2, 3.3, 3.4 (all components)
**Acceptance Criteria:**
- Mock HTTP server simulates all 7 fetch outcome categories
- Full pipeline tests: discover → fetch → validate → cache → generate context
- MCP server integration tests via protocol
- Real-world corpus integration: parse and validate all test corpus files end-to-end
- No test requires live network access

**Tasks:**

| # | Task | Points | Description |
|---|---|---|---|
| 3.5.1 | Build mock HTTP server test infrastructure | 2 | Configurable responses for: 200 OK, 403 Cloudflare, 429 rate limit, 404, redirects, slow responses, malformed content. |
| 3.5.2 | Write full pipeline integration tests | 2 | End-to-end: URL → fetch → parse → validate → cache → context. Multiple scenarios. |
| 3.5.3 | Write MCP server integration tests | 2 | Invoke each tool via protocol. Verify response structure and content. |
| 3.5.4 | Write real-world corpus integration tests | 2 | Parse and validate every file in `tests/TestData/valid/`. Verify no crashes, expected diagnostics. |

---

### Story 3.6: Packaging, Documentation, and Release

**Description:** Prepare NuGet packages, generate API documentation, write README, and publish v1.0.
**Lane Phase:** Ship | **Target Weeks:** 13–14 | **Points:** 8
**Dependencies:** Story 3.5 (integration tests pass)
**Acceptance Criteria:**
- NuGet packages build with correct metadata
- XML documentation generates browsable API reference
- README has installation instructions, quick start, API overview
- CHANGELOG documents all changes from initial commit through v1.0
- Tagged release created on GitHub
- NuGet packages published (or ready to publish)
- Integration listing PR submitted to llmstxt.org

**Tasks:**

| # | Task | Points | Description |
|---|---|---|---|
| 3.6.1 | Configure NuGet package metadata | 1 | Package ID, version, description, license (MIT), repo URL, tags, icon. Both packages. |
| 3.6.2 | Generate API documentation site | 2 | From XML doc comments. Browsable HTML. Host on GitHub Pages or similar. |
| 3.6.3 | Write comprehensive README | 2 | Installation, quick start (3 examples), API overview, MCP server setup, link to research initiative. |
| 3.6.4 | Write CHANGELOG | 1 | Document all features, following Keep a Changelog format. |
| 3.6.5 | Create v1.0 GitHub release | 1 | Tag, release notes, binary attachments. |
| 3.6.6 | Submit llmstxt.org integration listing PR | 1 | Add LlmsTxtKit to the integrations page. |

---

### Story 3.7: Post-Release Bug Fixes from Benchmark Usage

**Description:** Address issues discovered when the benchmark study uses LlmsTxtKit as its data collection tool.
**Lane Phase:** Ship | **Target Weeks:** 15–16 | **Points:** 5
**Dependencies:** Lane 4, Story 4.4 (Benchmark data collection)
**Acceptance Criteria:**
- All blocking bugs found during benchmark data collection resolved
- Parser handles any new edge cases discovered in benchmark corpus
- `llmstxt_compare` refinements based on real-world usage incorporated
- v1.0.x patch release if needed

**Tasks:**

| # | Task | Points | Description |
|---|---|---|---|
| 3.7.1 | Triage benchmark-discovered issues | 1 | Categorize: parser bug, fetcher bug, compare tool issue, edge case. |
| 3.7.2 | Fix blocking issues | 2 | Resolve issues that prevent benchmark data collection. |
| 3.7.3 | Add discovered edge cases to test corpus | 1 | Expand `tests/TestData/` with files from benchmark corpus that exposed issues. |
| 3.7.4 | Publish patch release if needed | 1 | v1.0.x with fixes. Update CHANGELOG. |

---

## Lane 3: DocStratum

> **Epic 2: DocStratum Validator — v0.3.x Through v1.0**
> **Repository:** `docstratum` | **Lane Phases:** Design → Build → Test → Calibrate
> **Lane color:** Deep Teal (`#117A65`)

Advance the DocStratum validator from its current state (v0.2.2d — parser complete, 523 tests, 96.96% coverage) through the validation engine (v0.3.x), quality scoring (v0.4.x), CLI/profiles (v0.5.x), and toward the v1.0 release. This epic's immediate priority is completing the 6-item documentation backlog that blocks v0.3.x implementation.

**Epic-Level Acceptance Criteria:**

- All 6 documentation backlog items completed per their exit criteria
- Validation engine (v0.3.x) implemented with L0–L3 checks and anti-pattern detection
- Quality scoring (v0.4.x) implemented with calibrated weights
- CLI operational with at least 3 built-in profiles (lint, ci, full)
- Test coverage maintained ≥90% across all new code
- Blog llms.txt file validated successfully as a dogfooding proof point

**Lane-specific guidance:** DocStratum's L0–L1 levels are self-contained and can ship independently. L2–L3 calibration depends on benchmark evidence (Lane 4). The "extension labeling" task — distinguishing spec-compliant rules from DocStratum extensions per the reference repo analysis — can start immediately.

---

### Story 2.1: Output Tier Specification (Documentation Backlog Item 1)

**Description:** Define the four consumer-facing output tiers (Pass/Fail Gate, Diagnostic Report, Remediation Playbook, Audience-Adapted Recommendations). This is the **root dependency** for all subsequent DocStratum design work — it defines what the validator delivers.
**Lane Phase:** Design | **Points:** 8 | **Priority:** Critical
**Dependencies:** None (root blocker)
**Acceptance Criteria:** (Per the documentation backlog's exit criteria)
- Four output tiers formally defined with audience, use case, and data requirements
- Pipeline stage → tier data mapping documented
- Serialization format specified per tier
- Format-tier compatibility matrix defined
- Scope boundaries drawn between v0.2.x–v0.3.x and v0.4.x+
- Reviewed against existing `ValidationResult` and `EcosystemScore` models for compatibility

**Tasks:**

| # | Task | Points | Description |
|---|---|---|---|
| 2.1.1 | Define Tier 1 (Pass/Fail Gate) | 1 | Specify the binary CI/CD output: exit code, minimal metadata, threshold configuration. Map to `ValidationResult.is_valid`. |
| 2.1.2 | Define Tier 2 (Diagnostic Report) | 2 | Specify the structured finding list: code, severity, message, line number, remediation hint. Map to `ValidationDiagnostic` output. Define JSON/Markdown/YAML serialization. |
| 2.1.3 | Define Tier 3 (Remediation Playbook) | 2 | Specify the prioritized action plan format. Define what data it consumes beyond Tier 2 (quality scores, ecosystem scores, relationship graph). |
| 2.1.4 | Define Tier 4 (Audience-Adapted) | 1 | Specify the contextual intelligence layer. Define additional context inputs required. Explicitly scope this to v0.4.x+. |
| 2.1.5 | Create pipeline stage → tier data mapping | 1 | Map each of the 5 (soon 6) pipeline stages to which tiers consume their output. |
| 2.1.6 | Review against existing models | 1 | Verify compatibility with `ValidationResult`, `EcosystemScore`, `QualityScore` Pydantic models. Document any required model changes. |

---

### Story 2.2: Remediation Framework (Documentation Backlog Item 2)

**Description:** Define how the validator transforms individual diagnostic hints into a coherent, prioritized action plan. Covers priority model, grouping strategy, remediation templates, and dependency-aware sequencing.
**Lane Phase:** Design | **Points:** 8 | **Priority:** High
**Dependencies:** Story 2.1 (Output Tier Specification)
**Acceptance Criteria:** (Per the documentation backlog's exit criteria)
- Priority model defined with ranked factors and tie-breaking rules
- Grouping strategy specified with at least two modes
- At least 5 remediation templates written spanning E/W/I severity
- Dependency graph or matrix for the 38 existing diagnostic codes
- Tier 3 / Tier 4 boundary explicitly drawn
- Reviewed against existing `DiagnosticCode.remediation` fields for consistency

**Tasks:**

| # | Task | Points | Description |
|---|---|---|---|
| 2.2.1 | Design priority model | 2 | Define ranking factors: gating impact, dependency, effort estimation, quality score impact. Define tie-breaking rules. |
| 2.2.2 | Design grouping strategy | 2 | Define at least two modes: by-validation-level (L0 first) and by-effort (quick wins first). Specify how the consumer selects the mode. |
| 2.2.3 | Write 5+ remediation templates | 2 | Expand terse `remediation` hints into actionable guidance. Cover at least one ERROR, one WARNING, and one INFO code. Include examples. |
| 2.2.4 | Build dependency matrix for 38 diagnostic codes | 1 | Identify which codes are prerequisite to others. Document as a matrix or DAG (directed acyclic graph). |
| 2.2.5 | Draw Tier 3 / Tier 4 boundary | 1 | Define where generic remediation (Tier 3) ends and contextual intelligence (Tier 4) begins. |

---

### Story 2.3: Unified Rule Registry (Documentation Backlog Item 3)

**Description:** Design the single-point-of-truth registry that connects every validation rule's definition (ASoT standard file) to its implementation (Python function), pipeline stage, dependencies, and output tier participation.
**Lane Phase:** Design | **Points:** 8 | **Priority:** High
**Dependencies:** Story 2.1 (Output Tier Specification — for the `output_tiers` field)
**Acceptance Criteria:** (Per the documentation backlog's exit criteria)
- Registry Pydantic model schema defined with all fields, types, and constraints
- Relationship to DS-MANIFEST explicitly documented
- Format decision made and justified (YAML + Pydantic recommended)
- Integrity assertion specifications written
- At least 5 example registry entries covering L0–L4 and multiple pipeline stages
- Reviewed against existing `ANTI_PATTERN_REGISTRY` for pattern consistency

**Tasks:**

| # | Task | Points | Description |
|---|---|---|---|
| 2.3.1 | Define registry Pydantic model | 2 | Schema: `rule_id`, `diagnostic_codes`, `validation_level`, `pipeline_stage`, `implemented_in`, `depends_on`, `asot_path`, `status`, `output_tiers`, `tags`, `spec_origin` (new: `spec-compliant` or `docstratum-extension`). |
| 2.3.2 | Document DS-MANIFEST relationship | 1 | Define whether the registry extends, replaces, or parallels the existing manifest. Recommended: extends. |
| 2.3.3 | Make and justify format decision | 1 | Choose YAML + Pydantic, pure Python, or static Markdown. Document rationale. |
| 2.3.4 | Write integrity assertion specs | 2 | Define testable assertions: all `diagnostic_codes` exist, all `asot_path` values resolve, all `pipeline_stage` values are valid. |
| 2.3.5 | Write 5+ example registry entries | 2 | Cover L0 (parseable), L1 (structural), L2 (content), L3 (best practices), and L4 (ecosystem). Include `spec_origin` field. |

---

### Story 2.4: Validation Profiles & Module Composition (Documentation Backlog Item 4)

**Description:** Define how consumers configure which validation checks run and what output they receive. Profiles are named module compositions; the "buffet" is an anonymous profile defined inline.
**Lane Phase:** Design | **Points:** 8 | **Priority:** High
**Dependencies:** Stories 2.1, 2.3 (Output Tiers, Rule Registry)
**Acceptance Criteria:** (Per the documentation backlog's exit criteria)
- Profile Pydantic model schema defined with all fields
- 3–4 built-in profiles fully specified (lint, ci, full, enterprise)
- Module composition semantics defined (tag interaction, exclusion precedence, inheritance)
- Custom profile loading mechanism specified
- Integration point with `PipelineContext` documented
- At least one example custom profile written

**Tasks:**

| # | Task | Points | Description |
|---|---|---|---|
| 2.4.1 | Define profile Pydantic model | 2 | Fields: `profile_name`, `description`, `max_validation_level`, `enabled_stages`, `rule_tags_include/exclude`, `severity_overrides`, `pass_threshold`, `output_tier`, `output_format`. |
| 2.4.2 | Specify 3–4 built-in profiles | 2 | Define `lint` (L0–L1, Tier 2), `ci` (L0–L3, Tier 1, threshold ≥50), `full` (L0–L4, Tier 3), `enterprise` (deferred scope). |
| 2.4.3 | Define module composition semantics | 2 | Tag interaction (AND/OR), exclusion overrides, profile inheritance via `extends`. |
| 2.4.4 | Specify custom profile loading | 1 | Define `.docstratum.yml` discovery, CLI flag overrides, lookup order, precedence. |
| 2.4.5 | Document PipelineContext integration | 1 | Define how `PipelineContext` gains a `profile` field. How each stage reads it. |

---

### Story 2.5: Report Generation Stage & Ecosystem Calibration (Documentation Backlog Items 5–6)

**Description:** Design Pipeline Stage 6 (report generation — the presentation layer that transforms pipeline results into consumable artifacts) and produce the ecosystem scoring calibration document.
**Lane Phase:** Design | **Points:** 13 | **Priority:** Medium
**Dependencies:** Stories 2.1, 2.2, 2.3, 2.4 (all prior backlog items)
**Acceptance Criteria:**
- Stage 6 interface defined conforming to existing patterns
- Tier-specific renderer specifications for Tiers 1–3
- Format serializers specified for JSON, Markdown, YAML
- Report metadata schema defined
- Ecosystem health dimension weights justified with evidence
- At least 4 calibration specimens defined with expected scores
- Grade boundaries proposed and justified
- Aggregation formula defined

**Tasks:**

| # | Task | Points | Description |
|---|---|---|---|
| 2.5.1 | Define Stage 6 interface | 2 | Conform to `StageResult` / `PipelineContext` patterns. Define skip conditions. |
| 2.5.2 | Specify Tier 1–3 renderers | 3 | Tier 1: pass/fail evaluator. Tier 2: diagnostic list serializer. Tier 3: remediation playbook generator (consumes framework from 2.2). |
| 2.5.3 | Specify JSON/Markdown/YAML serializers | 2 | Independent of tier. Define format for each. HTML deferred to v0.4.x. |
| 2.5.4 | Define report metadata schema | 1 | ASoT version, profile name, timestamp, files validated, stages executed, execution time. |
| 2.5.5 | Justify ecosystem dimension weights | 2 | For each of the 5 health dimensions (Coverage, Consistency, Completeness, Token Efficiency, Freshness), document proposed weight and evidence basis. |
| 2.5.6 | Create 4+ calibration specimens | 2 | EXEMPLARY, STRONG, NEEDS_WORK, CRITICAL. Document expected scores and reasoning. |
| 2.5.7 | Define grade boundaries and aggregation formula | 1 | Propose ecosystem-level grade thresholds. Define how per-file scores interact with ecosystem dimensions. |

---

### Story 2.5a: Extension Labeling Audit (New — from Reference Repo Analysis)

**Description:** Audit all existing DocStratum validation rules, canonical section definitions, and ABNF grammar rules to explicitly label which are spec-compliant (matching the reference parser's behavior) and which are DocStratum extensions (going beyond the reference parser).
**Lane Phase:** Design | **Points:** 5 | **Priority:** High
**Dependencies:** None (can start immediately using the reference repo analysis)
**Acceptance Criteria:**
- Every validation criterion in the ASoT standards library has a `spec_origin` classification
- The ABNF grammar's extension points are annotated (multi-line blockquote, H3 sub-section awareness, Optional aliases)
- A summary document maps each extension to its rationale
- DS-CN-011 (Optional section) updated to note that alias support is a DocStratum extension

**Tasks:**

| # | Task | Points | Description |
|---|---|---|---|
| 2.5a.1 | Classify all L0–L1 criteria as spec-compliant or extension | 1 | Compare each criterion against reference parser behavior documented in `llms-txt-reference-repo-analysis.md`. |
| 2.5a.2 | Classify all L2–L4 criteria as spec-compliant or extension | 2 | Most L2+ criteria will be extensions since the reference parser doesn't validate. Document rationale. |
| 2.5a.3 | Annotate ABNF grammar extension points | 1 | Add inline comments to the formal grammar (RR-SPEC-v0.0.1a) where rules extend beyond reference behavior. (Blockquote multi-line comment already added.) |
| 2.5a.4 | Update DS-CN-011 and related canonical standards | 1 | Note that Optional section aliases (supplementary, appendix, extras) are DocStratum extensions not present in the reference implementation. |

---

### Story 2.6: Implement L0–L1 Validation Checks (v0.3.0–v0.3.1)

**Description:** Implement the first two validation levels: L0 (Parseable — can the file be parsed at all?) and L1 (Structural — does the file meet the spec's structural requirements?). These are the foundation checks that all higher levels depend on.
**Lane Phase:** Build | **Points:** 13 | **Priority:** High
**Dependencies:** Stories 2.1–2.4 (design backlog complete), existing v0.2.x parser
**Acceptance Criteria:**
- `ValidationRule` base class/protocol implemented
- All L0 checks from `RR-SPEC-v0.3.0` implemented and tested
- All L1 checks from `RR-SPEC-v0.3.1` implemented and tested
- Each rule independently testable via the rule-based architecture
- Test coverage ≥90% for all new validation code
- Rules integrated with the parser adapter (v0.2.2d)

**Tasks:**

| # | Task | Points | Description |
|---|---|---|---|
| 2.6.1 | Implement `IValidationRule` protocol and base infrastructure | 2 | Define the rule interface, rule runner, and diagnostic emitter. |
| 2.6.2 | Implement L0 checks (v0.3.0a–d) | 3 | File exists, file is valid UTF-8, file is parseable Markdown, file has at least one structural element. Per the 4 sub-specs. |
| 2.6.3 | Implement L1 structural checks (v0.3.1a–d) | 3 | H1 title present, blockquote structure valid, H2 sections contain link lists, no content outside structure. Per the 4 sub-specs. |
| 2.6.4 | Write unit tests for L0 checks | 2 | Test each L0 rule independently against synthetic fixtures (L0_fail.txt, L1_minimal.txt). |
| 2.6.5 | Write unit tests for L1 checks | 2 | Test each L1 rule independently. Include edge cases from `test_parser_edge_cases.py`. |
| 2.6.6 | Integration test: L0–L1 against specimen files | 1 | Run L0–L1 validation against all 6 gold-standard specimens. Verify expected diagnostics. |

---

### Story 2.7: Implement L2–L3 Validation and Anti-Pattern Detection (v0.3.2–v0.3.4)

**Description:** Implement the content quality checks (L2), best practice checks (L3), and anti-pattern detection system. These represent the value-add validation beyond basic structural compliance.
**Lane Phase:** Build | **Points:** 13 | **Priority:** High
**Dependencies:** Story 2.6 (L0–L1 foundation)
**Acceptance Criteria:**
- All L2 content quality checks from `RR-SPEC-v0.3.2` implemented
- All L3 best practice checks from `RR-SPEC-v0.3.3` implemented
- Anti-pattern detection from `RR-SPEC-v0.3.4` implemented for all 28 defined anti-patterns
- Each check independently testable
- Test coverage ≥90%
- Validation report produces correct diagnostics for all 6 calibration specimens

**Tasks:**

| # | Task | Points | Description |
|---|---|---|---|
| 2.7.1 | Implement L2 content quality checks (v0.3.2a–d) | 3 | Section completeness, link description quality, content depth, canonical section matching. Per the 4 sub-specs. |
| 2.7.2 | Implement L3 best practice checks (v0.3.3a–e) | 3 | Optional section usage, token budget awareness, freshness indicators, cross-reference quality, metadata completeness. Per the 5 sub-specs. |
| 2.7.3 | Implement anti-pattern detection (v0.3.4a–d) | 3 | Detect all 28 anti-patterns across 5 categories (critical, structural, content, strategic, ecosystem). Per the 4 sub-specs. |
| 2.7.4 | Write unit tests for L2–L3 and anti-patterns | 2 | Comprehensive test suite. Use synthetic fixtures at all conformance levels (L0–L4). |
| 2.7.5 | Calibration validation against specimens | 2 | Run full L0–L3 + anti-pattern validation against all 6 specimens. Compare results to expected diagnostics. Document any calibration adjustments. |

---

### Story 2.8: Quality Scoring and CLI Implementation (v0.4.x–v0.5.x)

**Description:** Implement the 100-point quality scoring system (Structural 30%, Content 50%, Anti-Pattern 20%) and the command-line interface with built-in profiles. This makes DocStratum usable as a standalone tool.
**Lane Phase:** Build | **Points:** 13 | **Priority:** High
**Dependencies:** Stories 2.6, 2.7 (validation engine complete), Stories 2.1–2.4 (profiles designed)
**Acceptance Criteria:**
- Quality score calculation implemented per v0.4.x specs
- Grade assignment (EXEMPLARY through CRITICAL) operational
- CLI accepts file paths and profile names
- 3 built-in profiles operational (lint, ci, full)
- Custom profile loading from `.docstratum.yml` works
- Exit codes reflect pass/fail for CI integration
- Tier 1 and Tier 2 output formats implemented (JSON, Markdown)

**Tasks:**

| # | Task | Points | Description |
|---|---|---|---|
| 2.8.1 | Implement quality score calculation | 3 | Structural (30%), Content (50%), Anti-Pattern (20%) dimensions. Per v0.4.x specs. |
| 2.8.2 | Implement grade assignment | 1 | Map scores to grades: EXEMPLARY ≥90, STRONG ≥70, ADEQUATE ≥50, NEEDS_WORK ≥30, CRITICAL <30. |
| 2.8.3 | Implement CLI entry point | 2 | Accept file paths, `--profile` flag, `--format` flag. Parse arguments. Invoke pipeline. |
| 2.8.4 | Implement built-in profiles | 2 | `lint`, `ci`, `full` as defined in Story 2.4. Load from package defaults. |
| 2.8.5 | Implement custom profile loading | 1 | Discover and parse `.docstratum.yml`. Apply precedence rules. |
| 2.8.6 | Implement Tier 1 and Tier 2 output renderers | 2 | Tier 1: exit code + minimal JSON. Tier 2: structured diagnostic list in JSON/Markdown. |
| 2.8.7 | Write CLI integration tests | 2 | End-to-end tests: run CLI against fixtures, verify output format and exit codes. |

---

## Lane 4: Benchmark

> **Epic 4: Empirical Benchmark — Context Collapse Mitigation Study**
> **Repository:** `llmstxt-research` | **Lane Phases:** Design → Collect → Run → Analyze
> **Lane color:** Deep Gold (`#B9770E`)

Conduct the first controlled empirical study measuring whether llms.txt-curated content reduces context collapse in LLM responses. 30–50 websites, paired HTML vs. Markdown content, multiple local LLMs, five measured dimensions.

**Epic-Level Acceptance Criteria:**

- Methodology document reviewed by at least 1 external reviewer
- Test corpus of 30–50 sites with both llms.txt and HTML documentation
- Gold-standard answer set authored for all questions
- Data collection completed across all (site, question, model, condition) tuples
- Analysis notebook produces all figures and statistical tests
- Write-up published as Markdown + PDF
- Raw data published as CSV for reproducibility

**Lane-specific guidance:** The Design phase is fully independent — start it now. The Collect phase has a hard dependency on Lane 2's `llmstxt_compare` tool. The ref repo's `domains.md` provides your initial corpus list. Content preprocessing should match the reference implementation (strip HTML comments, base64 images).

---

### Story 4.1: Corpus Selection and Question Authoring

**Description:** Build the test corpus of 30–50 websites and author 5–10 factual questions per site with gold-standard answers.
**Lane Phase:** Design | **Target Weeks:** 3–6 | **Points:** 13
**Dependencies:** None (can begin in parallel with LlmsTxtKit development)
**Acceptance Criteria:**
- `benchmark/corpus/site-list.csv` populated with 30–50 sites
- Sites span at least 3 sectors beyond developer documentation
- Each site verified to have a well-formed llms.txt file and ≥5 Markdown-linked pages
- `benchmark/corpus/questions.json` authored with complexity ratings
- `benchmark/corpus/gold-answers.json` authored with definitive answers
- `benchmark/corpus/scoring-rubric.md` defines all scoring criteria with examples

**Tasks:**

| # | Task | Points | Description |
|---|---|---|---|
| 4.1.1 | Define corpus selection criteria | 1 | Minimum requirements: well-formed llms.txt, ≥5 Markdown pages, substantive content. Diversity requirements: ≥3 non-devtools sectors. |
| 4.1.2 | Source and evaluate candidate sites | 3 | Search llms.txt directories (llmstxt.site, directory.llmstxt.cloud). Cross-reference with ref repo `nbs/domains.md` for curated candidates. Manually evaluate. Record in `site-list.csv`. |
| 4.1.3 | Author questions for first 15 sites | 3 | 5–10 questions per site varying in complexity. Include single-fact, multi-section synthesis, and conceptual relationship questions. |
| 4.1.4 | Author questions for remaining sites | 2 | Complete question authoring for full corpus. |
| 4.1.5 | Author gold-standard answers | 2 | Definitive correct answer for every question. Sourced directly from site content. |
| 4.1.6 | Write scoring rubric | 2 | Define 0–3 accuracy scale with examples at each level. Define hallucination categories. Define completeness and citation fidelity criteria. |

---

### Story 4.2: Methodology Specification and Review

**Description:** Write the detailed methodology document and have it reviewed before data collection begins.
**Lane Phase:** Design | **Target Weeks:** 5–7 | **Points:** 8
**Dependencies:** Story 4.1 (corpus selection informs methodology details)
**Acceptance Criteria:**
- `benchmark/methodology.md` fully written
- Experimental design documented: conditions, controls, variables, measurement protocol
- Model selection documented with justification
- Statistical analysis plan documented (paired tests, effect sizes)
- At least 1 external reviewer has reviewed methodology
- Pilot run completed on ≥5 sites to validate the pipeline

**Tasks:**

| # | Task | Points | Description |
|---|---|---|---|
| 4.2.1 | Write methodology document | 3 | Full experimental design: content pairs, question set, models under test, measurement protocol, scoring, statistical analysis plan. |
| 4.2.2 | Define model selection | 1 | Choose models: ≥1 per family (Llama, Mistral, Qwen, Gemma). Multiple parameter sizes. Document versions, quantization, inference parameters. |
| 4.2.3 | Write `benchmark-config.json` | 1 | Exact model specs, API endpoints, prompt templates, output format. |
| 4.2.4 | Solicit methodology review | 1 | Contact ≥1 reviewer per Roadmap guidelines. Specific feedback on experimental design. |
| 4.2.5 | Run pilot study (≥5 sites) | 2 | End-to-end pipeline test. Validate data collection, scoring, and analysis notebook structure. Identify issues before full run. |

---

### Story 4.3: Data Collection Infrastructure

**Description:** Build the C# data collection runner that orchestrates the full experimental run.
**Lane Phase:** Collect | **Target Weeks:** 7–10 | **Points:** 8
**Dependencies:** Lane 2, Story 3.4 (`llmstxt_compare` tool functional)
**Acceptance Criteria:**
- Data collection runner orchestrates: content pair generation → prompt submission → response recording
- Uses LlmsTxtKit's `llmstxt_compare` for content pairs
- Content preprocessing matches reference implementation (strip HTML comments, base64 images)
- Submits to local LLM endpoints (LM Studio or Ollama API)
- Writes structured output to CSV/JSON
- Handles failures gracefully (retries, skip-and-log)
- Tested against pilot corpus (≥5 sites)

**Tasks:**

| # | Task | Points | Description |
|---|---|---|---|
| 4.3.1 | Build data collection runner scaffold | 2 | C# console app. Configuration loading from `benchmark-config.json`. |
| 4.3.2 | Integrate LlmsTxtKit for content pair generation | 2 | Call `llmstxt_compare` for each site. Store HTML and Markdown versions. Strip HTML comments and base64 images from Markdown content per reference implementation behavior. |
| 4.3.3 | Implement LLM inference submission | 2 | HTTP calls to local model endpoints. System prompt + content + question. Record response. |
| 4.3.4 | Implement structured output writing | 1 | Write to `raw-data.csv` with all columns: site, question, model, condition, tokens, response, etc. |
| 4.3.5 | Implement error handling and resumability | 1 | Graceful failure handling. Checkpoint progress. Resume from last completed tuple. |

---

### Story 4.4: Data Collection and Scoring

**Description:** Run the full experimental protocol across all sites, models, and conditions. Score all responses.
**Lane Phase:** Run | **Target Weeks:** 9–14 | **Points:** 13
**Dependencies:** Stories 4.1, 4.2, 4.3 (corpus, methodology, infrastructure ready)
**Acceptance Criteria:**
- Data collection completed for all (site, question, model, condition) tuples
- `benchmark/results/raw-data.csv` populated with complete experimental data
- All responses scored against gold-standard answers
- Scoring consistent with rubric (spot-check for inter-rater reliability)
- Data quality flags documented (failed runs, timeouts, empty responses)

**Tasks:**

| # | Task | Points | Description |
|---|---|---|---|
| 4.4.1 | Execute full data collection run | 5 | Run all experimental conditions on Mac Studio. Monitor for failures. Estimated: several days of compute time. |
| 4.4.2 | Score all responses: factual accuracy | 3 | Apply 0–3 scale against gold-standard answers. Systematic, rubric-adherent. |
| 4.4.3 | Score all responses: hallucination count | 2 | Count hallucinated claims per response. Categorize where feasible. |
| 4.4.4 | Score all responses: completeness and citation fidelity | 1 | Binary completeness. Citation fidelity where applicable. |
| 4.4.5 | Data quality review | 2 | Check for anomalies, incomplete runs, scoring inconsistencies. Document in data quality section. |

---

### Story 4.5: Analysis Notebook and Write-Up

**Description:** Build the Colab-compatible analysis notebook and write the benchmark study's final write-up.
**Lane Phase:** Analyze | **Target Weeks:** 12–16 | **Points:** 13
**Dependencies:** Story 4.4 (data collection and scoring complete)
**Acceptance Criteria:**
- `benchmark/results/analysis.ipynb` produces all figures and statistical tests
- Notebook is Colab-compatible (zero .NET dependencies)
- All 8 notebook sections from the proposal implemented
- `benchmark/write-up.md` written (4,000–8,000 words)
- `benchmark/write-up.pdf` rendered
- `benchmark/REPRODUCING.md` written with full reproducibility instructions

**Tasks:**

| # | Task | Points | Description |
|---|---|---|---|
| 4.5.1 | Build analysis notebook: Sections 1–3 | 3 | Data loading/validation, token efficiency analysis, factual accuracy comparison. Statistical tests. Figures 1–2, Tables 1–2. |
| 4.5.2 | Build analysis notebook: Sections 4–6 | 3 | Hallucination rate, completeness/citation fidelity, composite analysis. Figures 3–5, Tables 3–4. |
| 4.5.3 | Build analysis notebook: Sections 7–8 | 2 | Freshness/staleness check, summary and key findings. Figure 6, Table 5, consolidated results. |
| 4.5.4 | Write benchmark write-up | 3 | 4,000–8,000 words. Methodology, results, analysis, limitations. References notebook figures/tables. |
| 4.5.5 | Write REPRODUCING.md | 1 | Hardware requirements, data collection steps, notebook execution steps, verification instructions. |
| 4.5.6 | Render PDF and verify | 1 | Produce `write-up.pdf`. Verify figures render correctly. |

---

### Story 4.6: Benchmark Publication

**Description:** Finalize and publish all benchmark artifacts.
**Lane Phase:** Analyze | **Target Weeks:** 15–16 | **Points:** 5
**Dependencies:** Story 4.5
**Acceptance Criteria:**
- All deliverables committed to `llmstxt-research`
- README status updated
- Raw data CSV, analysis notebook, and write-up PDF all accessible
- "Open in Colab" badge on benchmark README
- Shared on target platforms

**Tasks:**

| # | Task | Points | Description |
|---|---|---|---|
| 4.6.1 | Final review of all artifacts | 2 | Cross-check write-up against notebook outputs. Verify reproducibility. |
| 4.6.2 | Update README status indicators | 1 | llmstxt-research README benchmark status. |
| 4.6.3 | Add Colab badge and verify | 1 | "Open in Colab" badge on benchmark README. Test that the notebook runs in Colab. |
| 4.6.4 | Publish and announce | 1 | Share on target platforms. Create GitHub Discussion. |

---

## Lane 5: Blog & Content

This lane contains two epics that work together: the 8-post blog series (Epic 5) and the blog's own llms.txt dogfooding (Epic 6).

---

> **Epic 5: Blog Series — 8-Post Publication Pipeline**
> **Repository:** `llmstxt-research` (drafts) + `southpawriter-blog` (publication)
> **Lane Phases:** Post 1 → Post 2 → ... → Post 8 (sequential, ~biweekly)
> **Lane color:** Deep Red (`#922B21`)

Eight blog posts published over the initiative's timeline, each sharing research findings while demonstrating GEO best practices. Posts progress from personal narrative (Post 1) through research summaries, ecosystem analysis, and practitioner guides to a synthesis post (Post 8).

**Epic-Level Acceptance Criteria:**

- All 8 posts drafted in `llmstxt-research/blog/`
- All 8 posts adapted and published on the Docusaurus blog
- Tags taxonomy expanded in `tags.yml`
- Author entry configured in `authors.yml`
- Each post shared on ≥2 relevant platforms
- Publication cadence maintained at approximately one post per two weeks

**Lane-specific guidance:** Each post has a specific upstream dependency from another lane. Posts 1–2 can be written as soon as the paper's early sections are drafted. Posts 3–5 require working software. Posts 6–8 require benchmark results or complete tooling. The blog's own llms.txt is a continuous dogfooding target for Lane 3 (DocStratum).

---

### Stories 5.1–5.8: Individual Blog Posts

Each blog post follows the same story structure. The pattern is defined once; specifics vary per post.

**Standard Blog Post Story Template:**
- **Acceptance Criteria (per post):** Draft complete in `llmstxt-research/blog/`. Adapted to Docusaurus format. Social card image created. Built and previewed locally. Published. Shared on ≥2 platforms.
- **Standard Tasks (per post):**

| # | Task | Points | Description |
|---|---|---|---|
| x.x.1 | Outline and research | 1–2 | Sketch argument, identify key data points, gather citations. |
| x.x.2 | Write first draft | 2–3 | Full draft in `llmstxt-research/blog/`. |
| x.x.3 | Self-review and revision | 1 | Factual accuracy, GEO practices, citation completeness. |
| x.x.4 | Apply GEO best practices | 1 | Implement Generative Engine Optimization practices: structured data, definitive statements, citation-rich writing, concise entity descriptions, FAQ schema where appropriate. Verify with GEO checklist. |
| x.x.5 | Adapt for Docusaurus and publish | 1 | Front matter conversion, `<!-- truncate -->` marker, social card, build preview, commit. |
| x.x.6 | Share on platforms | 1 | Post on ≥2 relevant platforms per community engagement strategy. |

**Post-Specific Details:**

| Story | Post | Type | Weeks | Points | Upstream Dependency | Key Notes |
|---|---|---|---|---|---|---|
| 5.1 | Post 1: "My Own Firewall Said No" | Personal narrative + technical deep dive | 1–2 | 5 | None | First post. Sets voice. 2,000–2,500 words. |
| 5.2 | Post 2: "What the Data Shows" | Research summary (Paper condensed) | 4–5 | 5 | Lane 1, Story 1.3 (paper first draft) | Condenses paper findings. 3,000–4,000 words. |
| 5.3 | Post 3: "Zero .NET Tools" | Project announcement + ecosystem survey | 6–7 | 5 | Lane 2, Story 3.1 (LlmsTxtKit specs) | Announces LlmsTxtKit. 2,500–3,000 words. |
| 5.4 | Post 4: "Tech Writer's GEO Guide" | Practitioner guide | 8–9 | 8 | None (original synthesis) | Full writing effort. Princeton GEO study. 3,000–3,500 words. |
| 5.5 | Post 5: "Content Signals Landscape" | Comparative analysis | 10–11 | 8 | Lane 1, Story 1.3 (paper Thread 4) | Reference guide. Side-by-side comparison. 3,500–4,500 words. |
| 5.6 | Post 6: "Does Clean Markdown Help?" | Benchmark results | 14–16 | 5 | Lane 4, Story 4.5 (analysis notebook) | Condenses benchmark. 3,000–4,000 words. |
| 5.7 | Post 7: "MCP Server in C#" | Technical tutorial | 12–14 | 5 | Lane 2, Story 3.6 (LlmsTxtKit v1.0) | Code examples. 3,000–4,000 words. |
| 5.8 | Post 8: "What Howard Got Right" | Synthesis | 16–18 | 8 | All lanes substantially complete | Ties everything together. 3,500–4,500 words. |

---

> **Epic 6: Blog llms.txt Dogfooding — Living Test Subject**
> **Repository:** `southpawriter-blog` + `docstratum`
> **Lane Phases:** Baseline → Field Test → Observe

Use the blog's own `llms.txt` file as a living test subject for DocStratum's validation rules. This provides a controlled environment for iterating on llms.txt structure, observing how LLMs consume the content, and feeding observations back into validation rules.

**Epic-Level Acceptance Criteria:**

- Blog's `llms.txt` validated by DocStratum at each major validator milestone
- Validation results documented with observations about rule effectiveness
- At least 3 feedback loop iterations (validate → observe → adjust → re-validate)
- Observations incorporated into DocStratum's calibration data

---

### Story 6.1: Baseline Validation

**Description:** Run DocStratum's current parser (v0.2.x) against the blog's `llms.txt` and document the baseline state.
**Lane Phase:** Baseline | **Points:** 3
**Dependencies:** None (parser already complete)
**Acceptance Criteria:**
- Blog's `llms.txt` parsed by DocStratum v0.2.x
- Parse results documented: document type, sections found, link counts, token estimates
- Any parser issues identified and filed as DocStratum issues
- Baseline report saved for comparison with future validation runs

**Tasks:**

| # | Task | Points | Description |
|---|---|---|---|
| 6.1.1 | Run DocStratum parser against blog llms.txt | 1 | Execute parser. Record full output. |
| 6.1.2 | Document baseline results | 1 | Write baseline report: type classification, sections, links, tokens, any parse warnings. |
| 6.1.3 | File any parser issues discovered | 1 | If the blog's llms.txt exposes parser edge cases, file them in the docstratum repo. Note: the blog uses H3 sub-sections within H2, which are valid but structurally invisible to the reference parser. |

---

### Story 6.2: Validation Rule Field Testing

**Description:** As DocStratum's validation engine (v0.3.x) comes online, run each new validation level against the blog's llms.txt. Document which rules pass, which fail, and whether the failures represent genuine quality issues or rule calibration problems.
**Lane Phase:** Field Test | **Points:** 5
**Dependencies:** Lane 3, Stories 2.6, 2.7 (validation engine)
**Acceptance Criteria:**
- L0–L3 validation run against blog llms.txt
- Each failing rule analyzed: genuine issue vs. calibration problem
- Calibration feedback filed as DocStratum issues
- Blog llms.txt iteratively improved based on genuine findings

**Tasks:**

| # | Task | Points | Description |
|---|---|---|---|
| 6.2.1 | Run L0–L1 validation and analyze | 1 | Document results. Classify failures. |
| 6.2.2 | Run L2–L3 validation and analyze | 2 | Document results. Identify calibration issues. File DocStratum issues for rule adjustments. |
| 6.2.3 | Improve blog llms.txt based on findings | 1 | Fix genuine quality issues. Document what changed and why. |
| 6.2.4 | Re-validate and document improvement | 1 | Run validation again. Compare to baseline. Document the feedback loop. |

---

### Story 6.3: LLM Consumption Observation

**Description:** Test how different LLMs actually consume the blog's llms.txt content. Observe whether the structure helps, what gets misinterpreted, and whether section organization affects response quality.
**Lane Phase:** Observe | **Points:** 5
**Dependencies:** Story 6.2, Lane 2 (LlmsTxtKit for content retrieval)
**Acceptance Criteria:**
- At least 3 LLMs tested with blog llms.txt content as context
- Observations documented: what worked well, what was misinterpreted, structural impacts
- Findings fed back into DocStratum validation rules where applicable
- Summary report available for use in blog posts or paper revisions

**Tasks:**

| # | Task | Points | Description |
|---|---|---|---|
| 6.3.1 | Design observation protocol | 1 | Define test questions, models, evaluation criteria. |
| 6.3.2 | Run LLM consumption tests | 2 | Submit blog content via llms.txt to ≥3 models. Record responses. |
| 6.3.3 | Analyze and document observations | 1 | What worked? What didn't? Structural impacts? |
| 6.3.4 | File feedback into DocStratum | 1 | Translate observations into validation rule suggestions or calibration adjustments. |

---

## Lane 6: Cross-Cutting

> **Epic 7: Cross-Cutting Infrastructure — CI/CD, Project Scaffolding & Ops**
> **Repository:** All repos | **Lane Phases:** Setup → Ongoing
> **Lane color:** Slate Gray (`#566573`)

Establish the project management infrastructure, CI/CD pipelines, repository scaffolding, and operational tooling that supports all other lanes. This is the "before we start building" work.

**Epic-Level Acceptance Criteria:**

- GitHub Project created and configured with all views and custom fields
- All repos have GitHub Issues populated from this blueprint
- All repos have consistent labeling
- CI/CD pipelines operational (at minimum: linting, testing, coverage)
- Cross-repo dependency tracking functional
- Shared bibliography and glossary maintained

**Lane-specific guidance:** The Setup tasks should be done first — they take 30 minutes and give you a centralized view of everything. The Ongoing tasks are maintenance habits, not discrete work items. Weekly reviews against the roadmap are how you avoid drifting.

---

### Story 7.1: GitHub Project Setup

**Description:** Create the user-level GitHub Project and configure all views, custom fields, and automation.
**Lane Phase:** Setup | **Points:** 5
**Dependencies:** This blueprint (approved)
**Acceptance Criteria:**
- GitHub Project created under Ryan's account
- All 6 views configured (Backlog, Sprint Board, Dependency Tracker, Timeline, By Lane, By Repository)
- All custom fields created (Lane, Epic, Story Points, Lane Phase, Phase, Blocked By, Target Week, Repository, Iteration)
- Project linked to all 4 repositories

**Tasks:**

| # | Task | Points | Description |
|---|---|---|---|
| 7.1.1 | Create GitHub Project | 1 | User-level project. Name: "llms.txt Research & Tooling Initiative". |
| 7.1.2 | Configure custom fields | 1 | All 9 fields from §3 of this blueprint. |
| 7.1.3 | Create project views | 2 | All 6 views with appropriate grouping and filtering. |
| 7.1.4 | Link repositories | 1 | Add all 4 repos to the project. |

---

### Story 7.2: Repository Label Standardization

**Description:** Apply the consistent label taxonomy across all four repositories.
**Lane Phase:** Setup | **Points:** 3
**Dependencies:** Story 7.1
**Acceptance Criteria:**
- All type, lane, domain, status, and priority labels created in all 4 repos
- Consistent colors and descriptions across repos
- Any existing labels reconciled (renamed, merged, or deprecated)

**Tasks:**

| # | Task | Points | Description |
|---|---|---|---|
| 7.2.1 | Create labels in `llmstxt-research` | 1 | All labels from §2 taxonomy (type, lane, domain, status, priority). |
| 7.2.2 | Create labels in `LlmsTxtKit` | 1 | All labels from §2 taxonomy. |
| 7.2.3 | Create labels in `docstratum` and `southpawriter-blog` | 1 | All labels from §2 taxonomy. Reconcile any existing labels. |

---

### Story 7.3: Issue Population from Blueprint

**Description:** Create GitHub Issues for all stories and high-priority tasks from this blueprint. Link them to the project board.
**Lane Phase:** Setup | **Points:** 8
**Dependencies:** Stories 7.1, 7.2
**Acceptance Criteria:**
- All 44 stories created as GitHub Issues in appropriate repos (43 original + Story 2.5a)
- All critical/high-priority tasks created as sub-issues or linked issues
- All issues tagged with correct labels and custom field values (including Lane and Lane Phase)
- Cross-repo dependencies documented with `Blocked By` links
- All issues added to the GitHub Project

**Tasks:**

| # | Task | Points | Description |
|---|---|---|---|
| 7.3.1 | Create Epic issues (7 total) | 1 | One issue per epic with description, scope, and acceptance criteria. Tag with lane label. |
| 7.3.2 | Create Story issues for Lanes 1–2 | 2 | Stories 1.1–1.6 and 3.1–3.7 with full acceptance criteria and task checklists. |
| 7.3.3 | Create Story issues for Lanes 3–4 | 2 | Stories 2.1–2.8, 2.5a, and 4.1–4.6 with full acceptance criteria and task checklists. |
| 7.3.4 | Create Story issues for Lanes 5–6 | 2 | Stories 5.1–5.8, 6.1–6.3, 7.1–7.5 with full acceptance criteria and task checklists. |
| 7.3.5 | Link cross-repo dependencies | 1 | Add `Blocked By` URLs to all blocked items. Apply `blocked` label where appropriate. |

---

### Story 7.4: CI/CD Pipeline Setup

**Description:** Configure GitHub Actions workflows for automated linting, testing, and coverage reporting in the two code repositories.
**Lane Phase:** Setup | **Points:** 5
**Dependencies:** None (can proceed in parallel with other Setup work)
**Acceptance Criteria:**
- `docstratum`: GitHub Actions workflow runs pytest, black, ruff, mypy, coverage on every PR
- `LlmsTxtKit`: GitHub Actions workflow runs dotnet build, dotnet test, coverage on every PR
- Coverage reports generated and accessible
- Build status badges added to both READMEs

**Tasks:**

| # | Task | Points | Description |
|---|---|---|---|
| 7.4.1 | Create DocStratum CI workflow | 2 | `.github/workflows/ci.yml`. Python 3.11+. Run black, ruff, mypy, pytest with coverage. Fail on coverage <90%. |
| 7.4.2 | Create LlmsTxtKit CI workflow | 2 | `.github/workflows/ci.yml`. .NET 8 SDK. Build, test, coverage. |
| 7.4.3 | Add build status badges | 1 | Both READMEs get CI status and coverage badges. |

---

### Story 7.5: Shared Research Artifacts

**Description:** Establish and maintain the shared bibliography, glossary, and cross-project reference materials.
**Lane Phase:** Ongoing | **Points:** 5
**Dependencies:** None
**Acceptance Criteria:**
- `shared/references.md` populated with all known sources (from proposal Appendix B and additional discoveries, including reference repo artifacts)
- `shared/glossary.md` populated with key terms
- Both artifacts maintained as living documents throughout the initiative

**Tasks:**

| # | Task | Points | Description |
|---|---|---|---|
| 7.5.1 | Populate shared bibliography | 2 | Migrate all sources from proposal Appendix B. Add new sources discovered during evidence gathering. Include reference repo artifact entries. Consistent citation format. |
| 7.5.2 | Populate shared glossary | 2 | Define key terms: llms.txt, GEO, context collapse, WAF, MCP, Content Signals, ASoT, etc. Cross-link to blog glossary on the Docusaurus site. |
| 7.5.3 | Document maintenance process | 1 | Note in both files: who updates them, when, and how conflicts are resolved. |
| 7.5.4 | Weekly progress review against roadmap | — | Ongoing habit: review progress against the Lane-Based Roadmap weekly. Update status checkboxes or GitHub Project board. Identify blocked items, adjust priorities, and note any new cross-lane dependencies. Not a completable task — tracked as a recurring practice. |
| 7.5.5 | Keep reference repo analysis doc current | — | Ongoing: as the `AnswerDotAI/llms-txt` repo evolves, update `llms-txt-reference-repo-analysis.md` with any behavioral changes that affect LlmsTxtKit or DocStratum. Not a completable task — tracked as a recurring practice. |

---

## 11. Cross-Lane Dependency Map

### Flow Dependencies

These show what each lane produces that other lanes consume. When you're blocked in one lane, this table tells you which upstream lane needs attention.

| From | → | To | What Flows |
|---|---|---|---|
| **Ref Repo** | → | Lane 2 (Toolkit) | Canonical parsing behavior, regex patterns, XML format, Optional default |
| **Ref Repo** | → | Lane 3 (Validator) | Spec ground truth, extension labeling, blockquote behavior |
| **Ref Repo** | → | Lane 1 (Paper) | Evidence items 2.6–2.7, domains.md for adoption stats |
| **Ref Repo** | → | Lane 4 (Benchmark) | domains.md for corpus selection, content preprocessing rules |
| Lane 2 (Toolkit) | → | Lane 4 (Benchmark) | `llmstxt_compare` tool for paired content data collection |
| Lane 4 (Benchmark) | → | Lane 1 (Paper) | Empirical results for §9 (Research Gaps) |
| Lane 4 (Benchmark) | → | Lane 3 (Validator) | Evidence-based quality thresholds for L2–L3 calibration |
| Lane 3 (Validator) | → | Lane 2 (Toolkit) | Quality definitions informing validator rule alignment |
| Lane 1 (Paper) | → | Lane 5 (Blog) | Research findings translated into practitioner posts |
| Lane 5 (Blog) | → | Lane 3 (Validator) | Blog llms.txt as living validation test subject |

### Critical Path Dependencies (Story-Level)

These define the longest chain of sequential work — the critical path that determines the minimum timeline.

```
Lane 6: [S7.1] GitHub Project Setup → [S7.3] Issue Population → All work begins

Lane 3: [S2.1] Output Tier Spec (ROOT BLOCKER)
    → [S2.2] Remediation Framework
    → [S2.3] Unified Rule Registry
        → [S2.4] Validation Profiles
            → [S2.5] Report Generation + Calibration
                → [S2.6] Implement L0–L1
                    → [S2.7] Implement L2–L3
                        → [S2.8] Quality Scoring + CLI

Lane 2: [S3.1] Specs
    → [S3.2] Parser + Fetcher
        → [S3.3] Validator + Cache + Context
            → [S3.4] MCP Server
                → [S3.5] Integration Tests
                    → [S3.6] Release

Lane 4: [S3.4] MCP Server (llmstxt_compare) ← crosses from Lane 2
    → [S4.3] Benchmark Data Collection Infrastructure
        → [S4.4] Data Collection
            → [S4.5] Analysis + Write-Up
                → [S4.6] Benchmark Publication
```

### Cross-Lane Story Dependencies

| Blocked Story | Lane | Blocked By | Source Lane | Nature of Dependency |
|---|---|---|---|---|
| Story 4.3 (Benchmark infrastructure) | 4 | Story 3.4 (MCP server — `llmstxt_compare`) | 2 | Benchmark data collection requires LlmsTxtKit's compare tool |
| Story 1.6 (Paper revision) | 1 | Story 4.5 (Benchmark analysis) | 4 | Paper revision incorporates benchmark findings |
| Story 5.2 (Blog Post 2) | 5 | Story 1.3 (Paper first draft) | 1 | Post condenses paper findings |
| Story 5.3 (Blog Post 3) | 5 | Story 3.1 (LlmsTxtKit specs) | 2 | Post announces LlmsTxtKit with design spec details |
| Story 5.6 (Blog Post 6) | 5 | Story 4.5 (Benchmark analysis) | 4 | Post condenses benchmark results |
| Story 5.7 (Blog Post 7) | 5 | Story 3.6 (LlmsTxtKit v1.0) | 2 | Tutorial requires stable API |
| Story 5.8 (Blog Post 8) | 5 | All lanes substantially complete | All | Synthesis requires everything |
| Story 6.2 (Dogfooding validation) | 5 | Stories 2.6, 2.7 (DocStratum validation engine) | 3 | Need validation engine to validate the blog's llms.txt |
| Story 6.3 (LLM consumption) | 5 | Story 3.3 (LlmsTxtKit context gen) | 2 | Need content retrieval tooling |
| Story 3.7 (Post-release fixes) | 2 | Story 4.4 (Benchmark data collection) | 4 | Bugs discovered during benchmark usage |

### Parallelizable Work (by Phase)

- **Phase 1 (Foundations):** Lane 1 Gather (1.1, 1.2) ‖ Lane 2 Spec (3.1) ‖ Lane 3 Design (2.1–2.4, 2.5a) ‖ Lane 4 Design (4.1) ‖ Lane 5 Post 1 (5.1) ‖ Lane 6 Setup (7.1–7.5)

- **Phase 2 (Implementation):** Lane 1 Write/Review (1.3, 1.4) ‖ Lane 2 Build (3.2–3.4) ‖ Lane 3 Build (2.6–2.7) ‖ Lane 4 Design+Collect (4.1–4.3) ‖ Lane 5 Posts 2–3 (5.2–5.3)

- **Phase 3 (Experimentation):** Lane 2 Test/Ship (3.5, 3.6) ‖ Lane 3 Build (2.8) ‖ Lane 4 Run (4.4) ‖ Lane 5 Posts 4–5, 7 (5.4, 5.5, 5.7)

- **Phase 4 (Synthesis):** Lane 1 Review (1.6) ‖ Lane 4 Analyze (4.5, 4.6) ‖ Lane 5 Posts 6, 8 (5.6, 5.8) ‖ Lane 3 Calibrate

---

## 12. Milestone Definitions

GitHub Milestones group issues into time-bounded delivery targets. These milestones align with the cross-project phases while the lane structure provides the within-phase navigation.

| Milestone | Phase | Target Weeks | Exit Criteria |
|---|---|---|---|
| **Phase 0: Setup** | 0 | Pre-Week 1 | GitHub Project configured. Labels standardized. Blueprint approved. |
| **Phase 1: Foundations** | 1 | Weeks 1–4 | Paper first draft complete. LlmsTxtKit specs complete. DocStratum design backlog items 1–4 complete. Extension labeling audit complete. Blog Post 1 published. Benchmark corpus ≥50% populated. |
| **Phase 2: Implementation** | 2 | Weeks 5–10 | Paper finalized. LlmsTxtKit Core functional. DocStratum L0–L3 validation implemented. Benchmark methodology reviewed. Blog Posts 2–3 published. |
| **Phase 3: Experimentation** | 3 | Weeks 9–14 | Paper published. LlmsTxtKit v1.0 released. Benchmark data collection complete. DocStratum CLI operational. Blog Posts 4–5, 7 published. |
| **Phase 4: Synthesis** | 4 | Weeks 15–18 | Benchmark published. Paper revised with benchmark data. Blog Posts 6, 8 published. All lanes substantially complete. |

---

## 13. Where to Start Right Now

If you're looking at this and thinking "okay, but what do I literally do tomorrow morning?" — here's the recommended sequence of first moves, designed to maximize parallel progress across lanes while respecting dependencies:

1. **Lane 6 Setup tasks** (30 min) — Create the GitHub Projects board. This gives you a single place to track everything and makes the rest of the lanes feel less scattered.

2. **Lane 2 Spec phase** (2–3 sessions) — Complete the user-stories.md and test-plan.md stubs. This unblocks all Build work in Lane 2, which in turn unblocks Lane 4's data collection.

3. **Lane 1 Gather phase** (parallel with Lane 2) — Start compiling evidence. This is pure research — no code, no dependencies. Every source you gather now becomes a sentence in the paper later.

4. **Lane 4 Design phase** (parallel with Lanes 1–2) — Finalize the benchmark methodology and select the corpus from the ref repo's `domains.md`. This is also pure design work with no code dependencies.

5. **Lane 3 Design phase** (parallel) — Label which DocStratum rules are spec-compliant vs. extensions (Story 2.5a). Resolve the documentation backlog. This is independent and can run alongside everything else.

The first five moves are all parallelizable. By the time you've finished them, Lane 2's Build phase is unblocked, Lane 4 is ready for data collection (pending the `llmstxt_compare` tool), and Lane 1 has enough evidence to start drafting. That's the moment the lanes stop being a plan and start producing output.

---

## 14. Implementation Plan for This Blueprint

This blueprint itself needs to be turned into action. Here's the sequence:

1. **Review this document.** Ryan reviews the lane/epic/story/task breakdown for completeness, accuracy, and priority alignment. Flag anything that's wrong, missing, or over-scoped.

2. **Approve the taxonomy.** Confirm the label scheme (including lane labels), custom fields, and view structure before creating anything in GitHub.

3. **Create the GitHub Project.** Execute Story 7.1 (project setup) and Story 7.2 (label standardization).

4. **Populate issues.** Execute Story 7.3 (issue population). This can be partially automated — the story descriptions and task lists in this blueprint translate directly into issue bodies with checkbox task lists.

5. **Begin Phase 1 work.** With the board populated, the first sprint can be planned by pulling from the Phase 1 stories across all lanes (see §13).

6. **Iterate.** This blueprint is a living document. As work progresses, stories will be refined, tasks will be added or removed, and point estimates will be revised. The GitHub Project is the source of truth for current status; this document is the architectural reference for why the work is structured this way. The Lane-Based Roadmap (`llmstxt-lane-roadmap.docx`) remains the high-level orientation guide.

---

## Appendix A: Story Point Calibration Guide

To keep estimates consistent:

| Points | Meaning | Example |
|---|---|---|
| 1 | Trivial — less than 1 hour | Create a single configuration file |
| 2 | Small — half a day | Write a short specification section |
| 3 | Medium — a full day | Implement a single component with tests |
| 5 | Large — 2–3 days | Write a major specification document |
| 8 | Very large — a week | Implement a complete subsystem with tests |
| 13 | Epic-sized — should usually be decomposed | Full first draft of a paper or full data collection run |

---

## Appendix B: Naming Conventions for GitHub Issues

**Epic Issues:** `[EPIC] {Epic Name}`
- Example: `[EPIC] Analytical Paper — The llms.txt Access Paradox`

**Story Issues:** `[L{lane}-E{epic}] {Story Name}`
- Example: `[L1-E1] Research Consolidation and Evidence Gathering`
- Example: `[L2-E3] Implement Parser and Fetcher`

**Task Issues (when created as separate issues):** `[L{lane}-S{story}] {Task Name}`
- Example: `[L1-S1.1] Create evidence inventory template`

**Most tasks should be tracked as checkboxes within their parent Story issue** rather than as separate issues. Create separate task issues only when the task is large enough to warrant its own discussion thread, is a cross-repo dependency, or needs to be independently assigned.

---

## Appendix C: How This Blueprint Relates to Existing Documents

| Existing Document | Relationship |
|---|---|
| `llmstxt-lane-roadmap.docx` | The roadmap is the high-level orientation guide; this blueprint is the detailed operational decomposition. The roadmap's six lanes map 1:1 to this blueprint's six lane sections. Use the roadmap to decide *where to focus*; use the blueprint to decide *what to do*. |
| `llmstxt-project-proposals.md` | This blueprint decomposes the proposal's deliverables into trackable work items. The proposal describes *what* and *why*; the blueprint describes *how* and *when*. |
| `ROADMAP.md` | The roadmap's phased delivery schedule and ongoing efforts are reflected in the milestone definitions and story timelines. The blueprint adds the task-level decomposition the roadmap lacks. |
| `southpawriter-content-strategy.md` | The content strategy's recommendations for docs sections, blog content, and site structure inform Lane 5 (Blog & Content). |
| DocStratum `RR-META-documentation-backlog.md` | Stories 2.1–2.5 directly correspond to the 6 backlog items. The blueprint preserves the backlog's dependency chain and exit criteria verbatim. |
| LlmsTxtKit `specs/prs.md` and `specs/design-spec.md` | Stories 3.2–3.4 decompose the PRS success criteria and Design Spec component responsibilities into implementable tasks. |
| LlmsTxtKit `specs/user-stories.md` (stub) | Story 3.1 includes completing this stub as a task. |
| LlmsTxtKit `specs/test-plan.md` (stub) | Story 3.1 includes completing this stub as a task. |
| `AnswerDotAI/llms-txt` (reference repo) | The canonical Python implementation. Its `miniparse.py` defines the behavioral baseline for both LlmsTxtKit's parser and DocStratum's validation criteria. Its `nbs/domains.md` informs benchmark corpus selection (Story 4.1). Its `core.py` context generation behavior informs LlmsTxtKit's Design Spec §2.5. Full analysis in `llms-txt-reference-repo-analysis.md`. |
| `llms-txt-reference-repo-analysis.md` | Documents the findings from analyzing the reference repo. Informs Story 2.5a (extension labeling), Stories 3.2/3.3 (parser/context behavioral alignment), and Story 4.1 (corpus sourcing). |

---

*End of blueprint. Version 2.0 — February 14, 2026.*
*v2.0 reorganizes the document around the six-lane structure from the Lane-Based Roadmap, adds lane labels and lane-phase custom fields, adds Story 2.5a (Extension Labeling Audit), integrates reference repo analysis work items throughout, and adds the "Where to Start Right Now" section.*
