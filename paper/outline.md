# "The llms.txt Access Paradox" — Detailed Outline

**Author:** Ryan
**Version:** 1.0
**Last Updated:** February 2026
**Status:** Draft — ready for first-draft writing

---

## How to Use This Document

This outline defines the paper's section-by-section structure, the specific claims each section makes, the evidence required to support each claim, and the current status of each piece. The "Evidence Status" column tracks whether the data, source, or analysis needed for a claim has been gathered (✅), is partially available (🔄), or still needs to be researched (🔲).

When writing the first draft, work through each section in order, writing the prose that turns these structured claims into a readable narrative. Every factual claim should be traceable to a specific entry in this outline, and every entry should cite a specific source from `shared/references.md` or link to raw data in `paper/data/`.

**Target length:** 6,000–10,000 words
**Target audience:** GEO/SEO practitioners, AI infrastructure engineers, technical documentation professionals

---

## Section 1: Abstract

**Target length:** ~200 words
**Status:** 🔲 Not started

The abstract should summarize the paper's four findings without jargon:

1. The llms.txt standard was designed for inference-time usage, but no major platform confirms using it at inference time.
2. The web's security infrastructure actively prevents the standard from working, even when site owners want AI access.
3. The standard lacks trust and validation mechanisms, which is why platforms have been reluctant to adopt it.
4. Multiple competing standards fragment the landscape without any single solution addressing all three problems (discovery, permission, validation).

The abstract closes by noting that these findings are supported by server log evidence, infrastructure analysis, and policy documentation, and that the accompanying benchmark study provides the first empirical measurement of whether llms.txt-curated content actually improves AI response quality.

---

## Section 2: Introduction — The Promise of llms.txt

**Target length:** ~600–800 words
**Status:** 🔲 Not started

### Claims and Evidence

| # | Claim | Evidence Required | Source | Evidence Status |
|---|---|---|---|---|
| 2.1 | The llms.txt standard was proposed by Jeremy Howard of Answer.AI in September 2024. | Direct citation of spec and author. | howard2024llmstxt | ✅ Available |
| 2.2 | Howard's motivation was the FastHTML documentation problem: AI assistants couldn't help developers use a library created after models' training cutoff dates. | Howard's original blog post and/or spec preamble. | howard2024llmstxt | ✅ Available |
| 2.3 | The spec is deliberately minimal: H1 title (required), blockquote summary, freeform Markdown, H2 sections with link lists, Optional section. | Direct spec description. | howard2024llmstxt | ✅ Available |
| 2.4 | The spec explicitly targets inference-time usage ("our expectation is that llms.txt will mainly be useful for inference"). | Direct quote from spec. | howard2024llmstxt | ✅ Available |
| 2.5 | The spec proposes `.md`-appended URLs for clean Markdown versions of pages. | Spec description. | howard2024llmstxt | ✅ Available |
| 2.6 | The reference Python implementation confirms the spec's minimalism — the canonical parser is ~20 lines of regex-based string processing, with no validation, no error handling, and no edge-case management. | Source code analysis of `miniparse.py` in `AnswerDotAI/llms-txt`. | answerdotai2024llmstxt | ✅ Available |
| 2.7 | The reference implementation generates Claude-oriented XML context using `<project>`/`<section>`/`<doc>` elements and explicitly skips the Optional section by default. | Source code analysis of `core.py` and the `ed` walkthrough (`nbs/ed.md`). | answerdotai2024llmstxt | ✅ Available |

### Narrative Structure

Open with the practical problem Howard faced: a brand-new Python framework with no AI assistant coverage because it was created after model training cutoffs. This is relatable — many developers have experienced the frustration of AI tools being useless for new libraries. Present the llms.txt spec as an elegant, minimal solution to a real problem. Use a direct quote from the spec to establish that inference-time usage was the explicit design goal. End by noting that this design intent is the lens through which the rest of the paper evaluates the standard.

---

## Section 3: The Adoption Landscape

**Target length:** ~800–1,000 words
**Status:** 🔲 Not started

### Claims and Evidence

