# llms.txt Research & Tooling Initiative — Unified Roadmap

**Author:** Ryan
**Version:** 1.0
**Last Updated:** February 2026
**Status:** Active — Sprint 1 Complete (Feb 21, 2026)

> This roadmap covers all three repositories in the initiative: [llmstxt-research](https://github.com/southpawriter02/llmstxt-research), [LlmsTxtKit](https://github.com/southpawriter02/LlmsTxtKit), and the [portfolio website](https://github.com/southpawriter02/website). It is the living document that tracks what gets built, when, and how — while the [PROPOSAL.md](PROPOSAL.md) remains a historical snapshot of the original vision.

---

## How to Read This Document

This roadmap is organized into two main parts. The first part, **Phased Delivery Schedule**, summarizes the discrete deliverables — the paper, the library, the benchmark, the blog posts — and their dependencies on each other. This section is deliberately condensed because the proposal already covers these deliverables in depth. If you need the full rationale behind any deliverable, refer to the corresponding section in PROPOSAL.md.

The second part, **Ongoing Efforts**, is where this document adds the most value. These are the recurring, operational, and strategic activities that don't have a single "done" date — things like how blog posts move from draft to published, how community feedback gets incorporated, what the tech stack is and why, and how the three repos stay in sync over time. The proposal acknowledges these efforts exist but doesn't specify how they work. This document does.

---

## Phased Delivery Schedule

The initiative spans approximately 18 weeks (~4.5 months) organized into four phases. Each phase produces standalone deliverables while building toward the next phase's prerequisites.

### Phase 1: Foundations (Weeks 1–4)

**Goal:** Establish the research scaffolding and begin the analytical paper.

| Deliverable | Repository | Status | Notes |
|---|---|---|---|
| Repository scaffolding (both repos) | llmstxt-research, LlmsTxtKit | ✅ Complete | Directory structures, LICENSE, GitHub Projects boards, labels, issues — all automated via `scripts/gh-project/` |
| Paper outline and research consolidation | llmstxt-research | ✅ Complete | `paper/outline.md` v1.2, `paper/evidence-inventory.md` v2.0 (51 claims, 27+ sources, 12+ primary) |
| Paper first draft | llmstxt-research | 🔲 Not started | `paper/draft.md`, 6,000–10,000 words — Sprint 2+ |
| LlmsTxtKit PRS + Design Spec | LlmsTxtKit | ✅ Complete | `specs/prs.md`, `specs/design-spec.md` — stubs completed pre-sprint |
| LlmsTxtKit User Stories + Test Plan | LlmsTxtKit | ✅ Complete | `specs/user-stories.md`, `specs/test-plan.md` — stubs completed pre-sprint |
| Blog Post 1: WAF story | llmstxt-research | ✅ Complete | Published as "The WAF Paradox" (Parts 1 & 2) on Docusaurus blog. 7 total posts published (exceeds Sprint 1 target) |
| Benchmark corpus selection begins | llmstxt-research | 🔲 Not started | `benchmark/corpus/site-list.csv` initial population — Sprint 2 |

**Phase 1 exit criteria:** Paper first draft complete. LlmsTxtKit spec documents complete and reviewed. Blog Post 1 published. Benchmark corpus selection underway.

### Phase 2: Implementation (Weeks 5–10)

**Goal:** Build LlmsTxtKit's core library, finalize the paper, and prepare the benchmark infrastructure.

| Deliverable | Repository | Status | Notes |
|---|---|---|---|
| Paper review, revision, final draft | llmstxt-research | 🔲 Not started | Data verification pass, adoption stats notebook |
| Data aggregation notebook | llmstxt-research | 🔲 Not started | `paper/data/adoption-analysis.ipynb` (optional) |
| LlmsTxtKit Core: Parser + Fetcher | LlmsTxtKit | 🔲 Not started | `src/LlmsTxtKit.Core/Parsing/`, `Fetching/` |
| LlmsTxtKit Core: Validator + Cache + Context Gen | LlmsTxtKit | 🔲 Not started | Remaining Core components |
| LlmsTxtKit MCP server implementation | LlmsTxtKit | 🔲 Not started | `src/LlmsTxtKit.Mcp/` |
| Benchmark question authoring + gold answers | llmstxt-research | 🔲 Not started | `benchmark/corpus/questions.json`, `gold-answers.json` |
| Benchmark data collection runner | llmstxt-research | 🔲 Not started | `benchmark/scripts/run-benchmark.cs` |
| Blog Post 2: Paper summary | llmstxt-research | 🔲 Not started | Publish after paper draft is finalized |
| Blog Post 3: .NET ecosystem gap | llmstxt-research | 🔲 Not started | Publish when LlmsTxtKit design spec is complete |

**Phase 2 exit criteria:** Paper finalized and ready for publication. LlmsTxtKit core library passes all unit tests. MCP server functional. Benchmark data collection runner tested against at least 5 pilot sites.

**Key dependency:** Benchmark data collection (Phase 3) is blocked until LlmsTxtKit's `llmstxt_compare` tool is functional. This is the critical path item in Phase 2.

### Phase 3: Experimentation (Weeks 9–14)

**Goal:** Run the benchmark study, complete LlmsTxtKit integration testing, and publish the paper.

| Deliverable | Repository | Status | Notes |
|---|---|---|---|
| **Paper published** | llmstxt-research | 🔲 Not started | `paper/draft.pdf` finalized and distributed |
| LlmsTxtKit integration tests | LlmsTxtKit | 🔲 Not started | Mock HTTP server scenarios, MCP protocol compliance |
| LlmsTxtKit packaging + README + docs site | LlmsTxtKit | 🔲 Not started | NuGet packages, generated API reference |
| **LlmsTxtKit v1.0 release** | LlmsTxtKit | 🔲 Not started | Tagged release, NuGet publish |
| Benchmark data collection (Phase 1: C#) | llmstxt-research | 🔲 Not started | Full experimental run on Mac Studio |
| Benchmark scoring + analysis notebook | llmstxt-research | 🔲 Not started | `benchmark/results/analysis.ipynb` |
| Blog Post 4: Technical writer's GEO guide | llmstxt-research | 🔲 Not started | |
| Blog Post 5: Standards landscape | llmstxt-research | 🔲 Not started | |
| Blog Post 7: MCP C# tutorial | llmstxt-research | 🔲 Not started | Publish after LlmsTxtKit v1.0 |

**Phase 3 exit criteria:** LlmsTxtKit v1.0 released on NuGet. Benchmark data collection complete. Analysis notebook produces all figures and statistical tests.

### Phase 4: Synthesis (Weeks 15–18)

**Goal:** Finalize the benchmark, revise the paper with empirical data, and publish the synthesis blog post.

| Deliverable | Repository | Status | Notes |
|---|---|---|---|
| Benchmark write-up + notebook finalized | llmstxt-research | 🔲 Not started | `benchmark/write-up.md`, `write-up.pdf` |
| **Benchmark study complete** | llmstxt-research | 🔲 Not started | All deliverables published |
| Paper revision with benchmark data | llmstxt-research | 🔲 Not started | Cross-references to benchmark findings |
| LlmsTxtKit bug fixes from benchmark usage | LlmsTxtKit | 🔲 Not started | Issues discovered during data collection |
| Blog Post 6: Benchmark results | llmstxt-research | 🔲 Not started | |
| Blog Post 8: Synthesis | llmstxt-research | 🔲 Not started | Final post tying everything together |

**Phase 4 exit criteria:** All three core projects (Paper, LlmsTxtKit, Benchmark) complete with published artifacts. All eight blog posts published. Portfolio website updated with all content.

---

## Cross-Project Dependency Map

Some deliverables block others across repo boundaries. These are the dependencies that need active tracking:

| Blocked Item | Blocked By | Repo Boundary | Resolution |
|---|---|---|---|
| Benchmark data collection | LlmsTxtKit `llmstxt_compare` tool | llmstxt-research ← LlmsTxtKit | Track as issue in llmstxt-research linking to LlmsTxtKit milestone |
| Blog Post 2 (paper summary) | Paper first draft | Same repo | Sequential — draft before summarizing |
| Blog Post 3 (.NET gap) | LlmsTxtKit design spec | llmstxt-research ← LlmsTxtKit | Can draft early, finalize after spec review |
| Blog Post 6 (benchmark results) | Benchmark analysis notebook | Same repo | Sequential — data before narrative |
| Blog Post 7 (MCP tutorial) | LlmsTxtKit v1.0 | llmstxt-research ← LlmsTxtKit | Need stable API before writing tutorial |
| Blog Post 8 (synthesis) | All other projects | All repos | Intentionally last |
| Paper revision | Benchmark findings | Same repo | Optional revision pass after benchmark |
| Benchmark scoring rubric | Paper's context collapse definitions | Same repo | Paper defines the theoretical framework |
| Website blog content | llmstxt-research blog drafts | llmstxt-research → website | See Blog Publishing Workflow below |

---

## Ongoing Efforts

The following sections describe work that doesn't fit neatly into a single phase — it's continuous, recurring, or strategic. This is where the proposal was thinnest and where this roadmap adds the most operational detail.

### Blog Publishing Workflow

Blog posts originate as Markdown files in `llmstxt-research/blog/` and are published through the portfolio website, which runs on **Docusaurus 3.x** (a React-based static site generator). Understanding this workflow matters because blog posts are a primary output of the initiative and the pipeline from "research finding" to "published post" has several handoff points.

#### Writing and Drafting

All blog content is authored in the `llmstxt-research` repo first. This keeps the research and its public-facing narrative version-controlled together. The source-of-truth for blog post content is always the research repo, not the website repo.

Each blog post file in `llmstxt-research/blog/` uses standard Markdown with front matter metadata:

```markdown
---
title: "Blog Post Title"
date: YYYY-MM-DD
tags: [llmstxt, geo, research]
description: "One-sentence meta description for SEO and social sharing."
---

Post content here. Use <!-- truncate --> to mark excerpt boundary.
```

The drafting workflow is:

1. **Outline** — Sketch the post's argument, key data points, and citations. For posts that condense a larger deliverable (Post 2 from the paper, Post 6 from the benchmark), the outline pulls directly from the source document's structure.
2. **First draft** — Write in `llmstxt-research/blog/NN-slug.md`. Commit to a feature branch.
3. **Self-review** — Check factual claims against sources. Verify that every statistic has a citation. Confirm that the post practices the GEO principles it discusses (structured content, authoritative sourcing, clear metadata).
4. **Revision** — Incorporate feedback (see Feedback Solicitation below). Merge to main when satisfied.

#### Publishing to the Website

Once a blog post is finalized in the research repo, it needs to be adapted for the Docusaurus site. This is not a straight copy — Docusaurus has its own conventions:

**Docusaurus blog file structure:**
```
website/website/blog/
├── YYYY/
│   └── MM-DD-post-slug/
│       ├── index.mdx
│       └── img/
│           └── social-card.png
├── authors.yml
└── tags.yml
```

**Adaptation steps:**

1. **Create the post directory** in the website repo following the `YYYY/MM-DD-slug/` convention.
2. **Convert front matter** to Docusaurus format. Key differences from the research repo's Markdown:
   - `authors:` field references author IDs defined in `authors.yml` (not inline author names).
   - `tags:` must reference tags defined in `tags.yml`. Add new tags there first if needed.
   - `image:` field points to a social card image for Open Graph / social media sharing.
   - `slug:` field can override the URL path if the default isn't ideal.
3. **Convert Markdown to MDX** if needed. Docusaurus supports MDX (Markdown + JSX), which allows embedding React components for interactive elements, admonitions, tabs, etc. Most posts won't need this, but benchmark result posts with data visualizations might benefit from it.
4. **Add the `<!-- truncate -->` marker** to control where the blog list excerpt cuts off. The Docusaurus config enforces this (`onUntruncatedBlogPosts: 'throw'`).
5. **Create social card image.** Each post should have a `social-card.png` (1200×630px recommended) for link previews on social media. This can be generated from a template.
6. **Build and preview locally** (`yarn start:website:blogOnly`) to verify rendering.
7. **Commit and push** to trigger the deployment pipeline.

**Author setup (one-time):** Add your author entry to `website/website/blog/authors.yml`:

```yaml
ryan:
  name: Ryan
  title: Technical Writer & .NET Developer
  url: https://southpawriter.com
  image_url: https://github.com/southpawriter02.png
  page: true
  description: >
    Researcher focused on AI content retrieval, the llms.txt ecosystem,
    and Generative Engine Optimization (GEO).
  socials:
    github: southpawriter02
    email: ryan@southpawriter.com
```

**Tag setup:** Add llms.txt-initiative-specific tags to `website/website/blog/tags.yml`:

```yaml
llmstxt:
  label: llms.txt
  description: Posts about the llms.txt standard and ecosystem
geo:
  label: GEO
  description: Posts about Generative Engine Optimization
research:
  label: Research
  description: Original research findings and analysis
dotnet:
  label: .NET
  description: Posts about .NET/C# development
mcp:
  label: MCP
  description: Posts about the Model Context Protocol
```

#### Publishing Cadence

The target cadence is **one post every two weeks** across the 18-week initiative timeline. This is aggressive but achievable because each post is a derivative of a larger deliverable — the writing load is condensing and adapting, not generating from scratch.

| Post | Source Deliverable | Target Week | Estimated Adaptation Effort |
|---|---|---|---|
| 1: WAF story | Original content (personal narrative) | Week 1–2 | Full writing effort (~8–12 hours) |
| 2: Paper summary | Paper first draft | Week 4–5 | Condensation (~4–6 hours) |
| 3: .NET gap | LlmsTxtKit design spec + ecosystem survey | Week 6–7 | Mixed: survey is original, spec summary is condensation (~6–8 hours) |
| 4: Tech writer GEO | Synthesis of external research + original analysis | Week 8–9 | Full writing effort (~8–12 hours) |
| 5: Standards landscape | Paper Thread 4 + additional research | Week 10–11 | Expansion from paper section (~6–10 hours) |
| 6: Benchmark results | Benchmark analysis notebook | Week 14–16 | Condensation + narrative framing (~6–8 hours) |
| 7: MCP C# tutorial | LlmsTxtKit implementation experience | Week 12–14 | Full writing effort with code examples (~10–14 hours) |
| 8: Synthesis | All projects | Week 16–18 | Synthesis effort (~8–12 hours) |

Total estimated blog writing effort: **56–82 hours** across 18 weeks, or roughly **3–5 hours per week** dedicated to blog content.

#### RSS and Discoverability

Docusaurus auto-generates RSS and Atom feeds from the blog directory. These feeds are configured in `docusaurus.config.ts` and require no manual intervention. Once blog posts are published, they appear in the feed automatically.

For additional discoverability, each post should be:
- Shared on relevant social platforms (see Community Engagement below)
- Cross-posted or linked from the research repo's `blog/README.md` status tracker
- Referenced in the llmstxt-research README's blog table (update the status column from 🔲 to ✅ with a link)

---

### Community Engagement and Feedback Solicitation

The proposal identifies community engagement as important but doesn't specify tactics. This section lays out a concrete strategy for building audience, soliciting feedback, and incorporating external input — all critical for a research initiative that depends on credibility and reproducibility.

#### Target Communities

The initiative's work is relevant to several distinct communities. Each has different norms, platforms, and expectations:

**GEO / SEO Practitioners**
- **Where they are:** Twitter/X (search marketing community), LinkedIn (content strategy circles), Search Engine Land, Search Engine Journal, r/SEO, GEO-specific Discords/Slacks
- **What they care about:** Actionable guidance, data they can cite to clients/stakeholders, competitive intelligence on what platforms actually do versus what they say
- **How to engage:** Share blog posts with specific, quotable data points. Avoid jargon-heavy framing — lead with "here's what the data shows" not "here's my C# library." Posts 2, 4, 5, and 6 are the most relevant for this audience.
- **Feedback to solicit:** "Does this match what you're seeing in practice? Have you measured any impact from implementing llms.txt?"

**Developer Tools / .NET Community**
- **Where they are:** GitHub, r/dotnet, r/csharp, .NET-focused Discords, Hacker News, dev.to, the C# subreddit
- **What they care about:** Working code, NuGet packages they can install, API design quality, documentation-first methodology
- **How to engage:** LlmsTxtKit announcements, Blog Posts 3 and 7, GitHub Discussions on the LlmsTxtKit repo. Lead with "here's a package that solves a real problem" not "here's my research project."
- **Feedback to solicit:** "Does this API surface feel idiomatic? Are there .NET conventions I'm violating? What's your experience with MCP servers in .NET?"

**llms.txt Community**
- **Where they are:** The Answer.AI community Discord, llmstxt.org's integrations page, GitHub issues on AnswerDotAI/llms-txt, Twitter threads about llms.txt
- **What they care about:** Adoption data, tooling that works, spec clarifications, whether the standard is gaining traction
- **How to engage:** Submit LlmsTxtKit as an integration listing (PR to llmstxt.org). File well-documented spec ambiguity issues on the upstream repo. Share benchmark findings when available. Blog Posts 2 and 8 are directly relevant.
- **Feedback to solicit:** "Have you encountered this spec ambiguity? Does this parser behavior match your implementation's interpretation?"

**Technical Writing / Documentation Community**
- **Where they are:** Write the Docs community (Slack, conferences), r/technicalwriting, LinkedIn technical writing groups, documentation-focused newsletters
- **What they care about:** Content strategy, docs-as-code workflows, how AI changes documentation work
- **How to engage:** Blog Post 4 is specifically written for this audience. The documentation-first methodology of LlmsTxtKit is also relevant.
- **Feedback to solicit:** "How are you thinking about AI discoverability in your docs strategy? What GEO practices have you adopted or considered?"

#### Feedback Mechanisms

**GitHub Issues and Discussions:** Both repos should have GitHub Discussions enabled. Issues are for bugs and concrete problems; Discussions are for open-ended conversation about methodology, interpretation, and direction. Label issues by type (`spec`, `implementation`, `test`, `docs`, `blog`, `feedback`) and link them to the appropriate project board milestone.

**Blog Post Comments:** If the Docusaurus site has a comments system (Giscus, Disqus, or similar), enable it for blog posts. If not, add a "Discuss this post" link at the bottom of each post pointing to a GitHub Discussion thread for that post. This keeps feedback in a searchable, citable location rather than scattered across social media replies.

**Explicit Calls for Review:** Before publishing the paper and benchmark write-up, share drafts with a small group of people whose feedback you trust — either domain experts or technical writers who can catch structural and argumentative weaknesses. This isn't about seeking approval; it's about catching errors before they become public. A pre-publication review of 2–3 trusted readers per major deliverable is realistic.

**Responding to Feedback:** All substantive feedback (corrections, counterevidence, alternative interpretations) should be acknowledged publicly and, where warranted, incorporated into the relevant deliverable. If someone provides server log data that contradicts the paper's analysis, that's not a threat — it's additional evidence. The initiative's credibility depends on being visibly responsive to evidence, not on being right the first time.

#### Engagement Cadence

Engagement is not a one-time push at launch. It's a sustained, low-effort rhythm:

- **Per blog post:** Share on 2–3 relevant platforms within 24 hours of publication. Respond to comments/replies within 48 hours. Share any interesting discussions that emerge.
- **Per major milestone** (paper published, LlmsTxtKit v1.0, benchmark complete): Write a short announcement post on relevant platforms. Update the llmstxt-research README status indicators.
- **Weekly:** Spend 30–60 minutes reading what others are publishing about llms.txt, GEO, and related topics. Comment substantively on posts that intersect with the initiative's work. This is not "engagement farming" — it's staying current and being visibly part of the conversation.
- **Monthly:** Review GitHub issues and Discussions for any feedback that hasn't been addressed. Update this roadmap's status indicators. Check whether any external developments (spec updates, new competing standards, platform announcements) warrant adjusting the initiative's priorities.

---

### Tech Stack Rationale and Decisions

The proposal specifies certain technology choices but doesn't always explain the reasoning or the alternatives that were considered. This section documents those decisions so they're traceable and revisitable.

#### LlmsTxtKit: C# / .NET 8+

**Decision:** Target .NET 8.0 as the minimum framework version.

**Rationale:** .NET 8 is the current Long-Term Support (LTS) release (supported through November 2026). It provides nullable reference types, required properties, and modern C# language features that the library's API design depends on. Targeting .NET 8 rather than .NET 6 (the previous LTS) means dropping support for teams that haven't upgraded, but .NET 6 reaches end-of-support in November 2024 — by the time LlmsTxtKit ships, .NET 6 will be out of support. Targeting .NET 9 would exclude teams on the LTS track. .NET 8 is the sweet spot.

**Alternatives considered:**
- **.NET 6** — Too old. End-of-support before the library ships.
- **.NET 9** — Current release but not LTS. Enterprise teams on the LTS track wouldn't adopt it.
- **Multi-targeting (.NET 8 + .NET 9)** — Adds CI complexity for marginal benefit. Revisit after v1.0 if there's demand.

#### LlmsTxtKit: xUnit for Testing

**Decision:** Use xUnit as the test framework.

**Rationale:** xUnit is the de facto standard for .NET testing, used by the .NET runtime itself and by most open-source .NET libraries. Its `[Fact]` and `[Theory]` attributes map naturally to the test plan's structure (individual rule verification as Facts, parameterized edge-case coverage as Theories). NUnit and MSTest are viable alternatives but have smaller open-source community adoption.

#### Research: Jupyter + Python for Analysis (Not .NET Interactive)

**Decision:** Use standard Python/Jupyter for the benchmark analysis notebook, not .NET Interactive or Polyglot Notebooks.

**Rationale:** The benchmark has a two-phase design: data collection runs in C# (local, hardware-dependent), and data analysis runs in Python/Jupyter (universal, Colab-compatible). The analysis phase needs to be accessible to anyone — GEO researchers, data scientists, skeptics who want to verify the numbers. Python + pandas + scipy + matplotlib is the universal lingua franca for this kind of reproducible statistical analysis. .NET Interactive notebooks exist but have a much smaller audience, no Colab equivalent, and would add a C# dependency to a layer that explicitly should not have one.

**Alternatives considered:**
- **.NET Interactive / Polyglot Notebooks** — Poor Colab story. The audience for benchmark reproducibility is broader than the .NET community.
- **R / RMarkdown** — Viable for statistical analysis but less accessible to the GEO/SEO practitioner audience, which skews Python.
- **Observable / JavaScript notebooks** — Interesting for interactive visualizations but lacks the statistical library depth needed for paired hypothesis tests.

#### Website: Docusaurus 3.x

**Decision:** Use the existing Docusaurus-based portfolio website for publishing blog posts.

**Rationale:** The website already exists, already runs Docusaurus, and already has a blog infrastructure (authors.yml, tags.yml, feed generation, pagination). Building a separate blog or migrating to a different platform would be pure overhead with no benefit to the research initiative. Docusaurus's MDX support also allows embedding interactive React components in posts if the benchmark results call for interactive visualizations.

**Potential concern:** The existing website appears to be a fork or instance of the Docusaurus documentation site itself. If the blog content needs to feel distinct from the Docusaurus project's own content, custom theming or a dedicated blog section may be needed. This is a presentation concern, not a blocker.

#### Local Inference: LM Studio / Ollama on Mac Studio M3 Ultra

**Decision:** Run benchmark inference locally rather than via cloud APIs.

**Rationale:** The benchmark needs to test multiple models across two conditions (HTML vs. Markdown) for 30–50 sites × 5–10 questions. Using cloud API endpoints (OpenAI, Anthropic, etc.) would be expensive, rate-limited, and non-reproducible (model versions change without notice). Local inference on the Mac Studio M3 Ultra (512GB unified memory) allows running 70B+ parameter models at full precision, with complete control over model versions, quantization, and inference parameters. The tradeoff is that full replication requires equivalent hardware — but the analysis notebook (Phase 2) is fully reproducible on any Python environment, and that's the layer where reproducibility matters most.

**Alternatives considered:**
- **Cloud APIs** — Cost-prohibitive for the experimental volume needed. Non-reproducible due to model versioning.
- **Google Colab (GPU)** — Free tier GPUs can't run 70B models. Pro tier has usage limits. Doesn't support the C# data collection pipeline.
- **Smaller models only** — Would limit the study's ability to test whether model size interacts with the llms.txt effect, which is one of the most interesting research questions.

---

### Cross-Repository Coordination

The initiative spans three repositories with different audiences, release cadences, and contribution workflows. Keeping them in sync requires explicit coordination practices.

#### Shared Context: What Each Repo Knows About the Others

**llmstxt-research** is the hub. It contains this roadmap, the proposal, the cross-project reference map, and links to LlmsTxtKit. Its README lists all three projects and their statuses. When in doubt about the initiative's current state, check this repo first.

**LlmsTxtKit** is self-contained. Its README mentions the research initiative and links to the llmstxt-research repo, but it does not depend on the research repo for any runtime functionality. A developer can clone LlmsTxtKit, build it, and use it without ever looking at the research repo. This independence is intentional — the library's audience is broader than the research audience.

**The website** consumes content from llmstxt-research (blog posts) but does not produce content that flows back. It is a one-directional dependency: research → website, never website → research.

#### Synchronization Points

**When the paper is published:** Update the llmstxt-research README status from 🔲 to ✅. Update any "future work" references in LlmsTxtKit's README that point to the paper.

**When LlmsTxtKit reaches v1.0:** Update the llmstxt-research README to note the release. Update cross-references in the paper and benchmark that reference "the companion library" to include version numbers and NuGet package links. Submit the integration listing PR to llmstxt.org.

**When the benchmark is published:** Update the llmstxt-research README status. If the benchmark results warrant revising the paper, create a paper revision branch and update the paper's "Research Gaps" section to reference the now-published findings.

**When blog posts are published:** Update the blog status table in `llmstxt-research/blog/README.md`. Adapt and commit the post to the website repo. Update the research repo's README blog table status.

#### Issue Tracking Across Repos

Cross-repo dependencies are tracked as issues in the *blocked* repo (the one that's waiting) with a link to the relevant milestone or issue in the *blocking* repo. For example, "Benchmark data collection blocked until LlmsTxtKit `llmstxt_compare` tool is functional" lives as an issue in llmstxt-research with a link to the LlmsTxtKit milestone where that tool is being built.

Both repos use GitHub Projects (kanban boards) with consistent labeling:

| Label | Meaning | Used In |
|---|---|---|
| `spec` | Specification/documentation work | LlmsTxtKit |
| `implementation` | Code implementation | LlmsTxtKit |
| `test` | Test writing or test infrastructure | LlmsTxtKit, llmstxt-research |
| `docs` | Documentation (non-spec) | Both |
| `blog` | Blog post drafting/publishing | llmstxt-research |
| `paper` | Analytical paper work | llmstxt-research |
| `benchmark` | Benchmark study work | llmstxt-research |
| `feedback` | External feedback to triage | Both |
| `blocked` | Waiting on a cross-repo dependency | Both |

---

### Maintenance and Long-Term Sustainability

The initiative's core deliverables are designed to be "published and done" — the paper, the benchmark write-up, and the blog posts are artifacts with completion dates. But LlmsTxtKit is a software product, and the research findings may need updates as the ecosystem evolves. This section documents the maintenance commitments and their limits.

#### LlmsTxtKit Post-v1.0 Maintenance

**Committed:**
- Security patches and critical bug fixes for the v1.0 release line.
- Responding to GitHub issues within 1 week (acknowledgment, not necessarily resolution).
- Keeping the library buildable on current .NET SDK versions (addressing breaking changes in .NET 9+ if they affect the library).
- Updating the test corpus with new real-world llms.txt files as they're discovered or contributed.

**Tentative (post-v1.0 enhancements, contingent on community interest):**
- Content Signals integration — if the benchmark shows that content quality metadata improves retrieval outcomes, a Content Signals adapter is a natural extension.
- Registry integration — if a community-maintained llms.txt registry emerges.
- Broader spec coverage — if the llms.txt spec is updated or if competing standards (CC Signals, IETF aipref) gain traction.
- .NET 9 target framework addition — if there's demand from the community.

**Not committed:**
- Feature development beyond the v1.0 scope without community demand.
- Backward compatibility with .NET versions older than 8.0.
- Hosting or operating a public MCP server instance. LlmsTxtKit is a library and self-hosted server, not a SaaS product.

#### Research Updates

**The paper** may receive a revision pass after the benchmark results are available (Phase 4, Week 15–16). Beyond that, the paper is a point-in-time analysis. If the llms.txt ecosystem changes significantly (e.g., a major platform confirms inference-time usage, or the spec is substantially revised), a follow-up blog post is more appropriate than revising the original paper.

**The benchmark** publishes raw data specifically so that others can re-analyze it. If a methodology flaw is discovered post-publication, the correction is documented in the benchmark README and a corrected analysis notebook is published alongside the original (not replacing it). Transparency about corrections is more credible than silently updating.

**Blog posts** are not revised after publication except to fix factual errors. If new information warrants an update, a new post is written that references and builds on the original. This preserves the integrity of the publication timeline and avoids "stealth editing."

#### Responding to Ecosystem Changes

The llms.txt ecosystem is actively evolving. Several categories of external events could affect the initiative's priorities:

**If a major LLM provider confirms inference-time llms.txt usage:** This would validate the spec's design intent and significantly increase the paper's relevance. Write a blog post analyzing the announcement. Consider revising the paper's inference gap section. Increase priority on LlmsTxtKit's post-v1.0 enhancements (especially caching optimization for high-frequency inference-time requests).

**If the llms.txt spec is substantially revised:** Assess whether LlmsTxtKit's parser needs updating. File issues for any breaking changes. Write a blog post analyzing the revision. If the spec adds validation mechanisms or trust features, these would be high-priority additions to LlmsTxtKit.

**If a competing standard gains dominant adoption:** Assess whether LlmsTxtKit should add support for the competing standard (following the same parse → fetch → validate → cache → generate pattern). Update the paper's standards fragmentation section if warranted. Blog Post 5 (standards landscape) may need a follow-up.

**If the benchmark results show negligible difference:** This is a valid outcome, not a failure. The blog post framing shifts from "here's proof that llms.txt helps" to "here's data showing the difference is smaller than assumed — here's what that means for your content strategy." The research is valuable regardless of direction.

---

### Recommendations for Soliciting Research Feedback

Beyond the general community engagement strategy, the paper and benchmark specifically benefit from targeted feedback at key milestones. Here's a structured approach to finding and engaging reviewers.

#### Paper Feedback

**When to seek feedback:** After the first draft is complete (end of Phase 1) and before finalizing (Phase 2).

**Who to ask:**
- 1–2 people with GEO or SEO domain expertise who can validate whether the paper's practitioner recommendations are realistic.
- 1–2 people with infrastructure or web security experience who can validate the WAF-blocking technical claims.
- 1 person who is generally skeptical of llms.txt (to stress-test the paper's objectivity and ensure it isn't inadvertently reading as advocacy).

**How to ask:** Share the draft.md file directly (GitHub link to a branch, or a rendered PDF). Frame the request specifically: "I'd appreciate feedback on whether the technical claims in Section 5 (Infrastructure Paradox) match your experience" is more useful than "what do you think?" Give reviewers a 1–2 week window and a specific scope.

**Where to find reviewers:** The communities listed above. Look for people who have published their own analysis of llms.txt, written about WAF configuration, or authored GEO content. A thoughtful cold DM that demonstrates you've read their work is more effective than a mass request.

#### Benchmark Feedback

**When to seek feedback:** At two points — methodology review (before data collection, during Phase 2) and results review (before publication, during Phase 4).

**Methodology review:**
- Share `benchmark/methodology.md` and `benchmark/corpus/scoring-rubric.md`.
- Ask specifically: "Is this experimental design sound? Are there confounds I'm not accounting for? Is the scoring rubric clear enough for someone else to apply consistently?"
- Ideal reviewer: someone with experience designing controlled experiments or running benchmark studies.

**Results review:**
- Share the analysis notebook and write-up draft.
- Ask: "Do the statistical tests seem appropriate for this data? Are there alternative interpretations of these results that I should address?"
- Ideal reviewer: someone comfortable with statistical analysis who can catch errors in methodology or interpretation.

#### Benchmark Corpus Contributions

The benchmark needs 30–50 websites with both well-formed llms.txt files and substantial HTML documentation. The proposal focuses on developer documentation sites, but diversifying beyond that sector reduces selection bias.

**Contribution mechanism:** File an issue on the llmstxt-research repo with the `benchmark` label suggesting a site. Include the site URL, a link to its llms.txt file, and a brief note on why it's a good candidate (diverse content, well-maintained Markdown versions, non-developer-tools sector, etc.).

**Evaluation criteria for corpus sites:**
- Has a well-formed llms.txt file (passes LlmsTxtKit validation with no errors).
- Has Markdown versions of at least 5 pages linked from the llms.txt file.
- Has substantive content (not just a landing page with one paragraph).
- Ideally spans a sector underrepresented in the current corpus.

---

### Website and Portfolio Integration

The portfolio website serves as the public face of this research initiative. While the research repos are the source of truth for content, the website is where the audience encounters it.

#### What Gets Published Where

| Content Type | Source | Published On Website? | Format |
|---|---|---|---|
| Blog posts | `llmstxt-research/blog/` | Yes — primary publication venue | Docusaurus blog posts (MDX) |
| Paper | `llmstxt-research/paper/draft.md` | Link only (PDF download) | Referenced from a dedicated research page or blog post |
| Benchmark write-up | `llmstxt-research/benchmark/write-up.md` | Link only (PDF download) | Referenced from blog post 6 |
| LlmsTxtKit | Separate repo | Link from website projects page | GitHub repo link + NuGet badge |
| Raw data / notebooks | `llmstxt-research/benchmark/results/` | Links only | GitHub links + Colab badge |

#### Portfolio Page Updates

When each major milestone is reached, the website's portfolio or projects page should be updated to reflect the completed work. This isn't automated — it's a manual update that takes 15–30 minutes per milestone. The key updates are:

- **LlmsTxtKit v1.0:** Add a project card with description, GitHub link, NuGet badge, and a screenshot of the MCP tools in action (if applicable).
- **Paper published:** Add to a research section with title, abstract excerpt, and PDF download link.
- **Benchmark published:** Add to research section with headline finding, link to write-up, and "Open in Colab" badge for the analysis notebook.

---

## Status Legend

Throughout this document:

| Icon | Meaning |
|---|---|
| 🔲 | Not started |
| 🔄 | In progress |
| ✅ | Complete |
| ⏸️ | Paused or blocked |

---

## Revision History

| Version | Date | Changes |
|---|---|---|
| 1.0 | February 2026 | Initial roadmap extracted from PROPOSAL.md v1.1 with expanded ongoing-effort sections |
| 1.1 | February 21, 2026 | Sprint 1 status update: Phase 1 deliverables updated to reflect actual completion. Research consolidation, extension labeling audit, blog posts, shared artifacts, and project infrastructure all verified complete. See `sprint-1-assessment.md` for full audit. |

---

*This document is maintained in the [llmstxt-research](https://github.com/southpawriter02/llmstxt-research) repository and covers the full initiative across all three repos. For the original project vision and rationale, see [PROPOSAL.md](PROPOSAL.md).*
