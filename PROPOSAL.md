# The llms.txt Research & Tooling Initiative

## Unified Project Proposal — February 2026

**Author:** Ryan  
**Version:** 1.1 — Draft  
**Status:** Proposal  
**Revision Notes:** v1.1 adds research output format strategy (Paper = prose + optional data notebook, Benchmark = C# data collection + Colab-compatible Jupyter analysis), repository structure (two-repo split with full directory trees), and detailed analysis notebook section outline.

---

## Executive Summary

This document proposes three interconnected projects that address a critical, under-documented gap in the AI-web infrastructure: the disconnect between how the llms.txt standard was *designed* to work, how it *actually* works in practice, and what tooling is needed to bridge that gap. Together, these projects form a cohesive research-and-implementation initiative that produces original analysis, working software, and empirical data — positioning the author as a credible, evidence-driven voice in the Generative Engine Optimization (GEO) space.

The three projects are:

1. **"The llms.txt Access Paradox"** — An analytical paper documenting the infrastructure contradictions that prevent llms.txt from fulfilling its stated purpose.

2. **LlmsTxtKit** — A C#/.NET MCP (Model Context Protocol) server and library that implements llms.txt-aware content retrieval, validation, and caching for AI agent systems.

3. **"Context Collapse Mitigation Benchmark"** — An empirical study measuring whether llms.txt-curated content actually reduces context collapse compared to standard HTML retrieval in local LLM inference.

These projects are designed to reference each other, share infrastructure, and collectively tell a story that progresses from "here's the problem" (Paper) to "here's a tool that could help" (MCP Server) to "here's whether it actually works" (Benchmark). The blog series proposed alongside them transforms this research into an ongoing content strategy that demonstrates both technical writing expertise and practical GEO knowledge.

---

## Shared Objectives

All three projects share the following overarching goals:

**O-1: Produce Original, Citable Research.** The llms.txt ecosystem is drowning in opinion pieces and SEO blog posts that recycle the same talking points. There is almost no rigorous, primary-source analysis. These projects fill that gap with firsthand data, original code, and controlled experiments — the kind of work that gets cited by other researchers, not just reshared on LinkedIn.

**O-2: Demonstrate Technical Writing + Development Proficiency.** Each deliverable showcases a different facet of the author's skillset: analytical writing (Paper), systems-level .NET development (MCP Server), and empirical research methodology (Benchmark). Together they present a portfolio that is difficult for a hiring manager to dismiss as "just blog posts" or "just code."

**O-3: Fill the .NET/C# Ecosystem Gap.** Every existing llms.txt tool — the official `llms_txt` Python module, the JavaScript implementation, the VitePress and Docusaurus plugins — is written in Python or JavaScript. There is zero .NET representation. Given that MCP is gaining traction as a standard for AI agent tool integration, a well-documented C# MCP server fills a genuine ecosystem need.

**O-4: Build Credibility Without Requiring Gatekeeper Approval.** The author has encountered resistance from Jeremy Howard (the llms.txt spec author) when attempting to collaborate. These projects are designed to be valuable *regardless* of whether the spec author endorses them. They analyze the standard objectively, build tooling that works with the standard as-specified, and produce benchmark data that speaks for itself. This is a "show, don't ask permission" strategy.

**O-5: Establish a GEO Content Pipeline.** The blog series transforms research artifacts into a sustained content strategy. Each post demonstrates GEO best practices *while discussing GEO* — a form of recursive credibility that is difficult to fake.

---

## The Standards Landscape: What You Need to Know

Before diving into the individual project proposals, it's essential to understand the current state of the llms.txt standard and the competing/complementary standards in the space. This context shapes every decision in the projects that follow.

### llms.txt: Origin, Intent, and Specification

The `/llms.txt` standard was proposed by Jeremy Howard (of Answer.AI and fast.ai) in September 2024. Howard's motivation was practical: he had just released FastHTML, a Python web framework, and developers kept complaining that AI coding assistants couldn't help them use it because the library was too new — created after the models' training cutoff dates. AI systems couldn't access FastHTML's documentation effectively at inference time.

The spec itself is deliberately minimal. An llms.txt file is a Markdown document placed at the root of a website (`/llms.txt`) that follows this structure:

- **An H1** with the project or site name (the only *required* element).
- **A blockquote** with a short summary containing key information needed to understand the rest of the file.
- **Zero or more Markdown sections** (paragraphs, lists, etc. — but no headings) with additional context.
- **Zero or more H2-delimited sections** containing "file lists" — Markdown lists of hyperlinks to further resources, each optionally followed by a colon and description.
- **An optional "Optional" section** (literally titled `## Optional`) whose URLs can be skipped when a shorter context window is needed.

The spec also proposes that pages provide clean Markdown versions at the same URL with `.md` appended (e.g., `/docs/quickstart.html` would have a Markdown counterpart at `/docs/quickstart.html.md`).

Critically, the spec itself states: *"Our expectation is that llms.txt will mainly be useful for inference, i.e. at the time a user is seeking assistance, as opposed to for training."* This is not a training-data-indexing protocol. It was designed to help AI answer questions *right now* by pointing them at the most relevant, cleanest versions of a site's content.

### The Adoption Reality

As of early 2026, adoption numbers tell a split story:

- **844,000+ websites** have implemented some form of llms.txt file, according to aggregate directory counts.
- **Notable adopters** include Anthropic, Cloudflare, Stripe, Vercel, Coinbase, and many developer documentation sites.
- **An independent crawl** of the Majestic Million dataset found only 15 sites with llms.txt in February 2025, growing to 105 by May 2025 — a 600% increase, but from an almost-zero base among the top 1 million websites.

The pattern is unmistakable: llms.txt has achieved rapid, enthusiastic adoption in developer tools and technical documentation, while remaining essentially invisible across the broader web.

### The Critical Gap: Nobody Reads It at Inference Time

This is the single most important fact about llms.txt, and the one most often glossed over by SEO commentators: **no major LLM provider has publicly confirmed that they use llms.txt at inference time.**

- **Google** has explicitly rejected the standard. John Mueller compared it to the discredited keywords meta tag in April 2025. Gary Illyes stated at Search Central Live in July 2025 that Google doesn't support llms.txt and isn't planning to. (Google then got caught with an llms.txt file on their own Search Central docs in December 2025, responded with "hmmn :-/" when asked about it, and removed it within hours. The file appears to have been auto-generated by their CMS platform rather than deliberately authored by the search team.)
- **Server log evidence** is contradictory. Yoast's analysis found that GPTBot, ClaudeBot, and Google's AI crawlers don't request llms.txt files. One hosting provider managing 20,000 sites confirmed zero GPTBot activity on llms.txt. But another developer showed screenshots of GPTBot pinging their llms.txt every 15 minutes. The inconsistency suggests experimental or selective behavior, not systematic support.
- **Training vs. inference** crawling is different. Mintlify and Profound data show Microsoft and OpenAI crawlers actively accessing llms.txt and llms-full.txt files. But crawling for training data collection is categorically different from reading the file at inference time to improve a specific response. The spec was designed for inference. The evidence suggests it's only being consumed for training.

### Competing Standards

llms.txt does not exist in isolation. Several competing or complementary standards have emerged:

- **Cloudflare Content Signals Policy** (September 2025): Extends `robots.txt` with three machine-readable directives (`search`, `ai-input`, `ai-train`) that let publishers declare how crawlers may use their content. Already deployed to 3.8 million domains via Cloudflare's managed robots.txt service. Fundamentally different from llms.txt in purpose — Content Signals govern *permission* (can you use my content?), while llms.txt governs *discovery* (here's the best content for you to use).
- **CC Signals** (Creative Commons, 2025): A values-driven framework for expressing how content should be used in AI development, emphasizing reciprocity, recognition, and sustainability. Still in pilot phase as of December 2025.
- **IETF AI Preferences (aipref)**: A proposed standard for website publishers to control how automated systems use their content, being developed through the Internet Engineering Task Force standards process.
- **`robots.txt` itself**: The 1994-vintage Robots Exclusion Protocol remains the foundational standard, but was never designed to handle the nuances of AI content usage. It's a binary allow/disallow mechanism applied to crawling behavior, not content usage after retrieval.