| # | Claim | Evidence Required | Source | Evidence Status |
|---|---|---|---|---|
| 3.1 | Community directories list hundreds of llms.txt implementations (~784 on llmstxt.site, ~684 on directory.llmstxt.cloud), while a Rankability crawl of ~300K domains found 10.13% had llms.txt files. The widely cited "844,000+" figure has no verifiable primary source. | Directory counts, Rankability crawl data, Majestic Million analysis. | llmstxt directories, rankability2025adoption, green2025million | ✅ Verified — see evidence-inventory.md §3.1 |
| 3.2 | Notable adopters include Anthropic, Cloudflare, Stripe, Vercel, Coinbase. | Direct verification of each site's /llms.txt. | Primary — fetch and verify | ✅ Verified — all five confirmed active Feb 2026 |
| 3.3 | An independent Majestic Million crawl found 15 sites in Feb 2025, growing to 105 by May 2025 — 600% increase from near-zero base (0.011% of top 1M). | Crawl data citation. | llmstxtio2025dead, green2025million | ✅ Available |
| 3.4 | Adoption is heavily concentrated in developer tools and technical documentation; mainstream web presence is essentially zero. Top-1,000 websites show 0% adoption. | Sector distribution from directory data + Rankability. | rankability2025adoption, directory analysis | ✅ Verified |
| 3.5 | The split between adoption volume (high in dev tools) and breadth (absent on broader web) indicates a niche rather than a standard. | Analytical interpretation of 3.1–3.4. | Author analysis | ✏️ Author analysis — now well-supported by corrected data |
| 3.6 | Two community directories (llmstxt.site, directory.llmstxt.cloud) provide the most comprehensive adoption tracking. The reference repo's `nbs/domains.md` is a usage-guidelines document showing how different verticals could construct llms.txt files, not an adopter directory. | Directory inspection + repo file analysis. | answerdotai2024llmstxt, llmstxt directories | ✅ Verified — corrected from v1.0 (was mischaracterized) |

### Narrative Structure

Present the numbers honestly — they tell a split story. Community directories list hundreds of sites, and a large-scale crawl found ~10% adoption among domains surveyed. But that headline number is misleading: when cross-referenced against the Majestic Million (only 105 out of 1,000,000 top websites, or 0.011%), and noting zero adoption among the top 1,000 sites, a much more nuanced picture emerges. Adoption is real but overwhelmingly concentrated in developer documentation — a niche, not a standard. The widely cited "844,000+" figure has no verifiable source and should be treated skeptically. Use the Majestic Million and directory data as the honest foundation.

### Data Artifacts

- `paper/data/adoption-stats.csv` — compiled adoption counts over time with sources.
- `paper/data/adoption-analysis.ipynb` — (optional) notebook documenting how aggregate numbers were compiled.

---

## Section 4: The Inference Gap

**Target length:** ~1,200–1,500 words
**Status:** 🔲 Not started

This is the paper's first major finding. It establishes that the standard is not being used for its stated purpose.

### Claims and Evidence

| # | Claim | Evidence Required | Source | Evidence Status |
|---|---|---|---|---|
| 4.1 | No major LLM provider has publicly confirmed using llms.txt at inference time. | Survey of public statements from Google, OpenAI, Anthropic, Microsoft. | Multiple — see below | 🔄 Partially gathered |
| 4.2 | Google has explicitly rejected the standard. Mueller compared it to the keywords meta tag (April 2025). Illyes stated no support at Search Central Live (July 2025). | Direct citations of Mueller and Illyes statements. | shelby2025metakeywords, 365i2026google | ✅ Available |
| 4.3 | Google was caught with an llms.txt on their own Search Central docs (December 2025), responded "hmmn :-/", and removed it within hours. | Direct citation of the incident. | Primary — find the original Twitter thread / announcement | 🔄 Need primary source |
| 4.4 | Yoast found that GPTBot, ClaudeBot, and Google AI crawlers don't request llms.txt files in their analysis. | Yoast article citation. | yoast2025llmstxt | ✅ Available |
| 4.5 | A hosting provider managing 20,000 sites confirmed zero GPTBot activity on llms.txt. | Citation from Yoast or related analysis. | yoast2025llmstxt | 🔄 Verify specific claim |
| 4.6 | Another developer showed GPTBot pinging their llms.txt every 15 minutes. | Citation from llms-txt.io or independent report. | llmstxtio2025dead | 🔄 Verify specific claim |
| 4.7 | The contradictory log data suggests experimental or selective behavior, not systematic support. | Analytical interpretation. | Author analysis | 🔲 Needs writing |
| 4.8 | Mintlify and Profound data show Microsoft and OpenAI crawlers actively accessing llms.txt and llms-full.txt. | Mintlify article citation. | mintlify2025llmstxt | ✅ Available |
| 4.9 | Training-time crawling is categorically different from inference-time retrieval. The spec targets inference; the evidence points to training. | Analytical distinction, citing spec text. | howard2024llmstxt, author analysis | ✅ Available |

