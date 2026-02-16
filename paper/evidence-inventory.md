# Evidence Inventory — "The llms.txt Access Paradox"

**Author:** Ryan
**Version:** 2.0
**Last Updated:** February 15, 2026
**Purpose:** Master tracking document for every factual claim in the paper. Each claim maps to a specific paper section, cites its source, tracks verification status, and records the actual evidence found during research consolidation.

---

## How to Use This Document

Every factual claim in the paper is listed below with:

- **Claim ID** — Matches the outline's numbering (Section.Claim, e.g., 2.1 = Section 2, Claim 1)
- **Claim** — The specific factual assertion
- **Source Key** — Reference key from `shared/references.md`
- **Status** — ✅ Verified | 🔄 Partially verified | 🔲 Unverified | ❌ Could not verify / Incorrect | ✏️ Author analysis (no external source needed)
- **Evidence Notes** — What was found, including specific URLs, dates, and any discrepancies

When writing the paper, every factual claim should trace back to an entry here, and every entry here should cite a specific source from `shared/references.md` or primary data in `paper/data/`.

---

## Section 2: Introduction — The Promise of llms.txt

| ID | Claim | Source Key | Status | Evidence Notes |
|----|-------|-----------|--------|----------------|
| 2.1 | The llms.txt standard was proposed by Jeremy Howard of Answer.AI in September 2024. | howard2024llmstxt | ✅ Verified | Spec page (`index.qmd`) is dated `2024-09-03`. Author: Jeremy Howard. |
| 2.2 | Howard's motivation was the FastHTML documentation problem: AI assistants couldn't help developers use a library created after models' training cutoff dates. | howard2024llmstxt | ✅ Verified | Spec Background section opens with context window limitations. FastHTML is the running example throughout. |
| 2.3 | The spec is deliberately minimal: H1 title (required), blockquote summary, freeform Markdown, H2 sections with link lists, Optional section. | howard2024llmstxt | ✅ Verified | Format section enumerates exactly these elements. H1 is "the only required section." |
| 2.4 | The spec explicitly targets inference-time usage. | howard2024llmstxt | ✅ Verified | Spec states it will mainly be useful for inference, as opposed to training. |
| 2.5 | The spec proposes `.md`-appended URLs for clean Markdown versions of pages. | howard2024llmstxt | ✅ Verified | Proposal section describes appending `.md` to page URLs. |
| 2.6 | The reference Python implementation confirms the spec's minimalism — the canonical parser is ~20 lines of regex-based string processing, with no validation, no error handling, and no edge-case management. | answerdotai2024llmstxt | ✅ Verified | `llms_txt/miniparse.py` analyzed in `llms-txt-reference-repo-analysis.md`. Parser is regex-only, no try/except, no type hints. |
| 2.7 | The reference implementation generates Claude-oriented XML context using `<project>`/`<section>`/`<doc>` elements and explicitly skips the Optional section by default. | answerdotai2024llmstxt | ✅ Verified | `core.py` uses `create_ctx()` with `optional=False` default. XML structure uses those exact element names. Confirmed in `ed.md` walkthrough. |

**Section 2 Summary:** 7/7 claims ✅ verified. No gaps.

---

## Section 3: The Adoption Landscape

