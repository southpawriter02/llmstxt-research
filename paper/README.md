# "The llms.txt Access Paradox" — Analytical Paper

**Status:** 🔲 Not started
**Target length:** 6,000–10,000 words
**Output format:** Markdown source (`draft.md`) → PDF (`draft.pdf`)

---

## Overview

This paper documents the gap between the llms.txt standard's design intent (inference-time content discovery), the infrastructure reality (WAF/CDN blocking), and actual AI system behavior (no confirmed inference-time usage). It covers four analytical threads:

1. **The Inference Gap** — Evidence that no major LLM provider uses llms.txt at inference time.
2. **The Infrastructure Paradox** — How WAF systems and Cloudflare's default-block policies prevent AI crawlers from accessing llms.txt files, even when site owners want AI access.
3. **The Trust Architecture** — The absence of validation, freshness, and consistency mechanisms.
4. **Standards Fragmentation** — How llms.txt, Content Signals, CC Signals, and IETF aipref relate and conflict.

For the full paper outline, scope, and methodology, see the project proposal at [`../PROPOSAL.md`](../PROPOSAL.md) (Project 1 section).

---

## Deliverables and Status

| Deliverable | File | Status |
|---|---|---|
| Detailed section outline | `outline.md` | 🔲 Not started |
| First draft | `draft.md` | 🔲 Not started |
| Rendered PDF | `draft.pdf` | 🔲 Not started |
| Adoption statistics (CSV) | `data/adoption-stats.csv` | 🔲 Not started |
| Server log samples | `data/server-log-samples/` | 🔲 Not started |
| WAF config examples | `data/config-examples/` | 🔲 Not started |
| Data aggregation notebook | `data/adoption-analysis.ipynb` | 🔲 Not started (optional) |

---

## Directory Structure

```
paper/
├── README.md              ← You are here
├── outline.md             # Section-by-section outline with completion tracking
├── draft.md               # The paper (Markdown source)
├── draft.pdf              # Rendered PDF for distribution
├── data/
│   ├── adoption-stats.csv
│   ├── server-log-samples/
│   ├── config-examples/
│   └── adoption-analysis.ipynb
└── figures/               # Charts or diagrams referenced in the paper
```

---

## Timeline

| Phase | Target Weeks | Activity |
|---|---|---|
| Research consolidation + outline | Weeks 1–2 | Compile sources, write `outline.md` |
| First draft | Weeks 3–4 | Write `draft.md` |
| Review + revision | Weeks 5–8 | Data verification, revision, final draft |
| Publication | Week 9 | Render PDF, publish |
| Revision with benchmark data | Weeks 15–16 | Optional update with empirical findings |
