# southpawriter: Content Strategy Beyond the Blog

> **Purpose:** A comprehensive analysis of the existing southpawriter Docusaurus site, with recommendations for help library content, new docs sections, and standalone pages that complement the blog without duplicating it.

---

## Current State Assessment

### What Exists Today

The site is built on **Docusaurus 3.9.2** (with v4 future compatibility flag enabled) using the classic preset. It has three content areas, but only one is actively populated:

- **Blog** — One substantial post published ("I Write the Docs Before the Code, and Yes, I Know That's Weird"), plus a detailed `blog-ideas.md` planning document with 21 standalone post ideas across five project areas. The blog has RSS/Atom feeds enabled, reading time estimates, and a well-structured `tags.yml` with three tags (Opinion, AI, Career).
- **Docs** — Currently contains only the default Docusaurus tutorial placeholder content (`intro.md`, `tutorial-basics/`, `tutorial-extras/`). The `blog-ideas.md` file lives here but is an internal planning doc, not published help content. The sidebar auto-generates from the `/docs` folder structure.
- **Pages** — The homepage (`src/pages/index.js`) is customized with a branded hero banner, three feature pillars (Tech Writing, AI Research, Dev Tooling), and two CTAs ("Read the Blog" and "Browse Docs"). There's also an orphaned `markdown-page.md` placeholder.

### Brand Identity and Audience

The site's tagline is *"A left-handed mind in a right-handed world."* The aesthetic is terminal/retro with dark mode default, monospace fonts, and pixel-art SVG illustrations. The three homepage pillars define the content scope clearly:

1. **Tech Writing** — Documentation-first thinking applied to AI workflows and developer tools
2. **AI Research** — Hands-on exploration of LLMs, web infrastructure, and industry direction
3. **Dev Tooling** — Building tools that help writers and non-programmers get value from AI

The audience, based on the blog post's voice and content, is technical professionals who are not necessarily full-time programmers — technical writers, developer advocates, documentation engineers, and "adjacent" technologists who use code as a means to an end rather than the end itself. There's also a strong secondary audience of C#/.NET developers who feel underserved by the Python-dominated AI ecosystem.

### Projects Referenced

The blog post and ideas document reference five active projects that drive the site's content:

| Project | Description | Content Role |
|---------|-------------|--------------|
| **LlmsTxtKit** | C#/.NET library for parsing, fetching, validating, caching llms.txt files; also an MCP server | Primary research subject, technical tutorials |
| **DocStratum** | llms.txt validator (like ESLint for a Markdown standard) | Standards compliance, tooling |
| **FractalRecall** | Metadata-as-DNA approach to vector embeddings and RAG | AI/ML conceptual explainers |
| **Lexichord** | AI orchestration tool for technical writers | Enterprise AI, workflow tooling |
| **Rune & Rust** | Text-based C# dungeon crawler | Design patterns, C# tutorials, creative coding |

---

## The Core Question: What Goes in Docs vs. Blog?

This is the crux of the matter. The blog is chronological, opinion-driven, and narrative. The docs section (which Docusaurus calls "docs" but is really a sidebar-navigated knowledge base) should be **evergreen, reference-oriented, and structured for findability**. Think of it this way:

- **Blog posts** answer: *"What's happening? What do I think about it? What did I learn?"*
- **Docs/Help pages** answer: *"How do I do this? What is this? Where do I find the thing I need?"*

A blog post titled "Why RAG Pipelines Lose Context" is a narrative exploration. A docs page titled "RAG Pipeline Context Loss: Causes and Mitigations" is a reference someone bookmarks and returns to. The blog post might *link to* the docs page. The docs page doesn't need to be entertaining — it needs to be *correct and findable*.

---

## Recommended Docs Sections

Here's where the real opportunity lives. The `/docs` directory should be restructured to replace the Docusaurus tutorial placeholders with original content organized into clear categories. Each category maps to a sidebar group.

### 1. Glossary / Terminology Reference

**Why it matters:** Your audience explicitly includes non-programmers and "adjacent" technologists. AI terminology is a moving target, and most glossaries online are either too shallow (marketing fluff) or too academic (assumes you already know half the terms). A glossary written by a technical writer *for* people who work alongside developers would be genuinely useful.

**Suggested structure:**

```
docs/glossary/
  _category_.json          → { "label": "Glossary", "position": 1 }
  index.md                 → Overview + how to use the glossary
  ai-fundamentals.md       → LLM, transformer, token, embedding, inference, fine-tuning, etc.
  rag-and-retrieval.md     → RAG, chunking, vector store, similarity search, reranking, etc.
  web-standards.md         → llms.txt, robots.txt, WAF, CDN, Content Signals, IETF aipref, etc.
  dev-tooling.md           → MCP, MCP server, orchestration, agent, tool use, context window, etc.
  dotnet-ai.md             → Semantic Kernel, ONNX Runtime, ML.NET, etc.
```