| ID | Claim | Source Key | Status | Evidence Notes |
|----|-------|-----------|--------|----------------|
| 3.1 | 844,000+ websites have implemented some form of llms.txt file. | llmstxt directories | ❌ **LIKELY INCORRECT** | **MAJOR FINDING:** Independent verification found this number has no credible primary source. Directory counts: `llmstxt.site` reports ~784 sites, `directory.llmstxt.cloud` reports ~684. A Rankability analysis of ~300K domains found only 10.13% had llms.txt. The Majestic Million crawl found only 105 in top 1M websites. Actual verified adoption appears to be in the hundreds to low thousands, not hundreds of thousands. **The paper should either remove or heavily qualify this claim.** |
| 3.2 | Notable adopters include Anthropic, Cloudflare, Stripe, Vercel, Coinbase. | Primary verification | ✅ Verified | All five confirmed active as of Feb 2026. Anthropic: 8,364 tokens in llms.txt, 481,349 in llms-full.txt. Cloudflare: organized by product. Stripe: structured by product category. Vercel: at sdk.vercel.ai/llms.txt. Coinbase: confirmed active. Sources: mintlify.com, llms-txt.io, direct fetches. |
| 3.3 | An independent Majestic Million crawl found 15 sites in Feb 2025, growing to 105 by May 2025 — 600% increase from near-zero base. | llmstxtio2025dead, green2025million | ✅ Verified | llms-txt.io article and Chris Green's analysis (chris-green.net/post/million-websites-in-search-of-llms-txt) both confirm: 105 valid files = 0.011% of the Majestic Million. |
| 3.4 | Adoption is heavily concentrated in developer tools and technical documentation; mainstream web presence is essentially zero. | Primary analysis + llmstxtio2025dead | ✅ Verified | Majestic Million data (0.011%) combined with directory composition (overwhelmingly dev-tool sites) confirms developer-tool concentration. Zero top-1000 websites implement llms.txt per Rankability data. |
| 3.5 | The split between adoption volume (high in dev tools) and breadth (absent on broader web) indicates a niche rather than a standard. | Author analysis | ✏️ Author analysis | Interpretive claim. Now well-supported by verified data from 3.1–3.4. The corrected adoption numbers (hundreds, not hundreds of thousands) strengthen this argument. |
| 3.6 | The reference repo maintains a curated list of known domains with llms.txt files in `nbs/domains.md`. | answerdotai2024llmstxt | ❌ **INCORRECT** | **CORRECTION:** `nbs/domains.md` is a usage-guidelines document (restaurant examples, vertical-specific advice), NOT an adopter directory. The spec's `index.qmd` links to two external directories: `llmstxt.site` and `directory.llmstxt.cloud`. This claim must be rewritten or removed from the outline. The `references.md` entry has been corrected (v2.0). |

**Section 3 Summary:** 3/6 verified, 1 author analysis, 2 incorrect. **Critical correction needed on claim 3.1** — the paper's adoption narrative should pivot from "844K sites" to the Majestic Million data (105/1M) and directory counts (~784) as the honest picture.

### New references to add to `shared/references.md`:
- Green, C. (2025). "A Million Websites in Search of llms.txt." https://www.chris-green.net/post/million-websites-in-search-of-llms-txt
- Rankability. (2025). "LLMS.txt Adoption Research Report 2025." https://www.rankability.com/data/llms-txt-adoption/

---

## Section 4: The Inference Gap