### The Anti-Bot Infrastructure Paradox

Perhaps the most underexplored problem in the entire llms.txt ecosystem: even when site owners *want* AI systems to access their llms.txt files, the web infrastructure often prevents it. This is the "Access Paradox" that Project 1 documents in detail.

Cloudflare — which sits in front of roughly 20% of all public websites — began blocking all AI crawlers by default on new domains in July 2025 ("AIndependence Day"). AI crawlers trigger bot-detection heuristics because they don't execute JavaScript, don't maintain cookies, originate from data center IP ranges, and use non-browser user agents. Web Application Firewalls (WAFs) and anti-bot systems treat these signals as threats.

The result is a three-way misalignment: site owners create llms.txt to help AI systems → hosting infrastructure blocks AI crawlers → AI systems fall back to search APIs instead of directly fetching curated content. Everyone does their part; the system still doesn't work.

Cloudflare does offer granular controls — you can separately configure `ai-train`, `search`, and `ai-input` permissions — but these require active configuration that most site owners never perform. Worse, WAF custom rules execute *before* AI Crawl Control settings, meaning a custom security rule can block an AI crawler even when the AI Crawl Control panel says "allowed."

---

## Project 1: "The llms.txt Access Paradox" — Analytical Paper

### Purpose

To produce a rigorous, primary-source analytical paper that documents the gap between llms.txt's design intent (inference-time content discovery), the infrastructure reality (WAF/CDN blocking), and actual AI system behavior (no confirmed inference-time usage). This paper fills the void between shallow SEO blog posts and the nonexistent academic literature on this topic.

### Scope

The paper covers four main analytical threads, each supported by evidence:

**Thread 1: Design Intent vs. Observed Behavior.** The spec explicitly targets inference-time usage. Server log data from multiple sources shows that major AI crawlers either don't request llms.txt files at all, or only do so inconsistently and likely for training purposes. This thread documents the evidence on both sides and analyzes what it means for the standard's viability.

**Thread 2: The Infrastructure Catch-22.** This is the paper's most original contribution. It documents, with concrete technical detail, how WAF systems, Cloudflare's default-block policies, and anti-bot heuristics prevent AI crawlers from accessing llms.txt files — even on sites where the owner explicitly wants AI access. The author's own firsthand experience with anti-bot blocking provides primary-source credibility here.

**Thread 3: The Trust Problem.** Google's comparison of llms.txt to the keywords meta tag isn't just dismissive rhetoric — it reflects a genuine engineering concern. Because llms.txt content is maintained separately from the HTML it describes, there's no built-in mechanism to verify consistency, detect staleness, or prevent manipulation. This thread examines the trust architecture (or lack thereof) and proposes what validation mechanisms would be needed for platform adoption.

**Thread 4: The Standards Fragmentation Problem.** llms.txt, Content Signals, CC Signals, IETF aipref, and plain robots.txt all address overlapping but distinct aspects of the AI-content relationship. This thread maps how they relate, where they conflict, and what a unified approach might look like.

### Target Audience

The paper targets three overlapping audiences: GEO/SEO practitioners who need to make informed decisions about implementing llms.txt; AI infrastructure engineers who encounter these problems when building retrieval systems; and technical documentation professionals who are evaluating content strategy for AI discoverability.

### Outline

1. **Abstract** — 200-word summary of findings.
2. **Introduction: The Promise of llms.txt** — What the standard was designed to solve, with direct quotes from the spec and Howard's original context (FastHTML documentation problem).
3. **The Adoption Landscape** — Quantitative data on adoption: directory counts, Majestic Million crawl results, notable implementors, sector distribution (tech-heavy, mainstream-absent).
4. **The Inference Gap** — Evidence that no major LLM provider uses llms.txt at inference time. Server log analysis from Yoast, Mintlify, independent developers. Distinction between training-time crawling and inference-time retrieval.
5. **The Infrastructure Paradox** — Technical deep dive into WAF/Cloudflare blocking mechanisms. How AI crawler characteristics trigger bot detection. The three-way misalignment (site owner intent → infrastructure blocking → AI fallback to search APIs). Cloudflare's granular controls and why they're insufficient. Primary-source account of the author's own blocking experience.
6. **The Trust Architecture** — Analysis of Google's keywords-meta-tag comparison. Cloaking concerns (separate content for bots vs. humans). Absence of validation, freshness verification, or consistency checks. What would be needed for platforms to trust llms.txt content.
7. **Standards Fragmentation** — How llms.txt, Content Signals, CC Signals, and IETF aipref relate and conflict. The permission-vs-discovery distinction. Why the ecosystem needs both but currently has neither working reliably.
8. **Implications for GEO Practice** — What practitioners should actually *do* given these findings. Evidence-based recommendations rather than speculation.
9. **Research Gaps and Future Work** — Explicit identification of unanswered questions that the Benchmark project (Project 3) addresses.
10. **References** — Full citation list using a consistent format.

### Relationship to Other Projects

The paper explicitly identifies the need for (a) tooling that can work around the infrastructure paradox — motivating LlmsTxtKit (Project 2), and (b) empirical testing of whether llms.txt-curated content actually improves AI response quality — motivating the Benchmark study (Project 3). It cites both as "future work" and, once they're complete, can be updated with cross-references.

### Output Format

The Paper is a prose document — its evidence is qualitative analysis, cited sources, server log excerpts, and policy documentation, not computed results. There is no meaningful code to "run" in the paper itself. Wrapping it in a Jupyter notebook would feel forced, like stuffing a policy brief into a computational shell just because the format exists. The paper's credibility comes from the quality of its sourcing and reasoning, not from reproducible computation.

However, the paper's data appendix involves aggregated statistics from multiple sources (directory adoption counts over time, Majestic Million crawl results, sector distribution breakdowns). Where those numbers are compiled or cross-referenced from raw data, a lightweight Jupyter notebook provides transparency into the aggregation methodology. This notebook is an *appendix artifact* — it shows how the numbers were derived, not the analysis itself.

### Deliverables

- **The paper itself** (`paper/draft.md`) — Markdown source, 6,000–10,000 words. Rendered to PDF for formal distribution.
- **Data appendix** (`paper/data/`) — Server log samples, adoption statistics, and configuration examples in their raw formats.
- **Data aggregation notebook** (`paper/data/adoption-analysis.ipynb`) — Optional. A lightweight Jupyter notebook that documents how adoption statistics from multiple sources were compiled and cross-referenced. Colab-compatible (no .NET dependencies — pure Python/pandas operating on flat data files).
- **A condensed blog post version** (see Blog Strategy below).

### Timeline Estimate

- Research consolidation and outline: 1 week
- First draft: 2 weeks
- Review, revision, and data verification: 1 week
- **Total: ~4 weeks**

---

## Project 2: LlmsTxtKit — C#/.NET MCP Server & Library

### Purpose

To build an open-source C#/.NET library and MCP (Model Context Protocol) server that implements llms.txt-aware content retrieval, parsing, validation, and caching. This fills the complete absence of .NET tooling in the llms.txt ecosystem, provides a testable artifact for the Benchmark study, and demonstrates the author's ability to design and document a non-trivial software project from scratch.

