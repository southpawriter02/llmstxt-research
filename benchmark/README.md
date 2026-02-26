# Context Collapse Mitigation Benchmark

**Status:** 🔲 Not started — blocked on [LlmsTxtKit](https://github.com/southpawriter02/LlmsTxtKit) `llmstxt_compare` tool
**Output format:** Markdown write-up (`write-up.md`) → PDF, raw CSV data, Colab-compatible Jupyter analysis notebook

---

## Overview

The first controlled empirical study (to our knowledge) measuring whether llms.txt-curated content reduces context collapse in LLM responses. For a corpus of 30–50 websites that maintain both llms.txt and HTML documentation, we generate paired content — raw HTML processed through a standard text pipeline (Condition A) versus llms.txt-linked clean Markdown (Condition B) — and test whether the cleaner input produces measurably different results across multiple local LLMs.

This study is valuable regardless of outcome. If llms.txt Markdown significantly outperforms HTML-derived text, that's the strongest evidence yet for the standard's practical value. If the difference is negligible, that validates the position that modern LLMs parse HTML effectively and that llms.txt adds marginal benefit. Both outcomes are useful.

For the full methodology, experimental design, and analysis plan, see the project proposal at [`../PROPOSAL.md`](../PROPOSAL.md) (Project 3 section).

---

## Deliverables and Status

| Deliverable | File | Status |
|---|---|---|
| Test site corpus | `corpus/site-list.csv` | ✅ 37 sites verified |
| Question sets | `corpus/questions.json` | ✅ All 37 sites complete (286 questions) |
| Gold-standard answers | `corpus/gold-answers.json` | ✅ All 37 sites complete (286 answers) |
| Scoring rubric | `corpus/scoring-rubric.md` | ✅ Refined (v2) — corpus-calibrated examples, 10 edge cases |
| Runner design spec | `runner-design-spec.md` | ✅ Complete (architecture-level, reader-tested) |
| Data collection runner (C#) | `scripts/RunBenchmark/` | ✅ Complete (8 components, all spec checks verified) |
| Benchmark configuration | `scripts/benchmark-config.json` | ✅ Complete (schema doc: `scripts/benchmark-config-schema.md`) |
| Detailed methodology | `methodology.md` | ✅ All 7 sections complete |
| Reproducibility instructions | `REPRODUCING.md` | 🔲 Not started |
| Raw experimental data | `results/raw-data.csv` | 🔲 Not started |
| Analysis notebook (Jupyter) | `results/analysis.ipynb` | 🔲 Not started |
| Study write-up | `write-up.md` | 🔲 Not started |
| Rendered PDF | `write-up.pdf` | 🔲 Not started |

---

## Two-Phase Design

**Phase 1: Data Collection (C#)** — Runs locally on Mac Studio M3 Ultra (512GB RAM). Uses LlmsTxtKit's `llmstxt_compare` tool to generate content pairs, submits prompts to local LLM endpoints (LM Studio / Ollama), records raw responses to CSV/JSON. Requires specialized hardware; documented for reproducibility but not trivially replicable.

**Phase 2: Data Analysis (Python/Jupyter)** — Reads the raw CSV/JSON output from Phase 1. Pure pandas + scipy + matplotlib/seaborn. Zero .NET dependencies. Fully reproducible on Google Colab or any Python environment. This is the layer where universal reproducibility matters most.

<!-- TODO: Add "Open in Colab" badge once analysis.ipynb exists -->

---

## Metrics

| Metric | Type | Scale |
|---|---|---|
| Factual accuracy | Primary | 0–3 ordinal |
| Hallucination rate | Primary | Count per response |
| Token efficiency | Primary | Integer (input token count) |
| Completeness | Secondary | Binary |
| Citation fidelity | Secondary | Scored where applicable |

---

## Directory Structure

```
benchmark/
├── README.md              ← You are here
├── REPRODUCING.md         # Full reproducibility instructions
├── methodology.md         # Detailed methodology specification
├── write-up.md            # Study write-up (Markdown source)
├── write-up.pdf           # Rendered PDF
├── corpus/
│   ├── site-list.csv      # Test sites with URLs, llms.txt status, sector tags
│   ├── questions.json     # Question sets per site with complexity ratings
│   ├── gold-answers.json  # Researcher-authored correct answers
│   └── scoring-rubric.md  # Detailed scoring criteria with examples
├── scripts/
│   ├── RunBenchmark/              # C# data collection runner (.NET 9 console app)
│   │   ├── RunBenchmark.csproj    #   Project file with NuGet deps + LlmsTxtKit ref
│   │   ├── Program.cs             #   CLI entry point (phases, options, Ctrl+C)
│   │   ├── Models/                #   Strongly-typed config + corpus data models
│   │   └── Components/            #   ConfigLoader, Orchestrator, ContentAssembler,
│   │                              #     InferenceClient, ResultWriter, CheckpointManager,
│   │                              #     PreflightValidator
│   ├── benchmark-config.json      # Model specs, parameters, paths, run protocol
│   └── benchmark-config-schema.md # Config schema documentation with field definitions
└── results/
    ├── raw-data.csv       # Complete experimental results
    ├── analysis.ipynb     # Jupyter analysis notebook (Colab-compatible)
    └── figures/           # Generated figures referenced in write-up
```

---

## Timeline

| Phase | Target Weeks | Activity |
|---|---|---|
| Corpus selection + question authoring | Weeks 3–6 | Build `site-list.csv`, `questions.json`, `gold-answers.json` |
| Infrastructure setup | Weeks 7–8 | Data collection runner, local model config |
| Data collection (Phase 1: C#) | Weeks 9–12 | Full experimental run |
| Scoring + analysis (Phase 2: Jupyter) | Weeks 13–14 | `analysis.ipynb`, all figures and statistical tests |
| Write-up | Weeks 15–16 | `write-up.md`, `REPRODUCING.md`, render PDF |