**Content style:** Each term gets a concise definition (2-3 sentences), an "in plain English" explanation, and optionally a "why it matters for writers" note. Cross-link liberally between terms and to relevant blog posts.

### 2. Project Documentation Hub

**Why it matters:** You have five projects, each with its own GitHub repo (presumably), but no centralized place to understand what they are, how they relate, and where to start. The docs section is the natural home for this.

**Suggested structure:**

```
docs/projects/
  _category_.json          → { "label": "Projects", "position": 2 }
  index.md                 → The "menagerie" overview — what each project is, how they connect
  llmstxtkit/
    overview.md            → What it does, who it's for, quick start
    architecture.md        → High-level design, module breakdown
    mcp-server.md          → How to use it as an MCP server for AI agents
    waf-handling.md        → How it handles the WAF-blocking paradox gracefully
  docstratum/
    overview.md            → What it validates, how to run it
    common-errors.md       → The most frequent llms.txt compliance issues (pairs with blog post #5)
  fractalrecall/
    overview.md            → The metadata-as-DNA thesis
    how-it-works.md        → Architecture and data flow
  lexichord/
    overview.md            → The problem it solves for technical writers
    style-guide-model.md   → How it represents and enforces style guides
  rune-and-rust/
    overview.md            → Why a dungeon crawler, what it teaches
    design-patterns.md     → State machines, narrative branching, combat mechanics
```

**Important note:** Per your docs-first philosophy, these pages should only be written when the underlying project documentation is stable enough to publish. The `overview.md` pages can come first since they're conceptual; the architecture and implementation pages should wait until the code is settled.

### 3. Guides and How-Tos

**Why it matters:** These are the "help library" pages — task-oriented content that walks someone through accomplishing a specific goal. They differ from blog tutorials in that they're not tied to a narrative or a moment in time. They're maintained, updated, and written to be discovered via search.

**Suggested topics:**

```
docs/guides/
  _category_.json                → { "label": "Guides", "position": 3 }
  setting-up-llmstxt.md          → How to create an llms.txt file for your site (step-by-step)
  validating-llmstxt.md          → Using DocStratum to validate your llms.txt file
  llmstxt-for-docusaurus.md      → Adding llms.txt to a Docusaurus site specifically
  building-mcp-servers-csharp.md → Practical guide to building MCP servers in C#/.NET
  docs-first-workflow.md         → How to adopt documentation-driven development
  geo-for-technical-writers.md   → Generative Engine Optimization — making your content AI-discoverable
  csharp-ai-getting-started.md   → Getting started with AI development in C#/.NET (the ecosystem map)
```

**Content style:** Each guide follows a consistent template: what you'll accomplish, prerequisites, step-by-step instructions, expected output, troubleshooting. No opinions, no narrative — just clear, tested instructions.

### 4. Research and Findings

**Why it matters:** The llms.txt research initiative (the analytical paper, the benchmark study) produces findings that are more permanent than blog posts. Blog posts can announce and discuss findings; docs pages can present the data itself in a structured, referenceable format.

**Suggested structure:**

```
docs/research/
  _category_.json                    → { "label": "Research", "position": 4 }
  index.md                           → Overview of research initiatives, methodology, status
  llmstxt-access-paradox/
    summary.md                       → Executive summary of the analytical paper's findings
    waf-analysis.md                  → Data on WAF blocking rates, by provider
    provider-adoption.md             → Which AI providers use llms.txt and how
    competing-standards.md           → llms.txt vs. Content Signals vs. CC Signals vs. IETF aipref
  context-collapse-benchmark/
    methodology.md                   → How the benchmark works, what it measures
    results.md                       → Findings (when available)
    dataset.md                       → Description of the test corpus
```

**Why this works in docs, not blog:** Research findings need to be citable, updatable, and structured. A blog post says "here's what I found." A docs page says "here are the findings" and gets updated as new data comes in. The blog post links to the docs page as the canonical source.

### 5. Resources and References

**Why it matters:** A curated collection of external resources, organized by topic, that your audience would find useful. This is the "help library" aspect — you're not just documenting your own projects, you're being a guide to the broader landscape.

**Suggested structure:**

```
docs/resources/
  _category_.json              → { "label": "Resources", "position": 5 }
  llmstxt-ecosystem.md         → Links to all known llms.txt tools, plugins, implementations
  csharp-ai-landscape.md       → Survey of C#/.NET AI libraries and tools (kept updated)
  ai-standards-tracker.md      → Living document tracking llms.txt, robots.txt updates, Content Signals, etc.
  recommended-reading.md       → Curated articles, papers, talks that inform your work
```

