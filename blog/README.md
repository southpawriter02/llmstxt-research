# Blog Series — Publication Schedule and Status

**Target cadence:** One post every ~2 weeks across the 18-week initiative timeline.
**Publication venue:** Portfolio website (Docusaurus 3.x) — adapted from drafts in this directory.
**Publishing workflow:** See the [Unified Roadmap](../ROADMAP.md) § Blog Publishing Workflow for the full pipeline from draft to published post.

---

## Status Tracker

| # | Title | Type | Target Week | Status | Published URL |
|---|---|---|---|---|---|
| 1 | "I Tried to Help AI Read My Website. My Own Firewall Said No." | Personal narrative + technical deep dive | Week 1–2 | 🔲 Not started | — |
| 2 | "llms.txt in 2026: What the Spec Says, What the Data Shows, and What Nobody's Talking About" | Research summary (Paper condensed) | Week 4–5 | 🔲 Not started | — |
| 3 | "Why There Are Zero .NET Tools for llms.txt (And What I'm Doing About It)" | Project announcement + ecosystem analysis | Week 6–7 | 🔲 Not started | — |
| 4 | "A Technical Writer's Guide to Generative Engine Optimization" | Practitioner guide | Week 8–9 | 🔲 Not started | — |
| 5 | "The Content Signals Landscape: Understanding robots.txt, llms.txt, Content Signals, and CC Signals" | Comparative analysis / reference guide | Week 10–11 | 🔲 Not started | — |
| 6 | "Does Clean Markdown Actually Help AI? First Results from an llms.txt Benchmark" | Benchmark results (Study condensed) | Week 14–16 | 🔲 Not started | — |
| 7 | "Building an MCP Server in C#: Lessons from LlmsTxtKit" | Technical tutorial / post-mortem | Week 12–14 | 🔲 Not started | — |
| 8 | "What Jeremy Howard Got Right — And What the Ecosystem Still Needs" | Synthesis / forward-looking analysis | Week 16–18 | 🔲 Not started | — |

---

## File Naming Convention

Blog post source files in this directory use the pattern `NN-slug.md`:

```
blog/
├── README.md              ← You are here
├── 01-waf-story.md
├── 02-paper-summary.md
├── 03-dotnet-gap.md
├── 04-techwriter-geo.md
├── 05-standards-landscape.md
├── 06-benchmark-results.md
├── 07-mcp-csharp-tutorial.md
└── 08-synthesis.md
```

These are the source-of-truth drafts. When a post is ready for publication, it is adapted to the Docusaurus blog format in the website repository. See the Roadmap's Blog Publishing Workflow section for the adaptation steps.

---

## Notes

- Posts 2 and 6 are condensations of the paper and benchmark write-up respectively. These can only be finalized after their source deliverables are complete.
- Post 7 (MCP C# tutorial) should only be finalized after LlmsTxtKit v1.0 is released, to ensure code examples reference a stable API.
- Post 8 (synthesis) is intentionally the last post, as it draws on findings from all three projects.
- For full post descriptions, content outlines, and GEO practice notes, see the Blog Series Strategy section in [`../PROPOSAL.md`](../PROPOSAL.md).