### Why C# and Why MCP?

**C# rationale:** Every existing llms.txt tool is Python or JavaScript. The official `llms_txt` Python module provides parsing and context generation. The JavaScript implementation mirrors it. Docusaurus and VitePress plugins generate llms.txt files from documentation sites. None of these serve the .NET ecosystem — which powers a massive share of enterprise web infrastructure, particularly in the Microsoft Azure, ASP.NET Core, and Blazor spaces. A .NET developer building an AI-integrated application currently has *zero* llms.txt libraries to choose from.

**MCP rationale:** The Model Context Protocol is emerging as the standard interface through which AI agents access external tools and data sources. Claude, GitHub Copilot, and other AI systems support MCP servers. An MCP server that understands llms.txt gives any MCP-capable AI agent the ability to discover, fetch, validate, and serve llms.txt-curated content — effectively implementing the inference-time workflow that the llms.txt spec describes but that no major platform has built natively.

### Architecture Overview

LlmsTxtKit is structured as two distinct packages that ship together:

**`LlmsTxtKit.Core`** — A standalone .NET library (targeting .NET 8+) that handles:

- **Parsing:** Reads an llms.txt file and produces a strongly-typed `LlmsDocument` object model (title, summary, sections, file lists with URLs and descriptions, optional section identification). The parser follows the spec precisely and handles edge cases (missing optional sections, malformed links, non-standard Markdown).
- **Fetching:** Retrieves llms.txt files from URLs with configurable retry logic, timeout handling, user-agent identification, and graceful degradation when WAFs block access. Includes a `FetchResult` type that distinguishes between "file found," "file not found," "blocked by WAF," "DNS failure," and other outcomes — giving calling code the information it needs to decide what to do next.
- **Validation:** Checks a fetched llms.txt file against the spec (required H1 present, blockquote structure correct, H2 sections contain valid link lists), verifies that linked URLs resolve, optionally checks Last-Modified headers for freshness, and produces a `ValidationReport` with warnings and errors.
- **Caching:** An in-memory and optionally file-backed cache with configurable TTL (time-to-live), so repeated requests for the same site's llms.txt don't hammer the origin server. Cache entries store the parsed document, validation report, fetch timestamp, and HTTP headers.
- **Context Generation:** Expands an llms.txt document into an LLM-ready context string — fetching linked Markdown files, concatenating them with XML-style section wrappers (similar to how FastHTML generates `llms-ctx.txt`), and respecting the "Optional" section's skip-when-short semantics.

**`LlmsTxtKit.Mcp`** — An MCP server that wraps LlmsTxtKit.Core and exposes it as a tool set that AI agents can call:

- **`llmstxt_discover`** — Given a domain, checks for `/llms.txt` and returns the parsed document structure. Reports whether the file was found, blocked, or absent.
- **`llmstxt_fetch_section`** — Given a domain and section name (e.g., "Docs", "Examples"), fetches and returns the content of all linked resources in that section.
- **`llmstxt_validate`** — Runs full validation on a site's llms.txt and returns the validation report.
- **`llmstxt_context`** — Generates the full LLM-ready context (like `llms-ctx-full.txt`) for a given site, respecting token budgets if specified.
- **`llmstxt_compare`** — Given a URL, fetches both the HTML page and the llms.txt-linked Markdown version (if available) and reports on size difference, content overlap, and freshness delta. This tool directly supports the Benchmark study.

### Documentation-First Approach

Before any code is written, the following documentation artifacts are produced:

1. **Product Requirements Specification (PRS)** — Defines the problem being solved, target users, success criteria, and non-goals (what the project explicitly does *not* do).
2. **Design Specification** — Architecture diagrams, component responsibilities, data flow, dependency choices, and rationale for key design decisions.
3. **API Reference** — XML doc comments on every public type and method, generated into a browsable documentation site.
4. **User Stories** — For both the library consumer ("As a .NET developer, I want to parse an llms.txt file so that I can build AI-integrated features that respect the standard") and the MCP agent consumer ("As an AI agent, I want to discover whether a site has an llms.txt file so that I can prefer curated content over raw HTML").
5. **Test Plan** — Defines unit test coverage targets, integration test scenarios (including mock WAF blocking responses), and the test data corpus.

### Testing Strategy

- **Unit tests** for the parser covering all spec-compliant and edge-case inputs (missing sections, malformed links, Unicode content, very large files, empty files).
- **Unit tests** for the validator covering each validation rule independently.
- **Integration tests** using a local HTTP server that simulates various real-world scenarios: healthy llms.txt, 403 Forbidden (WAF block), 429 Too Many Requests (rate limiting), 404 Not Found, redirect chains, slow responses, and malformed content.
- **MCP protocol tests** verifying that each tool responds with correctly structured MCP responses.
- **A curated test corpus** of real-world llms.txt files (from Anthropic, Cloudflare, Stripe, FastHTML, etc.) to verify parsing handles production content correctly.

### Relationship to Other Projects

LlmsTxtKit is the *practical implementation* of the infrastructure observations documented in the Paper (Project 1). The Paper says "here's why direct crawling fails and here's what a workaround would need to do." LlmsTxtKit does it.

The `llmstxt_compare` tool is specifically designed to generate the paired data (HTML vs. Markdown content for the same page) that the Benchmark study (Project 3) needs as input.

### Deliverables

- `LlmsTxtKit.Core` NuGet package with full XML documentation.
- `LlmsTxtKit.Mcp` MCP server binary, deployable as a standalone process.
- GitHub repository with MIT license, comprehensive README, contributing guide, and changelog.
- Documentation site generated from XML doc comments.
- All documentation artifacts listed above (PRS, Design Spec, Test Plan, User Stories).

### Timeline Estimate

- Documentation phase (PRS, Design Spec, User Stories, Test Plan): 2 weeks
- Core library implementation + unit tests: 3 weeks
- MCP server implementation + integration tests: 2 weeks
- Documentation site, README, packaging: 1 week
- **Total: ~8 weeks**

---

## Project 3: Context Collapse Mitigation Benchmark

### Purpose

To conduct the first (to our knowledge) controlled empirical study measuring whether llms.txt-curated content reduces context collapse in LLM responses compared to standard HTML-retrieved content. This directly addresses the most important unanswered question in the llms.txt debate: **does it actually help?**

Nobody has published rigorous A/B testing on this. The entire llms.txt discourse is built on the *assumption* that cleaner Markdown input produces better AI outputs, but no one has measured it. This study produces the data.

### Background: Three Forms of Context Collapse

The study is informed by research identifying multiple distinct forms of context collapse in AI systems. Understanding these forms is essential because llms.txt can only plausibly address some of them:

**Retrieval-Time Context Collapse** occurs when an AI system retrieves noisy, cluttered content from the web. A typical HTML page might be 50KB, of which 40KB is navigation, cookie banners, advertising scripts, and CSS — leaving only 10KB of substantive content. The AI's context window gets consumed by irrelevant markup, leaving less capacity for reasoning about the actual information. Chroma Research's "Context Rot" study (2025) demonstrated that LLM performance degrades nonuniformly as input length increases, particularly when the input contains irrelevant or noisy content interspersed with relevant information. **This is the form of context collapse that llms.txt should directly address** — if the Markdown version contains only substantive content, the AI wastes no context budget on noise.