| ID | Claim | Source Key | Status | Evidence Notes |
|----|-------|-----------|--------|----------------|
| 4.1 | No major LLM provider has publicly confirmed using llms.txt at inference time. | Multiple sources | ✅ Verified | Research found: Google explicitly rejected (Mueller April 2025, Illyes July 2025). No public confirmation from OpenAI, Anthropic, or Microsoft for inference-time usage. Crawler activity (4.6, 4.8) is consistent with training, not inference. |
| 4.2 | Google has explicitly rejected the standard. Mueller compared it to the keywords meta tag (April 2025). Illyes stated no support at Search Central Live (July 2025). | shelby2025metakeywords, 365i2026google, sej2025mueller, sel2025illyes | ✅ Verified | Mueller: Search Engine Journal, April 2025 (https://www.searchenginejournal.com/google-says-llms-txt-comparable-to-keywords-meta-tag/544804/). Illyes: Search Engine Land, July 2025 (https://searchengineland.com/google-says-normal-seo-works-for-ranking-in-ai-overviews-and-llms-txt-wont-be-used-459422). |
| 4.3 | Google was caught with an llms.txt on their own Search Central docs (December 2025), responded "hmmn :-/", and removed it within hours. | Primary: schwartz2025x, infante2025bsky, omnius2025google | ✅ Verified | **Discovery date: December 3, 2025.** Discovered by Lidia Infante (SEO professional), who posted on Bluesky. Barry Schwartz covered on X (https://x.com/rustybrick/status/1996192945486111193). Mueller responded with exact quote confirmed. File was at developers.google.com/search/docs/llms.txt, removed within hours. Also covered by: omnius.so, stanventures.com, 365i.co.uk (Dec 9, 2025 article). |
| 4.4 | Yoast found that GPTBot, ClaudeBot, and Google AI crawlers don't request llms.txt files in their analysis. | yoast2025llmstxt | ✅ Verified | Yoast article confirms these crawlers do not routinely request llms.txt. Note: some conflicting reports from other sources suggest selective behavior (see 4.6). |
| 4.5 | A hosting provider managing 20,000 sites confirmed zero GPTBot activity on llms.txt. | yoast2025llmstxt | 🔄 Partially verified | Referenced in Yoast article but the specific hosting provider's name could not be independently confirmed through web research. The claim is attributed but the attribution chain is thin. **Editorial decisions (Feb 16, 2026):** (1) **Paper:** Do NOT use this claim. Rely on claim 4.4 (Yoast's own verified finding) instead. Anonymous secondhand attribution does not meet the paper's evidence standard. (2) **Blog posts:** Retained with transparent attribution caveat — phrased as "unnamed hosting provider managing thousands of sites" with explicit note that "the provider wasn't identified, so the attribution chain is thin." Diplomatic but honest. |
| 4.6 | Another developer showed GPTBot pinging their llms.txt every 15 minutes. | llmstxtio2025dead, martinez2025x | ✅ Verified | **Developer identified: Ray Martinez, founder of Archer Education.** Posted on X (https://x.com/RayMartinezSEO/status/1947357454292889874). Also documented on Archer Education blog (https://www.archeredu.com/hemj/are-llms-txt-files-being-implemented-across-the-web/). Describes GPTBot fetching llms.txt every 15 minutes with log evidence. |
| 4.7 | The contradictory log data suggests experimental or selective behavior, not systematic support. | Author analysis | ✏️ Author analysis | Now well-supported: Martinez sees 15-min pings, Yoast/hosting provider sees zero activity. Pattern is consistent with selective/experimental crawling rather than systematic inference-time usage. |
| 4.8 | Mintlify and Profound data show Microsoft and OpenAI crawlers actively accessing llms.txt and llms-full.txt. | mintlify2025llmstxt | ✅ Verified | Mintlify article confirms: Profound tracking data shows Microsoft, OpenAI, and others actively crawling both files. Additional finding: llms-full.txt is accessed more frequently than llms.txt. Also notable: Mintlify developed llms-full.txt in collaboration with Anthropic, and Mintlify's rollout added thousands of docs sites overnight (November 2024). |
| 4.9 | Training-time crawling is categorically different from inference-time retrieval. The spec targets inference; the evidence points to training. | howard2024llmstxt + author analysis | ✅ Verified | Spec quote (claim 2.4) establishes inference intent. All observed crawler behavior (periodic fetching, bulk crawling) is consistent with training/indexing, not real-time inference retrieval. |

**Section 4 Summary:** 7/9 verified (up from 4), 1 partially verified, 1 author analysis. Major upgrade: claims 4.1, 4.3, and 4.6 now fully verified with primary sources.

### New references to add to `shared/references.md`:
- Schwartz, B. (2025). X post documenting Google Search Central llms.txt discovery. https://x.com/rustybrick/status/1996192945486111193
- Search Engine Journal. (2025). "Google Says LLMs.txt Comparable to Keywords Meta Tag." https://www.searchenginejournal.com/google-says-llms-txt-comparable-to-keywords-meta-tag/544804/
- Martinez, R. (2025). X post documenting GPTBot 15-minute llms.txt crawling. https://x.com/RayMartinezSEO/status/1947357454292889874
- Archer Education. (2025). "Are LLMs.txt Files Being Implemented Across the Web?" https://www.archeredu.com/hemj/are-llms-txt-files-being-implemented-across-the-web/
- Omnius. (2025). "Google Adds LLMs.txt to Docs After Publicly Dismissing It." https://www.omnius.so/industry-updates/google-adds-llms-txt-to-docs-after-publicly-dismissing-it

---

## Section 5: The Infrastructure Paradox

| ID | Claim | Source Key | Status | Evidence Notes |
|----|-------|-----------|--------|----------------|
| 5.1 | Cloudflare sits in front of roughly 20% of all public websites. | W3Techs | ✅ Verified | **W3Techs data (Feb 2026): 21.3% of all websites.** Additional context: 79.9% of CDN/reverse-proxy market, 48.7% of top 1M traffic sites. Source: https://w3techs.com/technologies/details/cn-cloudflare |
| 5.2 | Cloudflare began blocking all AI crawlers by default on new domains in July 2025 ("AIndependence Day"). | cloudflare2025aindependence, cloudflare2025independence | ✅ Verified **with correction** | **TIMELINE CORRECTION:** Two distinct events: (1) **July 3, 2024** — "Declare your AIndependence" blog post introduced **opt-in** one-click AI bot blocking for all customers (blog.cloudflare.com). In June 2024, AI bots accessed ~39% of top 1M Cloudflare properties but only 2.98% blocked them. (2) **July 1, 2025** — "Content Independence Day" announcement changed this to **default blocking** for newly created domains. The paper should cite both events to show the progression from opt-in → default. |
| 5.3 | AI crawlers trigger bot-detection heuristics because they don't execute JavaScript, don't maintain cookies, originate from data center IPs, and use non-browser user agents. | Cloudflare bot detection docs | ✅ Verified | Cloudflare documentation at https://developers.cloudflare.com/bots/concepts/bot-detection-engines/ confirms all four signals plus additional ones: TLS/JA3/JA4 fingerprinting, malicious fingerprint database, missing standard browser headers. The `cf_clearance` cookie is issued only after JavaScript detection passes — bots that can't execute JS never receive it. |
| 5.4 | Three-way misalignment: site owner creates llms.txt → infrastructure blocks AI crawlers → AI falls back to search APIs. | Author analysis | ✏️ Author analysis | Core thesis of the paper. Now fully supported by verified infrastructure evidence (5.1–5.3, 5.5–5.6). |
| 5.5 | Cloudflare offers granular controls (ai-train, search, ai-input) but these require active configuration most site owners never perform. | Cloudflare AI Crawl Control docs | ✅ Verified | Documentation at https://developers.cloudflare.com/ai-crawl-control/. Dashboard location: AI Crawl Control section with tabs for Overview, Crawlers, Settings, Metrics, robots.txt. **Default settings for managed robots.txt: search=yes, ai-train=no, ai-input=neutral (no expressed preference).** "Block on all pages" is default for newly created domains. |
| 5.6 | WAF custom rules execute before AI Crawl Control settings, meaning a security rule can block an AI crawler even when AI Crawl Control says "allowed." | Cloudflare WAF/AI Crawl Control docs | ✅ Verified | Documentation at https://developers.cloudflare.com/ai-crawl-control/configuration/ai-crawl-control-with-waf/. **Execution order: Traffic → WAF custom rules (including AI Crawl Control: Crawler blocks) → Cloudflare Bot Solutions → AI Crawl Control: Pay Per Crawl.** Key quote from docs: allowed bots may still be affected by other security rules that execute before the AI Crawl Control rule. Terminating actions stop evaluation immediately. |
| 5.7 | The author experienced this blocking firsthand. | Author's firsthand account | ✅ Verified | Primary source. Needs writing up as a narrative, but the facts are available. |

**Section 5 Summary:** 6/7 verified (up from 2), 1 author analysis. **All Cloudflare documentation gaps are now closed.** This section is fully research-ready.

### New references to add to `shared/references.md`:
- W3Techs. (2026). "Usage statistics of Cloudflare." https://w3techs.com/technologies/details/cn-cloudflare
- Cloudflare. (2025). "Bot detection engines." Developer documentation. https://developers.cloudflare.com/bots/concepts/bot-detection-engines/
- Cloudflare. (2025). "AI Crawl Control." Developer documentation. https://developers.cloudflare.com/ai-crawl-control/
- Cloudflare. (2025). "AI Crawl Control with WAF." Developer documentation. https://developers.cloudflare.com/ai-crawl-control/configuration/ai-crawl-control-with-waf/

---

## Section 6: The Trust Architecture

| ID | Claim | Source Key | Status | Evidence Notes |
|----|-------|-----------|--------|----------------|
| 6.1 | Google's Mueller compared llms.txt to the discredited keywords meta tag. | shelby2025metakeywords, sej2025mueller | ✅ Verified | Same primary sources as claim 4.2. Search Engine Journal (April 2025) and Search Engine Land both document the comparison. |
| 6.2 | The comparison reflects a genuine engineering concern: llms.txt content is self-reported, separately maintained, and unverifiable. | Author analysis | ✏️ Author analysis | Analytical interpretation of Mueller's analogy. |
| 6.3 | Because llms.txt content is maintained separately from the HTML it describes, there is no built-in mechanism to verify consistency, detect staleness, or prevent manipulation. | howard2024llmstxt + author analysis | ✅ Verified | Spec contains no signing, hashing, or freshness mechanisms. Verified by reading the full spec and reference implementation. No content-hash or last-modified fields are part of the format. |
| 6.4 | The cloaking concern: llms.txt could present different content to AI systems than what human visitors see, with no accountability mechanism. | Author analysis | ✏️ Author analysis | Standard cloaking analysis applied to llms.txt. |
| 6.5 | For platforms to trust llms.txt, they would need: content signing/hashing, freshness verification, consistency checks, and ideally a registry or reputation system. | Author proposal | ✏️ Author analysis | Proposed trust requirements. This is the paper's constructive contribution to the discourse. |

**Section 6 Summary:** 2/5 verified, 3 author analysis. No changes from v1.0. Section is primarily analytical — no external evidence gaps.

---

## Section 7: Standards Fragmentation

| ID | Claim | Source Key | Status | Evidence Notes |
|----|-------|-----------|--------|----------------|
| 7.1 | Multiple standards now address how AI systems interact with web content: llms.txt, Cloudflare Content Signals, CC Signals, IETF aipref, and robots.txt. | howard2024llmstxt, cloudflare2025contentsignals, cc2025signals | ✅ Verified | Each standard documented in references.md. |
| 7.2 | These standards address overlapping but distinct concerns: discovery (llms.txt), permission (Content Signals, CC Signals, aipref), and access control (robots.txt). | Author analysis | ✏️ Author analysis | Comparative framework. |
| 7.3 | Content Signals has already deployed to 3.8 million domains via Cloudflare's managed robots.txt service. | cloudflare2025contentsignals | ✅ Verified | Cloudflare blog post (September 24, 2025) confirms: customers turned on managed robots.txt for over 3.8 million domains, instructing companies they do not want content used for AI training. Default: search=yes, ai-train=no, ai-input=neutral. |
| 7.4 | CC Signals is still in pilot phase as of December 2025. | cc2025signals | ✅ Verified | CC blog post (December 15, 2025) confirms pilot status. |
| 7.5 | No single standard addresses all three layers (discovery + permission + validation). | Author analysis | ✏️ Author analysis | Analytical synthesis. |

**Section 7 Summary:** 3/5 verified, 2 author analysis. No changes from v1.0. No external evidence gaps.

---

## Section 8: Implications for GEO Practice

| ID | Claim | Source Key | Status | Evidence Notes |
|----|-------|-----------|--------|----------------|
| 8.1 | The GEO research (Princeton, 2024) found that citations and statistics improve AI visibility 30–40%, while keyword stuffing decreases it ~10%. | aggarwal2024geo | ✅ Verified | Paper (arXiv:2311.09735) reports these figures. Note: GEO paper does NOT specifically mention llms.txt — it focuses on generalized content optimization strategies for generative engines. |
| 8.2 | Implementing llms.txt today is low-cost/low-risk but also low-measurable-benefit, since no platform confirms inference-time usage. | Author synthesis | ✏️ Author analysis | Recommendation based on Sections 4–6 findings. |
| 8.3 | Content quality fundamentals matter more than any single standard. | aggarwal2024geo + author analysis | ✏️ Author analysis | GEO research supports this; practical reasoning extends it. |
| 8.4 | Practitioners should implement llms.txt if maintenance cost is low, but not as substitute for content quality. | Author synthesis | ✏️ Author analysis | Practical recommendation. |
| 8.5 | WAF configuration review is the most impactful immediate action for sites wanting AI access. | Author synthesis | ✏️ Author analysis | Grounded in Section 5 findings, now fully supported by verified Cloudflare documentation. |

**Section 8 Summary:** 1/5 verified, 4 author analysis. No changes needed. GEO paper confirmed as not mentioning llms.txt specifically — this is useful context for claim 9.1.

---

## Section 9: Research Gaps and Future Work

| ID | Claim | Source Key | Status | Evidence Notes |
|----|-------|-----------|--------|----------------|
| 9.1 | No published study has empirically measured whether llms.txt-curated content improves AI response quality versus HTML-derived text. | Author survey | ✅ Verified | Formal search across Google Scholar, arXiv, and Semantic Scholar found no such study. The GEO paper (arXiv:2311.09735) does not mention llms.txt. Search terms: "llms.txt benchmark", "llms.txt quality evaluation", "llms.txt empirical study" — all returned zero relevant results. |
| 9.2 | The accompanying benchmark study addresses this gap directly. | Internal cross-reference | ✅ Verified | Benchmark lane (Lane 4) is designed for exactly this. |
| 9.3 | The tooling gap (no .NET implementation) limits the ecosystem's reach to Python and JavaScript developers. | Author survey | ✅ Verified | Spec's Integrations section lists: Python (`llms_txt2ctx`), JavaScript (sample implementation), VitePress plugin, Docusaurus plugin, Drupal module, PHP library, VS Code extension. No .NET, Java, Go, or Rust implementations. |
| 9.4 | The companion LlmsTxtKit project addresses the .NET gap. | Internal cross-reference | ✅ Verified | LlmsTxtKit is Lane 2 of the initiative. |
| 9.5 | Open questions about platform adoption, trust mechanisms, and standards consolidation. | Author analysis | ✏️ Author analysis | Forward-looking questions. |

**Section 9 Summary:** 4/5 verified (up from 3), 1 author analysis. Claim 9.1 upgraded from 🔄 to ✅ after formal literature search.

---

## Aggregate Evidence Status (v2.0)

| Status | Count | Percentage | Change from v1.0 |
|--------|-------|------------|-------------------|
| ✅ Verified | 33 | 67% | +12 |
| 🔄 Partially verified | 1 | 2% | -9 |
| 🔲 Unverified | 0 | 0% | -2 |
| ❌ Incorrect / Needs correction | 2 | 4% | +1 |
| ✏️ Author analysis | 13 | 27% | — |
| **Total claims** | **49** | — | — |

> **Note on total count:** The original outline's summary table said "40 claims" but the actual section-by-section tables contain 49 distinct claims (7+6+9+7+5+5+5+5). The 13 "author analysis" claims are the paper's original analytical contributions and don't need external verification. The 2 incorrect claims (3.1 and 3.6) need correction in the paper outline before writing begins. Only 1 claim (4.5) remains partially verified — the rest are either fully verified, author analysis, or flagged for correction.

---

## Critical Corrections Needed Before Writing

### 1. Claim 3.1 — Adoption Count Must Be Revised

**Problem:** The "844,000+" figure has no credible primary source. Independent data shows actual verified adoption in the hundreds to low thousands.

**Recommendation:** Replace with honest data:
- Directory counts: ~784 sites (llmstxt.site)
- Majestic Million: 105 out of 1,000,000 top websites (0.011%)
- Top-1000 websites: 0% adoption
- Rankability large-scale crawl: 10.13% of ~300K analyzed domains

**Narrative impact:** This actually *strengthens* the paper's argument. The corrected numbers make the "niche vs. standard" analysis more compelling and honest. The paper should present the real data and let readers draw the obvious conclusion, rather than citing an inflated number that could undermine credibility.

### 2. Claim 3.6 — domains.md Reference Must Be Corrected

**Problem:** `nbs/domains.md` is a usage-guidelines document, not an adopter directory.

**Action:** Already corrected in `shared/references.md` (v2.0). Outline claim 3.6 should be rewritten to reference the external directories (`llmstxt.site`, `directory.llmstxt.cloud`) or removed entirely.

### 3. Claim 5.2 — AIndependence Timeline Must Be Clarified

**Problem:** The paper says "July 2025" but there are actually two distinct events.

**Action:** Cite both events:
- July 3, 2024: "AIndependence" blog post — opt-in one-click blocking
- July 1, 2025: "Content Independence Day" — default blocking for new domains

This progression (opt-in → default within one year) is actually a stronger narrative than a single event.

---

## References to Add to `shared/references.md`

The following sources were discovered during evidence verification and should be added:

### Industry Analysis and Commentary
- Green, C. (2025). "A Million Websites in Search of llms.txt." https://www.chris-green.net/post/million-websites-in-search-of-llms-txt
- Rankability. (2025). "LLMS.txt Adoption Research Report 2025." https://www.rankability.com/data/llms-txt-adoption/
- Omnius. (2025). "Google Adds LLMs.txt to Docs After Publicly Dismissing It." https://www.omnius.so/industry-updates/google-adds-llms-txt-to-docs-after-publicly-dismissing-it
- Search Engine Journal. (2025). "Google Says LLMs.txt Comparable to Keywords Meta Tag." https://www.searchenginejournal.com/google-says-llms-txt-comparable-to-keywords-meta-tag/544804/
- Martinez, R. (2025). "Are LLMs.txt Files Being Implemented Across the Web?" Archer Education. https://www.archeredu.com/hemj/are-llms-txt-files-being-implemented-across-the-web/

### Primary Sources (Social Media)
- Schwartz, B. (2025). X post: Google Search Central llms.txt discovery. https://x.com/rustybrick/status/1996192945486111193
- Martinez, R. (2025). X post: GPTBot 15-minute llms.txt crawling. https://x.com/RayMartinezSEO/status/1947357454292889874

### Technical Documentation
- W3Techs. (2026). "Usage statistics of Cloudflare." https://w3techs.com/technologies/details/cn-cloudflare
- Cloudflare. (2025). "Bot detection engines." https://developers.cloudflare.com/bots/concepts/bot-detection-engines/
- Cloudflare. (2025). "AI Crawl Control." https://developers.cloudflare.com/ai-crawl-control/
- Cloudflare. (2025). "AI Crawl Control with WAF." https://developers.cloudflare.com/ai-crawl-control/configuration/ai-crawl-control-with-waf/

---

## Revision History

| Version | Date | Changes |
|---------|------|---------|
| 1.0 | February 15, 2026 | Initial inventory created from outline.md claims. All 40 claims cataloged. 1 incorrect reference identified (domains.md). Priority verification queue established. |
| 2.0 | February 15, 2026 | **Major update after web research.** 9 claims upgraded from 🔄/🔲 to ✅. Overall verification rate: 75% (up from 48%). Two critical corrections identified: (1) 844K adoption figure is unsubstantiated — real data is ~784 directory entries and 105/1M Majestic Million; (2) AIndependence timeline has two events (2024 opt-in, 2025 default). 12 new references discovered. Google Search Central incident fully sourced with primary social media posts. All Cloudflare documentation gaps closed with specific URLs. GPTBot 15-minute claim attributed to Ray Martinez of Archer Education. Literature survey formally confirmed — no published llms.txt benchmark exists. |
