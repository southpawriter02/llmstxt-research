# Contributing to llmstxt-research

Thank you for your interest in contributing to the llms.txt Research & Tooling Initiative. This document explains how to report issues, suggest corrections, and contribute to the research.

---

## How to Contribute

### Corrections and Counterevidence

If the paper states something inaccurate, or if you have server log data, platform documentation, or other evidence that contradicts our findings, please file an issue with the `feedback` label. Include the specific claim you're disputing, the evidence you have, and where possible, a link to a public source. We take corrections seriously — getting the facts right matters more than being right the first time.

### Benchmark Corpus Suggestions

The benchmark study needs a diverse set of websites that maintain both well-formed llms.txt files and substantial HTML documentation. If you know of sites that should be included — particularly outside the developer tools sector, to reduce selection bias — please file an issue with the `benchmark` label. Include the site URL, a link to its llms.txt file, and a brief note on why it's a good candidate.

### Edge Cases and Test Data

LlmsTxtKit's test corpus (maintained in the [LlmsTxtKit repository](https://github.com/southpawriter02/LlmsTxtKit)) benefits from real-world llms.txt files that expose parser edge cases, unusual section structures, or non-standard Markdown. If you've encountered a file that doesn't parse cleanly, we'd like to add it as a test case. Submit it as an issue on the LlmsTxtKit repo with the `test` label.

### Blog Post Feedback

The blog posts are drafts until published. If you have domain expertise in GEO, technical writing, or AI content strategy, early feedback on drafts helps improve accuracy and completeness. Feedback can be submitted as GitHub Discussion comments or issues with the `blog` label.

---

## Issue Labels

We use the following labels to categorize issues across the project:

| Label | Description |
|---|---|
| `paper` | Related to the analytical paper |
| `benchmark` | Related to the benchmark study |
| `blog` | Related to blog posts |
| `feedback` | External feedback to triage |
| `blocked` | Waiting on a cross-repo dependency |
| `docs` | Documentation improvements |
| `test` | Test data or testing infrastructure |

---

## Style and Quality Standards

### Written Content

All written content in this repository — the paper, benchmark write-up, blog posts, and documentation — should meet the following standards:

- **Cite your sources.** Every factual claim should be traceable to a specific source. Use inline links for web sources and reference the shared bibliography in `shared/references.md` for frequently-cited works.
- **Be precise.** Prefer specific numbers over vague qualifiers. "844,000+ websites" is better than "many websites." "20% of public websites" is better than "a large portion."
- **Acknowledge uncertainty.** If the evidence is mixed, contradictory, or incomplete, say so. The initiative's credibility depends on honest analysis, not on projecting false confidence.
- **Write for multiple audiences.** The paper serves GEO practitioners, AI engineers, and documentation teams. Blog posts vary in audience. Keep jargon in check and define terms on first use, or reference the shared glossary in `shared/glossary.md`.

### Code Artifacts

Code in this repository (scripts, notebooks, configuration files) follows these conventions:

- **Python code** (Jupyter notebooks) follows PEP 8 and uses type hints where practical.
- **C# code** (benchmark data collection runner) follows the .NET coding conventions established in the [LlmsTxtKit CONTRIBUTING guide](https://github.com/southpawriter02/LlmsTxtKit/blob/main/CONTRIBUTING.md).
- **All code includes inline comments** explaining what it does and why, at a level appropriate for readers who are not the original author.

---

## Code of Conduct

This project follows the [Contributor Covenant Code of Conduct](https://www.contributor-covenant.org/version/2/1/code_of_conduct/). By participating, you agree to uphold a welcoming, inclusive, and respectful environment.

---

## Questions?

If you're unsure how to contribute or where something belongs, open a GitHub Discussion. We'd rather help you contribute than miss a valuable input because the process was unclear.