### Narrative Structure

Build the case incrementally. Start with Google's explicit rejection (most authoritative negative signal). Present the server log evidence — deliberately showing both sides (some see crawling, most don't). The key move is the training-vs-inference distinction: even sites that *do* see AI crawler activity on llms.txt cannot distinguish whether that activity serves training data collection or real-time retrieval. The spec was designed for inference. The available evidence is more consistent with training. This distinction matters because the *value proposition* of llms.txt depends on inference-time usage — if it's only consumed for training, site owners get no measurable benefit at the moment their users need help.

---

## Section 5: The Infrastructure Paradox

**Target length:** ~1,500–2,000 words
**Status:** 🔲 Not started

This is the paper's most original contribution. It documents a problem that nobody else has analyzed in detail.

### Claims and Evidence

| # | Claim | Evidence Required | Source | Evidence Status |
|---|---|---|---|---|
| 5.1 | Cloudflare sits in front of roughly 20% of all public websites. | Cloudflare market share data. | Cloudflare public disclosures / W3Techs data | 🔄 Number is widely cited; verify current |
| 5.2 | Cloudflare began blocking all AI crawlers by default on new domains in July 2025 ("AIndependence Day"). | Cloudflare blog post citation. | cloudflare2025aindependence | ✅ Available |
| 5.3 | AI crawlers trigger bot-detection heuristics because they don't execute JavaScript, don't maintain cookies, originate from data center IPs, and use non-browser user agents. | Technical description of WAF heuristics. | Cloudflare documentation + author experience | 🔄 Needs documentation |
| 5.4 | The result is a three-way misalignment: site owner creates llms.txt → infrastructure blocks AI crawlers → AI falls back to search APIs. | Analytical synthesis of 5.1–5.3. | Author analysis | 🔲 Needs writing |
| 5.5 | Cloudflare offers granular controls (ai-train, search, ai-input) but these require active configuration most site owners never perform. | Cloudflare documentation on AI Crawl Control. | Cloudflare docs | 🔄 Needs documentation |
| 5.6 | WAF custom rules execute before AI Crawl Control settings, meaning a security rule can block an AI crawler even when AI Crawl Control says "allowed." | Cloudflare execution order documentation. | Cloudflare docs + author experience | 🔄 Needs documentation |
| 5.7 | The author experienced this blocking firsthand. [Specific account of what happened, what configurations were tried, what failed.] | Primary source — the author's own experience. | Author's firsthand account | ✅ Available (needs writing) |

### Narrative Structure