**Epistemic Context Collapse** is the loss of diversity in LLM outputs. Research shows that larger models produce increasingly homogenized responses, narrowing to dominant high-probability ideas. RAG (Retrieval-Augmented Generation) can increase diversity when the retrieval database is contextually broad — but if llms.txt files only exist on large, well-resourced organizations' sites, it could *exacerbate* collapse by privileging already-dominant voices. This is a second-order effect that the study notes but does not directly measure.

**Within-Conversation Context Degradation** (sometimes called "losing the plot") is the gradual breakdown of coherence during long conversations as earlier context falls outside the model's effective attention window. llms.txt doesn't address this form at all — it's about initial content retrieval, not conversation maintenance.

### Methodology

The study uses a controlled experimental design with the following structure:

**Test Corpus:** A set of 30-50 websites that have *both* a well-maintained llms.txt file *and* substantial HTML documentation. Sites are selected from the llms.txt directories (llmstxt.site, directory.llmstxt.cloud) and verified manually for quality. The corpus spans multiple domains — developer documentation, SaaS product docs, API references, and general-purpose informational sites — to avoid selection bias.

**Content Pairs:** For each site, LlmsTxtKit's `llmstxt_compare` tool generates a content pair:
- **Condition A (Control):** The raw HTML of a representative page, processed through a standard HTML-to-text pipeline (similar to what AI search backends do today).
- **Condition B (Treatment):** The llms.txt-linked Markdown version of the same page, fetched and presented as clean Markdown.

**Question Set:** For each site, 5-10 factual questions are crafted that can be definitively answered from the site's content. Questions vary in complexity: some require information from a single paragraph, others require synthesizing information across multiple sections, and some require understanding the relationship between concepts. A "gold standard" answer is prepared for each question by the researcher.

**Models Under Test:** The study runs on local LLMs using the author's Mac Studio M3 Ultra (512GB RAM), which can comfortably serve multiple large models simultaneously. The initial model set includes at least one model from each major family available for local inference (Llama, Mistral, Qwen, Gemma, etc.) at multiple parameter sizes, to test whether the llms.txt effect varies with model capability.

**Measurement Protocol:** For each (site, question, model, condition) tuple:
1. The model receives a system prompt establishing it as a factual question-answering system.
2. The model receives the content (HTML-derived text for Condition A, Markdown for Condition B).
3. The model receives the question.
4. The response is recorded.

**Metrics:** Each response is scored on:
- **Factual Accuracy** — Does the response contain correct information? Scored on a 0-3 scale (completely wrong, partially correct, mostly correct, fully correct) against the gold standard.
- **Completeness** — Does the response include all relevant information available in the source? Binary (complete/incomplete) with qualitative notes.
- **Hallucination Rate** — Does the response contain claims not present in the source material? Counted per response.
- **Citation Fidelity** — When the model attributes information to the source, is the attribution accurate? Scored where applicable.
- **Token Efficiency** — How many input tokens were required for each condition? The hypothesis predicts Condition B (Markdown) requires significantly fewer tokens for equivalent or better output quality.

**Statistical Analysis:** Paired comparisons (same question, same model, different conditions) allow statistical testing of whether the differences are significant. With 30-50 sites × 5-10 questions × multiple models, the dataset is large enough for meaningful analysis.

### What the Study Can and Cannot Show

**Can show:** Whether cleaner input (llms.txt Markdown vs. HTML-derived text) produces measurably different response quality across multiple dimensions. Whether the effect size varies by model capability. Whether certain types of content benefit more than others from llms.txt curation. Whether the token savings are significant enough to justify the maintenance cost of llms.txt files.

