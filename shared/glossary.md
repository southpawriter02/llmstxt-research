# Shared Glossary

Definitions for terms used across the paper, benchmark, and blog posts. When a term first appears in any deliverable, it should be defined inline and match the definition here.

---

**Access Paradox** — The three-way misalignment where site owners create llms.txt to help AI systems, hosting infrastructure blocks AI crawlers from accessing it, and AI systems fall back to search APIs instead of directly fetching curated content. Coined and documented in the paper ("The llms.txt Access Paradox").

**AI Crawl Control** — Cloudflare's dashboard feature that allows site owners to configure how different categories of AI bots interact with their site. Granular controls for `ai-train`, `search`, and `ai-input` permissions. Note: WAF custom rules execute *before* AI Crawl Control settings, which means a security rule can block an AI crawler even when AI Crawl Control says "allowed."

**CC Signals** — A framework from Creative Commons (2025) for expressing how content should be used in AI development, emphasizing reciprocity, recognition, and sustainability. Still in pilot phase as of December 2025.

**Content Signals** — Cloudflare's Content Signals Policy (September 2025), which extends `robots.txt` with three machine-readable directives (`search`, `ai-input`, `ai-train`) governing how crawlers may use content. Fundamentally different from llms.txt: Content Signals govern *permission*, while llms.txt governs *discovery*.

**Context Collapse** — The degradation of AI system performance caused by noisy, irrelevant, or excessive input. This initiative identifies three distinct forms:
- **Retrieval-Time Context Collapse** — When noisy HTML content (navigation, cookie banners, scripts) consumes context budget that should be allocated to substantive content. This is the form llms.txt is designed to address.
- **Epistemic Context Collapse** — The loss of diversity in LLM outputs, where larger models converge on homogenized, high-probability responses.
- **Within-Conversation Context Degradation** — Gradual breakdown of coherence in long conversations as earlier context falls outside the model's effective attention window.

**GEO (Generative Engine Optimization)** — The practice of optimizing content for visibility and quality in AI-generated responses, as distinct from traditional SEO which targets search engine result pages. Term coined by Princeton University researchers (Aggarwal et al., 2024).

**Inference Gap** — The disconnect between llms.txt's designed purpose (inference-time content retrieval) and the reality that no major LLM provider has publicly confirmed using llms.txt at inference time. Server log evidence suggests llms.txt is consumed for training data collection, not real-time retrieval.

**Inference Time** — The moment when an AI system is generating a response to a specific user query. Distinct from training time (when the model's weights are being updated) and indexing time (when a search system is building its database). The llms.txt spec explicitly targets inference-time usage.

**llms.txt** — A convention proposed by Jeremy Howard of Answer.AI (September 2024) where websites place a Markdown file at their root (`/llms.txt`) that tells AI systems where to find clean, curated content. The spec defines a minimal structure: an H1 title, an optional blockquote summary, and H2-delimited sections containing lists of links to Markdown resources.

**llms-full.txt** — An extended variant of llms.txt that contains the full content of all linked resources in a single file, rather than linking to them. Used by some sites as a convenience format for AI systems that want everything in one request.

**MCP (Model Context Protocol)** — A standard developed by Anthropic for connecting AI agents to external tools and data sources. An MCP server exposes structured tool definitions that AI agents can call at inference time. LlmsTxtKit.Mcp implements an MCP server that exposes llms.txt capabilities as tools.

**WAF (Web Application Firewall)** — Security infrastructure that sits between a website and the internet, inspecting incoming requests and blocking those that match threat heuristics. AI crawlers frequently trigger WAF blocks because they don't execute JavaScript, don't maintain cookies, originate from data center IP ranges, and use non-browser user agents.

---

> **Maintenance note:** Keep definitions concise but precise. If a term requires extended explanation, provide the short definition here and reference the relevant section of the paper or proposal for the full treatment.
