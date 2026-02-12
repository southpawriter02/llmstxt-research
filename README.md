# llmstxt-research

**Original research, empirical benchmarks, and practitioner guidance for the llms.txt ecosystem.**

[![License: CC BY 4.0](https://img.shields.io/badge/Written_Content-CC_BY_4.0-lightgrey.svg)](https://creativecommons.org/licenses/by/4.0/)
[![License: MIT](https://img.shields.io/badge/Code-MIT-blue.svg)](https://opensource.org/licenses/MIT)

---

## Why This Repository Exists

The `/llms.txt` standard — proposed by Jeremy Howard of [Answer.AI](https://answer.ai) in September 2024 — was designed to solve a real problem. AI systems struggle to extract useful information from modern web pages because HTML is bloated with navigation, cookie banners, advertising scripts, and CSS that have nothing to do with the content a user actually asked about. The llms.txt spec offers a simple, elegant solution: place a Markdown file at your site's root that tells AI systems where your best, cleanest content lives, and provide Markdown versions of your pages that strip away the noise.

It's a good idea. Over 800,000 websites have implemented some form of llms.txt file. Anthropic, Cloudflare, Stripe, and Vercel all have one. The developer tools and documentation community adopted it enthusiastically.

But between the spec's design intent and the reality of how AI systems interact with the web today, there are gaps — significant ones — that nobody has rigorously documented, measured, or addressed with working tools. The discourse around llms.txt is stuck in a loop of opinion pieces and recycled talking points. One side says "implement llms.txt, it's the future." The other side says "it's dead on arrival, nobody reads it." Neither side has produced the primary-source evidence to support their claims.

This repository exists to change that.

We produce original research, build tools that work, and publish data that anyone can verify. The goal is not to advocate for or against llms.txt, but to give the community — developers, technical writers, GEO practitioners, AI infrastructure engineers, and documentation teams — the evidence and tooling they need to make informed decisions about AI content strategy.

---

## The Problems We're Investigating

### The Inference Gap

The llms.txt spec was explicitly designed for **inference time** — the moment when an AI system is answering a specific user question and needs to retrieve authoritative content right now. But no major LLM provider has publicly confirmed that they use llms.txt at inference time. Server log data from multiple sources shows contradictory behavior: some sites see AI crawlers requesting llms.txt every 15 minutes; others see zero requests over 60+ days. The evidence that does exist suggests crawlers are consuming llms.txt for **training data collection**, not for real-time retrieval — which is the opposite of what the spec was designed for.

This matters because if nobody reads the file when it's supposed to be read, implementing it is a maintenance cost with no measurable return. Understanding *why* the inference gap exists — and what would need to change for platforms to close it — is the central question of our analytical paper.

### The Infrastructure Paradox

Even when site owners *want* AI systems to access their llms.txt files, the web's security infrastructure often prevents it. Cloudflare — which sits in front of roughly 20% of all public websites — began blocking all AI crawlers by default on new domains in July 2025. AI crawlers trigger bot-detection heuristics because they don't execute JavaScript, don't maintain cookies, originate from data center IP ranges, and use non-browser user agents. Web Application Firewalls treat these signals as threats.

The result is a three-way misalignment that undermines the entire value proposition:

1. **Site owners** create llms.txt to help AI systems find their best content.
2. **Hosting infrastructure** blocks AI crawlers from accessing it.
3. **AI systems** fall back to search APIs instead of directly fetching curated content.

Everyone does their part. The system still doesn't work. We call this the **Access Paradox**, and documenting it with concrete technical evidence is one of this initiative's most original contributions.

### The Trust Question

Google's John Mueller compared llms.txt to the discredited keywords meta tag — and while that comparison was dismissive, it reflects a genuine engineering concern. Because llms.txt content is maintained separately from the HTML it describes, there is no built-in mechanism to verify that the Markdown matches the live page, detect when it becomes stale, or prevent deliberate manipulation. Research has shown that content-level prompts embedded in llms.txt files can make LLMs 2.5× more likely to recommend targeted content. Without validation, freshness checks, or consistency verification, platforms have rational reasons to distrust llms.txt content — even when it's authored in good faith.

Understanding the trust architecture gap and proposing what validation would look like is essential groundwork for any future platform adoption.

### The Measurement Gap

Perhaps most critically: **nobody has measured whether llms.txt actually helps.** The entire discourse is built on the assumption that cleaner Markdown input produces better AI output, but no controlled study has compared AI response quality when given llms.txt-curated content versus standard HTML-derived text. We don't know if the token savings are significant. We don't know if accuracy improves. We don't know if hallucination rates decrease. We don't know if certain types of content benefit more than others.

Without that data, every recommendation about llms.txt — for or against — is speculation. Our benchmark study produces the data.

---

## What's In This Repository

This repository contains three interconnected research projects and an accompanying blog series. They progress from "here's the problem" to "here's a tool that could help" to "here's whether it actually works." For the phased delivery schedule, cross-repo coordination strategy, blog publishing workflow, and ongoing effort details, see the **[Unified Roadmap](ROADMAP.md)**.

### 📄 The Paper: "The llms.txt Access Paradox"

**Location:** [`paper/`](paper/)

A 6,000–10,000 word analytical paper that documents the gap between llms.txt's design intent, the infrastructure reality, and actual AI system behavior. This is not an opinion piece — it's a primary-source analysis built on server log evidence, Cloudflare policy documentation, firsthand WAF-blocking experience, and a systematic survey of the competing standards landscape (Content Signals, CC Signals, IETF aipref, and robots.txt).

The paper covers four analytical threads: the inference gap (nobody reads it at inference time), the infrastructure paradox (WAFs block it even when wanted), the trust architecture (no validation or freshness mechanisms), and standards fragmentation (how multiple overlapping standards relate and conflict). It concludes with evidence-based recommendations for GEO practitioners and explicit identification of the research gaps that the benchmark study addresses.

**Deliverables:** Markdown source → PDF, data appendix with adoption statistics, optional Jupyter notebook documenting data aggregation methodology.

**Status:** 🔲 Not started

### 📊 The Benchmark: "Context Collapse Mitigation"

**Location:** [`benchmark/`](benchmark/)

The first controlled empirical study (to our knowledge) measuring whether llms.txt-curated content reduces context collapse in LLM responses. For a corpus of 30–50 websites that maintain both llms.txt and HTML documentation, we generate paired content — raw HTML processed through a standard text pipeline (Condition A) versus llms.txt-linked clean Markdown (Condition B) — and test whether the cleaner input produces measurably different results across multiple local LLMs.

Metrics include factual accuracy (scored against researcher-authored gold-standard answers), hallucination rate, completeness, citation fidelity, and token efficiency. The study uses a two-phase approach: data collection runs in C# via [LlmsTxtKit](https://github.com/YOUR_USERNAME/LlmsTxtKit) on local hardware, while data analysis runs in a Colab-compatible Jupyter notebook that anyone can execute against the published raw data.

This study is valuable regardless of outcome. If llms.txt Markdown significantly outperforms HTML-derived text, that's the strongest evidence yet for the standard's practical value. If the difference is negligible, that validates the position that modern LLMs parse HTML effectively and that llms.txt adds marginal benefit. Both outcomes are useful, and both redirect the community's effort toward strategies that actually work.

**Deliverables:** Study write-up (Markdown → PDF), raw experimental data (CSV), Colab-compatible analysis notebook, scoring rubric, gold-standard answer set, C# data collection runner, full reproducibility documentation.

**Status:** 🔲 Not started — blocked on LlmsTxtKit `llmstxt_compare` tool

### ✍️ The Blog Series

**Location:** [`blog/`](blog/)

Eight posts published over the course of the initiative, each serving dual purposes: sharing research findings with the GEO and AI content strategy community, and demonstrating that good technical writing *is* good GEO. Each post practices what it preaches — structured for AI discoverability, grounded in original evidence, and properly sourced.

| # | Title | Type | Status |
|---|---|---|---|
| 1 | "I Tried to Help AI Read My Website. My Own Firewall Said No." | Personal narrative + technical deep dive | 🔲 |
| 2 | "llms.txt in 2026: What the Spec Says, What the Data Shows, and What Nobody's Talking About" | Research summary (Paper condensed) | 🔲 |
| 3 | "Why There Are Zero .NET Tools for llms.txt (And What I'm Doing About It)" | Project announcement + ecosystem analysis | 🔲 |
| 4 | "A Technical Writer's Guide to Generative Engine Optimization" | Practitioner guide | 🔲 |
| 5 | "The Content Signals Landscape: Understanding robots.txt, llms.txt, Content Signals, and CC Signals" | Comparative analysis / reference guide | 🔲 |
| 6 | "Does Clean Markdown Actually Help AI? First Results from an llms.txt Benchmark" | Benchmark results (Study condensed) | 🔲 |
| 7 | "Building an MCP Server in C#: Lessons from LlmsTxtKit" | Technical tutorial / post-mortem | 🔲 |
| 8 | "What Jeremy Howard Got Right — And What the Ecosystem Still Needs" | Synthesis / forward-looking analysis | 🔲 |

---

## Companion Repository

### 🛠️ LlmsTxtKit — C#/.NET Library and MCP Server

**Repository:** [LlmsTxtKit](https://github.com/YOUR_USERNAME/LlmsTxtKit)

The practical implementation arm of this initiative. LlmsTxtKit is an open-source C#/.NET library and MCP (Model Context Protocol) server that implements llms.txt-aware content retrieval, parsing, validation, and caching. It fills the complete absence of .NET tooling in the llms.txt ecosystem and provides the data collection infrastructure for the benchmark study.

LlmsTxtKit is maintained as a separate repository because it's a shipping software product with its own audience, release cycle, and NuGet package — distinct from this research repository. See the [LlmsTxtKit README](https://github.com/YOUR_USERNAME/LlmsTxtKit) for installation, API documentation, and usage examples.

---

## How These Projects Connect

The three projects are designed to reference each other and collectively tell a coherent story. This table maps the connections:

| Concern | Paper | LlmsTxtKit | Benchmark |
|---|---|---|---|
| **Problem definition** | Defines the Access Paradox and inference gap | Implements workarounds for the Access Paradox | Tests whether solving the problem actually matters |
| **Trust & validation** | Analyzes the trust architecture gap | Implements `ValidationReport` and freshness checks | Measures whether validated content improves outcomes |
| **WAF blocking** | Documents the blocking mechanisms | Implements graceful degradation and `FetchResult` types | Uses LlmsTxtKit to handle blocking during data collection |
| **Context collapse** | Introduces and categorizes three forms | Provides `llmstxt_compare` for paired content generation | Empirically measures context collapse mitigation |
| **Standards landscape** | Maps how llms.txt, Content Signals, CC Signals, aipref relate | Implements the llms.txt spec | Tests llms.txt specifically; framework extensible to other standards |
| **Practitioner guidance** | Discusses what practitioners should do | Provides a tool practitioners can use | Provides evidence to inform practitioner decisions |
| **Reproducibility** | Source citations verifiable by reader | Unit and integration tests; test corpus of real files | C# data collection documented for replication; Jupyter analysis fully reproducible on Colab |

---

## Repository Structure

```
llmstxt-research/
├── README.md                         ← You are here
├── PROPOSAL.md                       # Full unified project proposal (v1.1)
├── ROADMAP.md                        # Unified roadmap across all three repos (living document)
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
│   │   └── adoption-analysis.ipynb   # Notebook documenting data aggregation methodology
│   └── figures/                      # Charts or diagrams used in the paper
│
├── benchmark/
│   ├── README.md                     # Study overview, methodology summary, status
│   ├── REPRODUCING.md                # Full reproducibility instructions
│   ├── methodology.md                # Detailed methodology specification
│   ├── write-up.md                   # The benchmark study write-up (Markdown source)
│   ├── write-up.pdf                  # Rendered PDF for formal distribution
│   ├── corpus/
│   │   ├── site-list.csv             # Test sites with URLs, llms.txt status, sector tags
│   │   ├── questions.json            # Question sets per site with complexity ratings
│   │   ├── gold-answers.json         # Researcher-authored correct answers
│   │   └── scoring-rubric.md         # Detailed scoring criteria with examples
│   ├── scripts/
│   │   ├── run-benchmark.cs          # C# data collection orchestrator
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
    ├── references.md                 # Shared bibliography (paper + benchmark)
    ├── glossary.md                   # Shared terminology definitions
    └── references.bib                # Optional structured bibliography (BibTeX)
```

---

## Who This Is For

**GEO / SEO practitioners** who need to make evidence-based decisions about whether to implement llms.txt and how to position their content for AI discoverability. The paper and blog series provide the analysis; the benchmark provides the data.

**AI infrastructure engineers** who encounter the content retrieval problem when building AI-integrated applications. LlmsTxtKit provides working tooling; the paper documents the infrastructure challenges you'll encounter (WAF blocking, inconsistent crawler behavior, standards fragmentation).

**Technical documentation teams** evaluating their content strategy for an AI-mediated future. The "Technical Writer's Guide to GEO" blog post and the standards landscape comparison are written specifically for this audience.

**llms.txt implementors and advocates** who want the standard to succeed and need to understand what's preventing broader platform adoption. Constructive critique — grounded in evidence, not in dismissiveness — is how standards mature.

**Researchers** studying AI content retrieval, context collapse, or the emerging GEO field. The benchmark's raw data, methodology, and analysis notebook are published for full reproducibility.

---

## Contributing

We welcome contributions that improve the quality, accuracy, or scope of this research. See [CONTRIBUTING.md](CONTRIBUTING.md) for details.

The most valuable contributions are:

**Corrections and counterevidence.** If the paper states something inaccurate, or if you have server log data or platform documentation that contradicts our findings, we want to know. File an issue with the evidence and we'll investigate.

**Benchmark corpus suggestions.** The benchmark study needs a diverse set of websites that maintain both well-formed llms.txt files and substantial HTML documentation. If you know of sites that should be included — particularly outside the developer tools sector, to reduce selection bias — please suggest them via issue.

**Edge cases and test data.** LlmsTxtKit's test corpus benefits from real-world llms.txt files that expose parser edge cases, unusual section structures, or non-standard Markdown. If you've encountered a llms.txt file that doesn't parse cleanly, we'd like to add it to the test suite.

**Blog post feedback.** The blog posts are drafts until published. If you have domain expertise in GEO, technical writing, or AI content strategy, early feedback on drafts helps improve accuracy and completeness.

---

## Acknowledgments

The `/llms.txt` standard was created by [Jeremy Howard](https://jeremy.fast.ai/) and the [Answer.AI](https://answer.ai) team. The specification is maintained at [llmstxt.org](https://llmstxt.org/) and the reference implementation is at [github.com/AnswerDotAI/llms-txt](https://github.com/AnswerDotAI/llms-txt). This research builds on their work and cites it throughout.

This initiative also draws on published research from Chroma Research (context rot), Princeton University (GEO), Cloudflare (Content Signals), Mintlify (llms.txt adoption data), and Yoast (server log analysis). Full citations are in [`shared/references.md`](shared/references.md).

---

## License

Written content (paper, benchmark write-up, blog posts, documentation) is licensed under [CC BY 4.0](https://creativecommons.org/licenses/by/4.0/). You are free to share and adapt this material with attribution.

Code artifacts (scripts, notebooks, configuration files) are licensed under the [MIT License](https://opensource.org/licenses/MIT).

See [LICENSE](LICENSE) for the full text of both licenses.