Start with the scale of the problem (Cloudflare's market share). Explain how WAF heuristics work at a technical level — what signals trigger them and why AI crawlers inherently match those signals. Introduce the three-way misalignment as the core paradox: everyone is doing the right thing (site owner serves llms.txt, Cloudflare protects against bots, AI system follows the spec) and the system still doesn't work. Then go granular: walk through Cloudflare's control panel, explain the execution order problem, and ground it in the author's firsthand experience. The firsthand account provides primary-source credibility that distinguishes this analysis from generic commentary.

### Data Artifacts

- `paper/data/config-examples/` — Screenshots or configuration snippets showing Cloudflare settings.
- `paper/data/server-log-samples/` — Anonymized log excerpts showing blocked requests.

---

## Section 6: The Trust Architecture

**Target length:** ~1,000–1,200 words
**Status:** 🔲 Not started

### Claims and Evidence

| # | Claim | Evidence Required | Source | Evidence Status |
|---|---|---|---|---|
| 6.1 | Google's Mueller compared llms.txt to the discredited keywords meta tag. | Direct citation. | shelby2025metakeywords | ✅ Available |
| 6.2 | The comparison reflects a genuine engineering concern: llms.txt content is self-reported, separately maintained, and unverifiable. | Analytical argument connecting the analogy to the underlying issue. | Author analysis | 🔲 Needs writing |
| 6.3 | Because llms.txt content is maintained separately from the HTML it describes, there is no built-in mechanism to verify consistency, detect staleness, or prevent manipulation. | Technical analysis of the spec's design. | howard2024llmstxt + author analysis | ✅ Available |
| 6.4 | The cloaking concern: llms.txt could present different content to AI systems than what human visitors see, with no accountability mechanism. | Standard cloaking analysis applied to llms.txt context. | Author analysis | 🔲 Needs writing |
| 6.5 | For platforms to trust llms.txt, they would need: content signing/hashing, freshness verification, consistency checks between HTML and Markdown, and ideally a registry or reputation system. | Proposed trust requirements based on analysis. | Author proposal | 🔲 Needs writing |

### Narrative Structure

Start with the Mueller quote — it's provocative and widely discussed. But rather than dismissing it (as many commentators have), take it seriously as an engineering observation. The keywords meta tag failed because it was self-reported, unmeasurable, and gameable. llms.txt has the same structural vulnerabilities. Enumerate what's missing: no hashing, no signing, no freshness guarantees, no consistency verification. Then propose what a trust architecture would need to look like — not as a spec proposal, but as an analysis of the gap between where the standard is and where it would need to be for platform adoption.

---

## Section 7: Standards Fragmentation

**Target length:** ~1,000–1,200 words
**Status:** 🔲 Not started

### Claims and Evidence

| # | Claim | Evidence Required | Source | Evidence Status |
|---|---|---|---|---|
| 7.1 | Multiple standards now address how AI systems interact with web content: llms.txt, Cloudflare Content Signals, CC Signals, IETF aipref, and robots.txt. | Direct citation of each standard. | howard2024llmstxt, cloudflare2025contentsignals, cc2025signals | ✅ Available |
| 7.2 | These standards address overlapping but distinct concerns: discovery (llms.txt), permission (Content Signals, CC Signals, aipref), and access control (robots.txt). | Comparative analysis. | Author analysis | 🔲 Needs writing |
| 7.3 | Content Signals has already deployed to 3.8 million domains via Cloudflare's managed robots.txt service. | Cloudflare blog citation. | cloudflare2025contentsignals | ✅ Available |
| 7.4 | CC Signals is still in pilot phase as of December 2025. | CC blog citation. | cc2025signals | ✅ Available |
| 7.5 | No single standard addresses all three layers (discovery + permission + validation). The ecosystem has two of the three at best, and no standard has both widespread adoption and platform endorsement. | Analytical synthesis. | Author analysis | 🔲 Needs writing |

### Narrative Structure

Use a comparison table as the centerpiece of this section. For each standard, list: what layer it addresses (discovery, permission, access control), who maintains it, deployment scale, platform endorsement status, and mechanism type. The analysis shows that the standards are more complementary than competing — robots.txt handles access, Content Signals handle permission, llms.txt handles discovery — but that this complementarity is accidental rather than designed, and that the critical gap (validation/trust) isn't addressed by any of them.

### Data Artifacts

- Comparison table (rendered in paper, sourced from analysis).

---

## Section 8: Implications for GEO Practice

**Target length:** ~800–1,000 words
**Status:** 🔲 Not started

### Claims and Evidence

| # | Claim | Evidence Required | Source | Evidence Status |
|---|---|---|---|---|
| 8.1 | The GEO research (Princeton, 2024) found that citations and statistics improve AI visibility 30–40%, while keyword stuffing decreases it ~10%. | GEO paper citation. | aggarwal2024geo | ✅ Available |
| 8.2 | Given the findings above, implementing llms.txt today is low-cost/low-risk but also low-measurable-benefit, since no platform confirms inference-time usage. | Evidence-based recommendation synthesizing Sections 4–6. | Author synthesis | 🔲 Needs writing |
| 8.3 | Content quality fundamentals (clear structure, authoritative sourcing, factual density) matter more than any single standard, because they improve outcomes regardless of how AI retrieves the content. | GEO research + practical reasoning. | aggarwal2024geo + author analysis | 🔲 Needs writing |
| 8.4 | Practitioners should implement llms.txt if maintenance cost is low, but should not treat it as a substitute for content quality fundamentals. | Practical recommendation. | Author synthesis | 🔲 Needs writing |
| 8.5 | WAF configuration review is the most impactful immediate action for sites that want AI access. The Infrastructure Paradox (Section 5) affects sites regardless of whether they have an llms.txt file. | Practical recommendation grounded in Section 5. | Author synthesis | 🔲 Needs writing |

### Narrative Structure

This section translates the findings into actionable advice. Resist the temptation to be prescriptive — the evidence supports nuanced recommendations, not "implement llms.txt" or "don't bother." The key insight is that the most impactful action isn't adding llms.txt (which has uncertain benefit) but reviewing WAF configuration (which has concrete, immediate impact on whether *any* AI system can access *any* content on the site).

---

## Section 9: Research Gaps and Future Work

**Target length:** ~500–700 words
**Status:** 🔲 Not started

### Claims and Evidence

| # | Claim | Evidence Required | Source | Evidence Status |
|---|---|---|---|---|
| 9.1 | No published study has empirically measured whether llms.txt-curated content improves AI response quality versus HTML-derived text. | Literature survey confirming absence. | Author survey | 🔄 Informal survey done; needs formal confirmation |
| 9.2 | The accompanying benchmark study (companion project) addresses this gap directly. | Cross-reference to benchmark project. | Internal cross-reference | ✅ Available |
| 9.3 | The tooling gap (no .NET implementation) limits the ecosystem's reach to Python and JavaScript developers. | Ecosystem survey. | Author survey (Blog Post 3 content) | ✅ Available |
| 9.4 | The companion LlmsTxtKit project addresses the .NET gap. | Cross-reference to LlmsTxtKit project. | Internal cross-reference | ✅ Available |
| 9.5 | Open questions: Will any major platform adopt inference-time llms.txt usage? Can trust mechanisms be added without breaking the spec's minimalist design? Will the standards landscape consolidate or fragment further? | Identification of unanswered questions. | Author analysis | 🔲 Needs writing |

### Narrative Structure

Frame the gaps honestly — these are the things the paper doesn't answer, and deliberately pointing them out strengthens the paper's credibility. The benchmark study and LlmsTxtKit are introduced as companion projects that address specific gaps, not as products being marketed. The open questions section should read as genuine questions that interest the author, not rhetorical setup.

---

## Section 10: References

**Status:** 🔄 Partially compiled

Full citation list, sourced from `shared/references.md` and `shared/references.bib`. Format consistently (preferably a standard academic citation style, adapted for web-primary sources).

---

## Overall Evidence Status Summary

| Status | Count | Percentage |
|---|---|---|
| ✅ Verified | 33 | 67% |
| 🔄 Partially verified | 1 | 2% |
| ❌ Corrected | 2 | 4% |
| ✏️ Author analysis | 13 | 27% |
| **Total claims** | **49** | |

> **Note:** The original v1.0 summary counted 40 claims; the actual section-by-section total is 49 (7+6+9+7+5+5+5+5). See `paper/evidence-inventory.md` for the full claim-by-claim verification record with source URLs, dates, and notes.

The paper is writing-ready. All externally-sourceable claims are verified except one (4.5 — hosting provider attribution, partially verified). The 13 author-analysis claims are the paper's original analytical contributions. Two claims (3.1 adoption count, 3.6 domains.md reference) were corrected during evidence consolidation — the corrections strengthen the paper's credibility by presenting honest data.

---

## Revision History

| Version | Date | Changes |
|---|---|---|
| 1.0 | February 2026 | Initial outline with full evidence tracking |
| 1.1 | February 15, 2026 | Claims 3.1 and 3.6 corrected per evidence-inventory.md findings. 844K adoption figure replaced with verified directory/crawl data. domains.md reference corrected. Narrative structure updated. Evidence summary updated to reflect 49 claims, 67% verified. |