---

## Standalone Pages (src/pages)

Beyond docs and blog, Docusaurus supports standalone pages as React components or Markdown files in `src/pages/`. These are good for content that doesn't fit the sidebar-navigated docs structure.

### About Page (`src/pages/about.md` or `about.js`)

You don't currently have one. The blog post does a lot of "about me" work, but a dedicated About page is the canonical place for: who you are, what southpawriter is about, the docs-first philosophy, and how to get in touch. Keep it short, link to the blog for the full story.

### Projects Overview Page (`src/pages/projects.js`)

A visual, card-based overview of all five projects with status indicators, links to GitHub repos, and links to the relevant docs sections. Think of it as a portfolio page. This could also be a docs page, but a standalone page with custom React components (cards with SVG icons matching the pixel-art style) would be more visually engaging on the homepage navigation.

### Now Page (`src/pages/now.md`)

Borrowed from the [/now page movement](https://nownownow.com/about). A simple page that says: "Here's what I'm currently working on." Updated periodically. It's a living document that gives visitors context without requiring them to read through blog posts to figure out what's active. Very on-brand for a docs-first personality.

---

## Structural Recommendations

### Replace the Default Tutorial Content

The `docs/tutorial-basics/` and `docs/tutorial-extras/` directories contain Docusaurus's scaffold content. This should be removed before the site goes live (or as soon as possible if it's already live). Visitors clicking "Browse Docs" and landing on "Tutorial Intro: Let's discover Docusaurus in less than 5 minutes" is a poor first impression for a site about documentation quality.

### Clean Up the Orphaned Markdown Page

`src/pages/markdown-page.md` is a placeholder that says "You don't need React to write simple standalone pages." Remove it or replace it with something intentional (like the About page suggested above).

### Expand the Tags Taxonomy

The current `tags.yml` has three tags: Opinion, AI, Career. The `blog-ideas.md` document references many more: `fractalrecall`, `embeddings`, `rag`, `llmstxt`, `docstratum`, `csharp`, `gamedev`, `rune-and-rust`, `lexichord`, `technical-writing`, `tools`, `dotnet`, `mcp`, `lessons-learned`, `enterprise`, `tutorial`, `standards`, `explainer`, `documentation`. These should be added to `tags.yml` with descriptions before the corresponding posts are published.

### Consider a Sidebar Rename

The navbar currently labels the docs section as "Docs" with the sidebar ID `tutorialSidebar`. Once the tutorial content is replaced, the sidebar ID should be renamed (e.g., `mainSidebar` or `helpSidebar`) for clarity in the codebase. The user-facing label "Docs" is fine — or you might consider "Library" or "Knowledge Base" to distinguish it from the project-specific documentation that lives in GitHub repos.

### Add an llms.txt File

This one is almost too on-the-nose, but: a site about llms.txt research should have its own llms.txt file. Docusaurus has a plugin for this (`docusaurus-plugin-llms-txt`), or you can create one manually in the `static/` directory. It would be a nice bit of dogfooding and a concrete example for the guides section.

---

## Content Priority Matrix

If you're wondering where to start, here's a suggested priority order based on impact and effort:

| Priority | Action | Effort | Impact |
|----------|--------|--------|--------|
| 1 | Remove default tutorial content | Low | High (eliminates bad first impression) |
| 2 | Create About page | Low | Medium (establishes identity) |
| 3 | Write Glossary section (start with 15-20 core terms) | Medium | High (unique value, highly linkable) |
| 4 | Create Project overview pages (overview.md for each) | Medium | High (centralizes scattered project info) |
| 5 | Write "Setting up llms.txt" guide | Medium | High (practical, searchable, ties to research) |
| 6 | Add your own llms.txt file | Low | Medium (dogfooding, credibility) |
| 7 | Create Now page | Low | Low-Medium (personality, low maintenance) |
| 8 | Build out Research section | High | High (differentiator, but depends on research progress) |
| 9 | Resources/landscape pages | Medium | Medium (curation value, needs maintenance) |
| 10 | Remaining guides | High | High (but each is independent, write as needed) |

---

## A Note on the Docs-First Paradox

There's something delightfully recursive about this whole situation: you're a documentation-first developer whose site's documentation section is currently full of someone else's default tutorial content. The blog post talks about writing specs before code, but the "Browse Docs" button leads to a page about how to install Docusaurus.

This isn't a criticism — it's an observation that the docs section is your biggest untapped opportunity. The blog voice is strong, the projects are compelling, and the research is genuinely novel. The docs section is where all of that gets organized into something people can *use*, not just *read*. And given your philosophy, you probably already know that.