**Cannot show:** Whether any major LLM provider *does* or *should* use llms.txt at inference time (that's a business and platform decision, not an empirical one). Whether the study results generalize to proprietary models with different architectures and training data. Whether the maintenance burden of keeping llms.txt files current is economically justified for a given organization.

**Valuable regardless of outcome:** If Condition B (Markdown) significantly outperforms Condition A (HTML), it provides the strongest evidence yet that llms.txt-style content curation has tangible value — which would be noteworthy given the current skepticism. If the difference is negligible or inconsistent, it would validate Google's position that modern LLMs can parse HTML effectively and that a separate Markdown version adds marginal value — which would *also* be noteworthy and would redirect GEO effort away from llms.txt and toward other strategies. Both outcomes are publishable and useful.

### Relationship to Other Projects

The Benchmark study uses LlmsTxtKit (Project 2) as its primary data collection tool — the `llmstxt_compare` and `llmstxt_context` tools generate the content pairs that form the experimental input. The Paper (Project 1) motivates the study by identifying the absence of empirical evidence as a critical gap in the llms.txt discourse, and the study's results are incorporated into a revised version of the paper (or published as a follow-up).

### Output Format: The Hybrid Approach

The Benchmark has a fundamentally different relationship with executable code than the Paper does. It produces empirical data — accuracy scores, token counts, hallucination rates, paired comparisons across models and conditions. Anyone reading the results should be able to ask "how exactly did you compute that?" and get a concrete answer. But there's a tension: **Google Colab is a Python environment, and the entire data collection pipeline is C#/.NET.** LlmsTxtKit generates the content pairs, and local inference runs on the Mac Studio, not on cloud GPUs. Colab doesn't natively support .NET, and while you *can* hack it with `dotnet-script` or Polyglot Notebooks, it's a second-class experience that fights the platform rather than leveraging it.

The solution is to separate the pipeline into two distinct phases with different tooling:

**Phase 1: Data Collection (C#)** — A console application (or script) in the LlmsTxtKit repo that orchestrates the full experimental run. It calls LlmsTxtKit's `llmstxt_compare` to generate content pairs, submits prompts to local LLM endpoints via HTTP (LM Studio or Ollama API), records raw responses, and writes structured output to CSV/JSON files. This phase requires the Mac Studio's hardware and LlmsTxtKit as a dependency. It is *documented for reproducibility* (exact model names, parameter counts, quantization levels, prompt templates, API endpoints) but not expected to be trivially reproducible on arbitrary hardware — running 70B+ parameter models locally requires 512GB of unified memory, and that's a constraint the study acknowledges honestly rather than pretending Colab can replicate.

**Phase 2: Data Analysis (Python/Jupyter)** — A standard Jupyter notebook that reads the raw CSV/JSON output from Phase 1 and produces every figure, table, and statistical test cited in the write-up. This notebook has zero .NET dependencies — it's pure pandas, scipy, matplotlib/seaborn, operating on flat files. It *is* fully reproducible on Colab or any Python environment. This is the layer where universal reproducibility matters most, because this is where someone goes to verify that the published numbers actually follow from the data.

This separation mirrors how empirical research typically works. The instrument (LlmsTxtKit + local inference) and the analysis (notebook) are distinct artifacts with distinct purposes. Bundling them into one monolithic notebook would obscure that distinction rather than clarify it.

### Analysis Notebook Structure

The analysis notebook (`benchmark/results/analysis.ipynb`) is organized into the following sections, each producing specific outputs that the write-up references:

**Section 1: Data Loading and Validation**
- Load raw results from `benchmark/results/raw-data.csv`
- Schema validation (expected columns, data types, completeness checks)
- Summary statistics: total experimental runs, unique sites, questions, models, conditions
- Data quality flags (any runs that failed, timed out, or produced empty responses)

**Section 2: Token Efficiency Analysis**
- Paired comparison of input token counts: Condition A (HTML-derived text) vs. Condition B (llms.txt Markdown) for the same content
- Distribution plots showing token reduction across the corpus
- Statistical test (paired t-test or Wilcoxon signed-rank) for significance
- Breakdown by content type (API docs vs. tutorials vs. reference pages) to identify which categories benefit most from llms.txt curation
- **Output:** Figure 1 (token count distributions), Table 1 (mean/median/std token counts by condition)

**Section 3: Factual Accuracy Comparison**
- Paired comparison of accuracy scores (0–3 scale) between conditions
- Per-model breakdown: does the llms.txt effect vary with model capability (small vs. large models)?
- Per-question-complexity breakdown: do synthesis questions show larger effects than single-fact questions?
- Statistical test (Wilcoxon signed-rank, appropriate for ordinal paired data) for significance
- Effect size calculation (rank-biserial correlation or similar)
- **Output:** Figure 2 (accuracy score distributions by condition and model), Table 2 (accuracy statistics by condition × model × question complexity)

**Section 4: Hallucination Rate Analysis**
- Count of hallucinated claims per response, paired between conditions
- Categorization of hallucination types where feasible (fabricated facts, incorrect attribution, extrapolation beyond source)
- Statistical test for whether Condition B produces fewer hallucinations
- **Output:** Figure 3 (hallucination rate comparison), Table 3 (hallucination counts by condition and model)

**Section 5: Completeness and Citation Fidelity**
- Binary completeness scores (complete/incomplete) compared between conditions
- Citation fidelity scores where applicable
- These are secondary metrics — reported for thoroughness but expected to show less dramatic differences than accuracy and hallucination rate
- **Output:** Table 4 (completeness and citation fidelity percentages)

**Section 6: Composite Analysis**
- Correlation matrix across all metrics (do token savings predict accuracy gains?)
- Per-site analysis: are there sites where llms.txt Markdown *hurts* performance? (Possible if the Markdown version is stale or incomplete relative to the HTML.)
- Model capability interaction: plot the llms.txt effect size against model parameter count to identify whether smaller models benefit more (hypothesis: smaller models with tighter context windows should show larger improvements from reduced token input)
- **Output:** Figure 4 (effect size vs. model size scatter plot), Figure 5 (per-site delta heatmap)

**Section 7: Freshness and Staleness Check**
- For each site in the corpus, compare Last-Modified dates (or content hashes) between the HTML page and the llms.txt-linked Markdown version
- Identify sites where the Markdown is stale relative to the HTML
- Correlate staleness with accuracy deltas (does stale Markdown actually produce *worse* results than fresh HTML?)
- **Output:** Table 5 (freshness comparison), Figure 6 (accuracy delta vs. content freshness)

**Section 8: Summary and Key Findings**
- Consolidated results table with all primary metrics
- Statistical significance summary
- Plain-language interpretation of what the numbers mean for the llms.txt debate
- Explicit statement of limitations and what the data does *not* show

### Deliverables

- **Study write-up** (`benchmark/write-up.md`) — Markdown, 4,000–8,000 words. Methodology, results, analysis, and limitations as a standalone readable document. Rendered to PDF for formal distribution. References specific figures and tables from the analysis notebook but does not require the reader to execute anything.
- **Raw data set** (`benchmark/results/raw-data.csv`) — Every experimental run with columns for site, question, model, condition, input token count, output token count, response text, accuracy score, hallucination count, completeness flag, and citation fidelity score. Anonymized if necessary (replacing site names with identifiers if any sites request it).
- **Analysis notebook** (`benchmark/results/analysis.ipynb`) — The Jupyter notebook described above. Reads `raw-data.csv` and produces every figure and statistical test cited in the write-up. Colab-compatible (zero .NET dependencies — pure Python with pandas, scipy, matplotlib/seaborn). A "Open in Colab" badge in the benchmark README links directly to this notebook.
- **Scoring rubric** (`benchmark/corpus/scoring-rubric.md`) — The detailed criteria for each metric, with examples of each score level for accuracy (0–3) and hallucination categorization.
- **Gold-standard answer set** (`benchmark/corpus/gold-answers.json`) — The researcher-authored correct answers for every question, against which model responses are scored.
- **Data collection runner** (`benchmark/scripts/run-benchmark.cs` or a console project in the LlmsTxtKit repo) — The C# program that orchestrates Phase 1. Documented with inline comments explaining every configuration parameter, API endpoint, prompt template, and output format. Includes a `benchmark-config.json` that specifies the exact models, quantization levels, and inference parameters used.
- **Reproducibility README** (`benchmark/REPRODUCING.md`) — Step-by-step instructions covering: (1) hardware requirements for full replication (Mac Studio M3 Ultra 512GB or equivalent for local inference), (2) how to run the data collection pipeline, (3) how to run the analysis notebook on the pre-collected data (Colab or local Python), (4) how to verify that the notebook outputs match the published figures and tables. Honest about what requires specialized hardware and what doesn't.
- **A condensed blog post version** (see Blog Strategy below).

### Timeline Estimate

- Corpus selection and question authoring: 2 weeks
- Infrastructure setup (LlmsTxtKit integration, local model configuration): 1 week
- Data collection (running all experimental conditions): 2 weeks
- Scoring and analysis: 2 weeks
- Write-up: 1 week
- **Total: ~8 weeks** (can overlap with LlmsTxtKit development; data collection starts as soon as the library is functional)

---

## Cross-Project Reference Map

The following table shows how the three projects reference and depend on each other. This is the connective tissue that makes the initiative feel like a coherent body of work rather than three unrelated projects:

| Reference Point | Paper (P1) | LlmsTxtKit (P2) | Benchmark (P3) |
|---|---|---|---|
| **Problem definition** | Defines the Access Paradox and inference gap | Implements workarounds for the Access Paradox | Tests whether solving the problem actually matters |
| **Trust/validation** | Analyzes the trust architecture gap | Implements `ValidationReport` and freshness checks | Measures whether validated content improves outcomes |
| **WAF blocking** | Documents the blocking mechanisms | Implements graceful degradation + `FetchResult` types | Uses LlmsTxtKit to handle blocking during data collection |
| **Context collapse** | Introduces and categorizes the three forms | Provides `llmstxt_compare` for paired content generation | Empirically measures context collapse mitigation |
| **Standards analysis** | Maps how llms.txt, Content Signals, CC Signals, aipref relate | Implements the llms.txt spec; could extend to Content Signals | Tests llms.txt specifically; framework extensible to other standards |
| **GEO implications** | Discusses what practitioners should do | Provides a tool practitioners can use | Provides evidence to inform practitioner decisions |
| **Output format** | Prose document (Markdown/PDF) + optional data aggregation notebook | .NET library + NuGet package + MCP binary | Prose write-up + raw CSV data + Colab-compatible Jupyter analysis notebook |
| **Reproducibility** | Source citations verifiable by reader | Unit + integration tests; test corpus of real llms.txt files | Phase 1 (data collection) requires Mac Studio hardware; Phase 2 (analysis) fully reproducible on Colab |

---

## Repository Structure

The initiative uses two GitHub repositories, separated by the fundamental difference between a *shipping software product* (LlmsTxtKit) and a *research body of work* (everything else).

### Why Two Repos, Not One or Three

LlmsTxtKit has a fundamentally different audience than the paper and benchmark. Developers searching for ".NET llms.txt library" need a repo with a clear README, API docs, NuGet packaging instructions, and a contributing guide — not a research monorepo where the library happens to live in a subdirectory. Giving it its own repo means its GitHub stars, issues, and activity graph reflect the library's traction independently, which matters for portfolio visibility and for anyone evaluating the library as a dependency.

The paper and benchmark, on the other hand, are tightly coupled — the benchmark exists because the paper identified the research gap, they share a bibliography, and the benchmark feeds results back into the paper's revision. Keeping them in one repo means cross-references are relative paths, the shared bibliography stays in one place, and the blog posts (which synthesize from both) can reference either without juggling multiple checkouts.

A third option — three separate repos plus a "hub" — adds coordination overhead without meaningful benefit. The paper and benchmark aren't independently discoverable products that someone would search for and clone separately; they're parts of a unified research effort.

### `llmstxt-research` — Research Repository

```
llmstxt-research/
├── README.md                         # Initiative overview, links to LlmsTxtKit repo
├── PROPOSAL.md                       # This unified proposal document
├── CONTRIBUTING.md                   # How to report issues, suggest corrections
├── LICENSE                           # CC BY 4.0 for written content, MIT for code
│
├── paper/
│   ├── README.md                     # Paper-specific overview and current status
│   ├── outline.md                    # Detailed section outline with completion status
│   ├── draft.md                      # The paper itself (Markdown source)
│   ├── draft.pdf                     # Rendered PDF for formal distribution
│   ├── data/
│   │   ├── adoption-stats.csv        # Compiled adoption statistics with sources
│   │   ├── server-log-samples/       # Anonymized excerpts illustrating crawler behavior
│   │   ├── config-examples/          # WAF/Cloudflare configuration screenshots/snippets
│   │   └── adoption-analysis.ipynb   # Optional notebook documenting data aggregation
│   └── figures/                      # Any charts or diagrams used in the paper
│
├── benchmark/
│   ├── README.md                     # Study overview, methodology summary, status
│   ├── REPRODUCING.md                # Full reproducibility instructions (hardware + software)
│   ├── methodology.md                # Detailed methodology specification
│   ├── write-up.md                   # The benchmark study write-up (Markdown source)
│   ├── write-up.pdf                  # Rendered PDF for formal distribution
│   ├── corpus/
│   │   ├── site-list.csv             # Test sites with URLs, llms.txt status, sector tags
│   │   ├── questions.json            # Question sets per site with complexity ratings
│   │   ├── gold-answers.json         # Researcher-authored correct answers
│   │   └── scoring-rubric.md         # Detailed scoring criteria with examples
│   ├── scripts/
│   │   ├── run-benchmark.cs          # C# data collection orchestrator (or console project)
│   │   └── benchmark-config.json     # Model specs, quantization, inference parameters
│   └── results/
│       ├── raw-data.csv              # Complete experimental results
│       ├── analysis.ipynb            # Jupyter analysis notebook (Colab-compatible)
│       └── figures/                  # Generated figures referenced in write-up
│
├── blog/
│   ├── README.md                     # Publication schedule, status tracker
│   ├── 01-waf-story.md
│   ├── 02-paper-summary.md
│   ├── 03-dotnet-gap.md
│   ├── 04-techwriter-geo.md
│   ├── 05-standards-landscape.md
│   ├── 06-benchmark-results.md
│   ├── 07-mcp-csharp-tutorial.md
│   └── 08-synthesis.md
│
└── shared/
    ├── references.md                 # Shared bibliography (used by paper + benchmark)
    ├── glossary.md                   # Shared terminology definitions
    └── references.bib                # Optional structured bibliography (BibTeX)
```

**License note:** Written content (paper, benchmark write-up, blog posts) uses CC BY 4.0, allowing others to cite and share with attribution. Code artifacts (scripts, notebooks) use MIT. This dual-license structure is declared in the root LICENSE file and reiterated in each subdirectory's README where relevant.

### `LlmsTxtKit` — Software Repository

```
LlmsTxtKit/
├── README.md                         # Library overview, installation, quick start
├── CONTRIBUTING.md                   # Development setup, PR guidelines, coding standards
├── CHANGELOG.md                      # Version history following Keep a Changelog format
├── LICENSE                           # MIT
├── LlmsTxtKit.sln                    # Solution file
│
├── src/
│   ├── LlmsTxtKit.Core/
│   │   ├── LlmsTxtKit.Core.csproj
│   │   ├── Parsing/                  # LlmsDocument model, parser, spec-compliant tokenization
│   │   ├── Fetching/                 # HTTP client, FetchResult types, retry logic, UA config
│   │   ├── Validation/               # ValidationReport, rule engine, freshness checks
│   │   ├── Caching/                  # In-memory + file-backed cache, TTL management
│   │   └── Context/                  # Context generation, section expansion, token budgeting
│   └── LlmsTxtKit.Mcp/
│       ├── LlmsTxtKit.Mcp.csproj
│       ├── Tools/                    # MCP tool definitions (discover, fetch, validate, etc.)
│       ├── Server/                   # MCP protocol handling, transport, registration
│       └── Program.cs                # Entry point, configuration, DI setup
│
├── tests/
│   ├── LlmsTxtKit.Core.Tests/
│   │   ├── ParserTests.cs            # Spec-compliant and edge-case parsing
│   │   ├── ValidatorTests.cs         # Per-rule validation testing
│   │   ├── FetcherTests.cs           # Mock HTTP scenarios (WAF block, 404, redirects, etc.)
│   │   ├── CacheTests.cs             # TTL, eviction, serialization
│   │   └── ContextTests.cs           # Context generation, Optional section handling
│   ├── LlmsTxtKit.Mcp.Tests/
│   │   └── ToolResponseTests.cs      # MCP protocol compliance
│   └── TestData/
│       ├── valid/                    # Corpus of well-formed llms.txt files from real sites
│       ├── malformed/                # Intentionally broken files for parser resilience testing
│       └── edge-cases/               # Unicode, very large files, empty files, etc.
│
├── docs/
│   ├── api/                          # Generated API reference from XML doc comments
│   └── images/                       # Architecture diagrams, data flow illustrations
│
└── specs/
    ├── prs.md                        # Product Requirements Specification
    ├── design-spec.md                # Architecture, components, data flow, decision rationale
    ├── user-stories.md               # Library consumer + MCP agent consumer stories
    └── test-plan.md                  # Coverage targets, integration scenarios, test data corpus
```

### Project Management

Both repos use **GitHub Projects** (the kanban board feature) for issue tracking. This serves dual purposes: it organizes the actual work, and it's publicly visible — anyone browsing the author's GitHub profile can see not just the code, but the structured progression from specification through implementation to completion. Issues are labeled by type (`spec`, `implementation`, `test`, `docs`, `blog`) and linked to the relevant milestone in the consolidated timeline.

The `llmstxt-research` repo's project board tracks the paper, benchmark, and blog posts. The `LlmsTxtKit` repo's project board tracks the library and MCP server. Cross-repo dependencies (e.g., "Benchmark data collection blocked until LlmsTxtKit `llmstxt_compare` tool is functional") are tracked as issues in the research repo with a link to the relevant LlmsTxtKit milestone.

---

## Blog Series Strategy

The following blog posts are designed to be published over the course of the project timeline, each serving dual purposes: sharing genuine research findings with the GEO community, and demonstrating the author's expertise for portfolio/job-search purposes. Each post practices what it preaches about GEO — it's structured for AI discoverability, contains original data or analysis, and uses proper citation and sourcing.

### Blog Post 1: "I Tried to Help AI Read My Website. My Own Firewall Said No."

**Type:** Personal narrative + technical deep dive  
**Timing:** Week 1-2 (publish early to establish the author's voice)  
**Content:** The author's firsthand experience with the WAF-blocking paradox. Concrete steps taken, what failed, what the error responses looked like, what Cloudflare dashboard settings were involved. Written in a tone that's technically precise but personally frustrated — relatable to anyone who's fought with CDN configuration. Ends by framing the problem as systemic rather than personal, leading the reader toward the analytical paper.  
**GEO Practice Demonstrated:** Original firsthand data, specific technical claims with evidence, clear narrative structure that AI systems can extract facts from.  
**Length:** 2,000-2,500 words.

### Blog Post 2: "llms.txt in 2026: What the Spec Says, What the Data Shows, and What Nobody's Talking About"

**Type:** Research summary (condensed version of the Paper)  
**Timing:** Week 4-5 (after the paper draft is complete)  
**Content:** The three key findings from the Paper, presented in blog format: (1) the inference gap (nobody reads it at inference time), (2) the infrastructure paradox (WAFs block it even when wanted), (3) the trust gap (no validation, no freshness, no consistency checks). Includes specific data points and source citations. Avoids the "is llms.txt dead?" framing — instead positions the analysis as "here's what's actually happening, and here's what needs to change."  
**GEO Practice Demonstrated:** Authoritative sourcing, statistical claims with provenance, structured arguments that address counterpoints.  
**Length:** 3,000-4,000 words.

### Blog Post 3: "Why There Are Zero .NET Tools for llms.txt (And What I'm Doing About It)"

**Type:** Project announcement + ecosystem analysis  
**Timing:** Week 6-7 (when LlmsTxtKit design spec is complete, before full implementation)  
**Content:** Documents the complete absence of .NET/C# tooling in the llms.txt ecosystem. Surveys existing tools (Python module, JavaScript implementation, Docusaurus plugin, VitePress plugin, Drupal module, PHP library). Explains what MCP is and why an MCP server is a meaningful integration point. Announces LlmsTxtKit with its design philosophy: documentation-first, validation-aware, cache-backed, WAF-tolerant. Includes code snippets showing the API surface.  
**GEO Practice Demonstrated:** Ecosystem survey with concrete evidence, technical depth that demonstrates credibility, open-source contribution announcement that invites community engagement.  
**Length:** 2,500-3,000 words.

### Blog Post 4: "A Technical Writer's Guide to Generative Engine Optimization"

**Type:** Practitioner guide  
**Timing:** Week 8-9  
**Content:** Bridges the gap between the GEO discourse (which is dominated by SEO marketers) and technical writing practice. Argues that good documentation has always been "GEO-optimized" — clear structure, authoritative sourcing, concise language, proper metadata. Covers: what GEO is and isn't, what the Princeton study found (citations and statistics improve AI visibility 30-40%, keyword stuffing decreases it ~10%), how llms.txt fits into a documentation strategy, what Mintlify means by "50% for humans, 50% for LLMs," and practical steps a technical writer can take today. Explicitly *does not* oversell llms.txt — presents it as one tool in a larger strategy, with appropriate caveats about the adoption gap.  
**GEO Practice Demonstrated:** The meta-recursive quality of writing good GEO content about GEO. Original synthesis of research from multiple sources. Practical, actionable advice grounded in evidence.  
**Length:** 3,000-3,500 words.

### Blog Post 5: "The Content Signals Landscape: Understanding robots.txt, llms.txt, Content Signals, and CC Signals"

**Type:** Comparative analysis / reference guide  
**Timing:** Week 10-11  
**Content:** A comprehensive, side-by-side comparison of every standard that governs how AI systems interact with web content. For each standard: what it does, who created it, what problem it solves, current adoption status, limitations. A table comparing scope, mechanism, enforcement model, and platform support across all standards. Positions these as complementary rather than competing — robots.txt handles access control, Content Signals handle usage rights, llms.txt handles content discovery, CC Signals handle values alignment. Identifies the gaps between them.  
**GEO Practice Demonstrated:** Comprehensive reference content that AI systems will find authoritative. Structured comparison that's easy to extract facts from. Neutral, evidence-based analysis rather than advocacy.  
**Length:** 3,500-4,500 words.

### Blog Post 6: "Does Clean Markdown Actually Help AI? First Results from an llms.txt Benchmark"

**Type:** Research results (condensed version of the Benchmark study)  
**Timing:** Week 14-16 (after data collection and initial analysis)  
**Content:** Presents the headline findings from the Benchmark study in accessible form. What the study measured, how it was designed, what the results show. Includes specific numbers: accuracy deltas, token savings, hallucination rate differences. Discusses what the results mean for practitioners: should you invest in llms.txt? What kinds of content benefit most? Honest about limitations and what the study can't tell you.  
**GEO Practice Demonstrated:** Original empirical data — the most authoritative form of content. Methodology transparency. Balanced interpretation that acknowledges uncertainty.  
**Length:** 3,000-4,000 words.

### Blog Post 7: "Building an MCP Server in C#: Lessons from LlmsTxtKit"

**Type:** Technical tutorial / post-mortem  
**Timing:** Week 12-14  
**Content:** A deep-dive into the engineering decisions behind LlmsTxtKit's MCP server. What MCP is, how it works, what the protocol looks like in practice. How the C# implementation handles async streaming, tool registration, error reporting, and state management. Lessons learned about designing tools that AI agents can use effectively (naming conventions, description quality, parameter design). Includes runnable code examples.  
**GEO Practice Demonstrated:** Technical depth, code-level specificity, practical guidance for a growing developer audience (MCP tooling builders).  
**Length:** 3,000-4,000 words.

### Blog Post 8: "What Jeremy Howard Got Right — And What the Ecosystem Still Needs"

**Type:** Constructive critique / forward-looking analysis  
**Timing:** Week 16+ (after all three projects have results)  
**Content:** A synthesis post that brings together all findings. What Howard's spec got right: the problem it identifies (HTML is wasteful for AI contexts) is real and measurable (citing the Benchmark). What it got wrong or left unaddressed: no validation mechanism, no infrastructure guidance, no discoverability mechanism for the llms.txt file itself (how does an AI even know to check for it?). What the ecosystem needs next: validation standards, a registry/CDN solution for cached llms.txt files, platform commitments to inference-time usage, tooling in enterprise-relevant ecosystems (.NET, Java, Go). Written with genuine respect for the spec's contributions while being honest about its gaps.  
**GEO Practice Demonstrated:** Synthesis of an entire research initiative into a coherent narrative. Original analysis built on original data. Forward-looking recommendations grounded in evidence rather than speculation.  
**Length:** 3,500-4,500 words.

---

## Navigating the Jeremy Howard Relationship

This section addresses a real constraint: the author's attempt to engage with Jeremy Howard (the llms.txt spec author, via Answer.AI) has been met with a standoffish reception. This is worth addressing strategically rather than emotionally, because how the author positions relative to the spec author matters for credibility.

### Understanding the Dynamic

Jeremy Howard is an accomplished researcher (former president of Kaggle, creator of fast.ai, deep learning educator) who has proposed many standards and tools over his career. The llms.txt spec was born from a specific personal frustration (FastHTML documentation inaccessibility to AI assistants) and grew rapidly in scope when the community adopted it. Howard's team at Answer.AI maintains the spec, the Python module, and the reference implementations.

People in Howard's position typically receive *enormous* volumes of unsolicited feedback, feature requests, partnership proposals, and collaboration offers — most of which are low-quality, self-serving, or don't demonstrate understanding of the project's goals. This creates a default defensive posture that has very little to do with the specific person being rebuffed and everything to do with information overload. It's not personal, even when it feels that way.

### The "Show, Don't Tell" Strategy

Rather than seeking permission or endorsement, the projects are designed to be valuable on their own terms. This approach works because:

**Original research doesn't require the spec author's blessing.** The Paper analyzes a public standard using public data. The Benchmark measures empirical outcomes using publicly available tools and models. LlmsTxtKit implements a public spec. None of this requires anyone's approval.

**Quality work attracts attention on its own timeline.** If the Paper produces genuinely novel analysis, if LlmsTxtKit fills a real ecosystem gap, and if the Benchmark produces data that nobody else has — the llms.txt community (including Howard) will encounter the work organically. A GitHub repository with thorough documentation, a blog post cited by other GEO writers, or a benchmark result referenced in the ongoing "is llms.txt dead?" discourse creates organic engagement that no cold email can replicate.

**Constructive critique is more credible than uncritical advocacy.** The Paper and Blog Post 8 specifically identify gaps in the spec and ecosystem — the absence of validation mechanisms, the infrastructure paradox, the inference gap. This isn't hostile criticism; it's the kind of analysis that *helps* a standard mature. If the work is done honestly and the critique is constructive, it positions the author as someone who has done their homework and cares about the standard's success, not just their own visibility.

### Specific Tactical Recommendations

1. **Do not seek approval before publishing.** The work speaks for itself. Asking for a "stamp of approval" from Howard before publishing signals that the work needs external validation to be credible. It doesn't.

2. **Cite the spec generously and accurately.** Every reference to llms.txt should cite the original spec at llmstxt.org, attribute authorship to Howard, and quote accurately. This demonstrates respect for the work without requiring a personal relationship.

3. **Contribute to the GitHub repository where appropriate.** If the research uncovers a spec ambiguity that causes parsing inconsistencies, file a clear, well-documented issue on the AnswerDotAI/llms-txt repo. If LlmsTxtKit reveals that the spec doesn't address a common edge case, describe it precisely. These are contributions to the standard, not requests for attention. They're also publicly visible evidence of engagement.

4. **Publish LlmsTxtKit as a listed integration.** The llmstxt.org page has an "Integrations" section listing community tools. Once LlmsTxtKit is released and documented, submit a PR adding it to that list. This is a standard open-source contribution workflow that doesn't require a personal relationship.

5. **Let the Benchmark data do the talking.** If the study shows that llms.txt-curated content measurably improves AI response quality, that single finding is more persuasive than any amount of relationship-building. If it shows marginal improvement, that's honest analysis that the community needs. Either way, it advances the discourse in a way that Howard — as someone who genuinely wants the standard to succeed — should appreciate, even if the relationship remains professionally distant.

6. **Build relationships laterally, not just upward.** The llms.txt community includes hundreds of implementors, tool builders, GEO practitioners, and documentation teams. Engaging with *them* — via the community Discord, via blog post comments, via cross-citations — builds a network of credibility that eventually reaches the spec author whether or not a direct relationship exists.

---

## Consolidated Timeline

| Week | Paper (P1) | LlmsTxtKit (P2) | Benchmark (P3) | Blog Posts |
|---|---|---|---|---|
| 1-2 | Research consolidation, outline; repo scaffolding | PRS, Design Spec drafting; repo scaffolding | — | Blog 1 (WAF story) |
| 3-4 | First draft | User Stories, Test Plan, API design | Corpus selection begins | — |
| 5-6 | Review, revision | Core library: Parser, Fetcher | Question authoring, gold-standard answers | Blog 2 (Paper summary) |
| 7-8 | Data verification, final draft; data appendix notebook | Core library: Validator, Cache, Context Gen | Infrastructure setup, data collection runner | Blog 3 (.NET gap) |
| 9-10 | **Paper complete** | MCP server implementation | Data collection begins (Phase 1: C#) | Blog 4 (Tech writer GEO), Blog 5 (Standards landscape) |
| 11-12 | — | Integration tests, documentation | Data collection continues | Blog 7 (MCP C# tutorial) |
| 13-14 | — | Packaging, README, **LlmsTxtKit v1.0** | Scoring; analysis notebook (Phase 2: Jupyter) | — |
| 15-16 | Paper revision with benchmark data | Bug fixes based on benchmark usage | Write-up + notebook finalized, **Benchmark complete** | Blog 6 (Benchmark results) |
| 17-18 | — | — | — | Blog 8 (Synthesis post) |

Total initiative duration: approximately 18 weeks (~4.5 months). The Paper can be published independently after week 9. LlmsTxtKit is usable in beta after week 10. Blog posts maintain a steady cadence of roughly one every two weeks throughout.

---

## Portfolio Impact

When complete, this initiative produces:

- **One original analytical paper** covering a topic nobody else has rigorously documented, with a companion data aggregation notebook.
- **One open-source .NET library and MCP server** filling a genuine ecosystem gap, with full documentation, unit tests, and integration tests.
- **One empirical benchmark study** producing data that doesn't exist anywhere in the current literature, with a Colab-compatible analysis notebook that lets anyone verify the published results.
- **Eight blog posts** demonstrating GEO expertise, technical writing quality, and sustained content production.
- **Two well-organized GitHub repositories** — one research, one software — showing documentation-first development methodology, C# proficiency, structured project management, and the ability to take a research question from "what should we investigate?" through "here's the tool" to "here's what the data shows."

For a technical writer and C#/.NET developer actively seeking employment, this body of work demonstrates exactly the intersection of skills that AI-era technical roles demand: the ability to research rigorously, write clearly, build working software, and communicate complex findings to multiple audiences.

---

## Appendix A: Key References

- Howard, J. (2024). "The /llms.txt file." llmstxt.org. https://llmstxt.org/
- AnswerDotAI. (2024). llms-txt GitHub repository. https://github.com/AnswerDotAI/llms-txt
- Cloudflare. (2025). "Giving users choice with Cloudflare's new Content Signals Policy." https://blog.cloudflare.com/content-signals-policy/
- Cloudflare. (2025). "Declaring your AIndependence: blocking AI bots, scrapers and crawlers with a single click." Cloudflare Blog.
- Mintlify. (2025). "The Value of llms.txt: Hype or Real?" https://www.mintlify.com/blog/the-value-of-llms-txt-hype-or-real
- Yoast. (2025). "What AI Gets Wrong About Your Site & llms.txt." https://yoast.com/what-ai-gets-wrong-about-your-site-llms-txt/
- Chroma Research. (2025). "Context Rot." https://research.trychroma.com/context-rot
- Emergent Mind. (2025). "Context Collapse." https://www.emergentmind.com/topics/context-collapse
- Aggarwal, P., et al. (2024). "GEO: Generative Engine Optimization." Princeton University. arXiv:2311.09735.
- llms-txt.io. (2025). "Is llms.txt Dead? The Current State of Adoption in 2025." https://llms-txt.io/blog/is-llms-txt-dead
- Shelby, C. (2025). "No, llms.txt is not the 'new meta keywords'." Search Engine Land.
- 365i. (2026). "Google Says Markdown for AI Is 'a Stupid Idea.' They're Half Right." https://www.365iwebdesign.co.uk/news/2026/02/08/google-markdown-ai-stupid-idea-discovery-files/
- Creative Commons. (2025). "CC Signals: What We've Been Working On." https://creativecommons.org/2025/12/15/cc-signals-what-weve-been-working-on/

## Appendix B: Connections to Existing Project Portfolio

These projects connect to the author's existing and planned work:

- **Chronicle** (CLI worldbuilding lore management with Git integration): LlmsTxtKit's parser design and documentation-first methodology are directly applicable. Chronicle could eventually generate its own llms.txt files for published worldbuilding content.
- **FractalRecall** (.NET hierarchical context-aware embedding retrieval): The Benchmark study's findings on context collapse directly inform FractalRecall's design decisions about how to structure hierarchical retrieval to minimize information loss.
- **Aethelgard** (TTRPG worldbuilding setting): As a large, complex documentation corpus, Aethelgard could serve as an additional test case for the Benchmark — measuring whether llms.txt-curated worldbuilding documentation produces better AI-assisted answers about lore and mechanics than raw HTML/Markdown retrieval.

---

*End of proposal document. Version 1.0 — February 2026.*
