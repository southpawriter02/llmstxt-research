# Shared Bibliography

This file serves as the shared reference list for the paper, benchmark write-up, and blog posts. All citations across the initiative should reference this canonical list to ensure consistency.

---

## Standards and Specifications

- Howard, J. (2024). "The /llms.txt file." llmstxt.org. https://llmstxt.org/
- AnswerDotAI. (2024). llms-txt GitHub repository. https://github.com/AnswerDotAI/llms-txt
  - `llms_txt/miniparse.py` — Minimal standalone parser (canonical parsing behavior, no external dependencies)
  - `llms_txt/core.py` — Reference implementation (parsing, XML context generation via fastcore FT, parallel document fetching)
  - `nbs/llms-sample.txt` — Canonical example file from the specification
  - `nbs/domains.md` — Usage guidelines showing how different verticals (restaurants, etc.) could construct llms.txt files (NOT an adopter directory)
  - External adopter directories referenced in spec: [llmstxt.site](https://llmstxt.site/), [directory.llmstxt.cloud](https://directory.llmstxt.cloud/)
  - `nbs/ed.md` — Narrative walkthrough demonstrating intended editor/IDE integration pattern
  - `llms_txt/txt2html.py` — HTML renderer used for the llmstxt.org website
- Cloudflare. (2025). "Giving users choice with Cloudflare's new Content Signals Policy." https://blog.cloudflare.com/content-signals-policy/
- Creative Commons. (2025). "CC Signals: What We've Been Working On." https://creativecommons.org/2025/12/15/cc-signals-what-weve-been-working-on/

## Industry Analysis and Commentary

- Cloudflare. (2024). "Declare your AIndependence: block AI bots, scrapers and crawlers with a single click." Cloudflare Blog, July 3, 2024. https://blog.cloudflare.com/declaring-your-aindependence-block-ai-bots-scrapers-and-crawlers-with-a-single-click/
- Cloudflare. (2025). "Content Independence Day." Cloudflare Blog, July 1, 2025. _(Default blocking for new domains.)_
- Mintlify. (2025). "The Value of llms.txt: Hype or Real?" https://www.mintlify.com/blog/the-value-of-llms-txt-hype-or-real
- Yoast. (2025). "What AI Gets Wrong About Your Site & llms.txt." https://yoast.com/what-ai-gets-wrong-about-your-site-llms-txt/
- llms-txt.io. (2025). "Is llms.txt Dead? The Current State of Adoption in 2025." https://llms-txt.io/blog/is-llms-txt-dead
- Green, C. (2025). "A Million Websites in Search of llms.txt." https://www.chris-green.net/post/million-websites-in-search-of-llms-txt
- Rankability. (2025). "LLMS.txt Adoption Research Report 2025." https://www.rankability.com/data/llms-txt-adoption/
- Shelby, C. (2025). "No, llms.txt is not the 'new meta keywords'." Search Engine Land. https://searchengineland.com/no-llms-txt-is-not-the-new-meta-keywords-458199
- Search Engine Journal. (2025). "Google Says LLMs.txt Comparable to Keywords Meta Tag." https://www.searchenginejournal.com/google-says-llms-txt-comparable-to-keywords-meta-tag/544804/
- Search Engine Land. (2025). "Google says normal SEO works for ranking in AI Overviews and llms.txt won't be used." https://searchengineland.com/google-says-normal-seo-works-for-ranking-in-ai-overviews-and-llms-txt-wont-be-used-459422
- Martinez, R. (2025). "Are LLMs.txt Files Being Implemented Across the Web?" Archer Education. https://www.archeredu.com/hemj/are-llms-txt-files-being-implemented-across-the-web/
- Omnius. (2025). "Google Adds LLMs.txt to Docs After Publicly Dismissing It." https://www.omnius.so/industry-updates/google-adds-llms-txt-to-docs-after-publicly-dismissing-it _(URL no longer available; redirects to homepage. Article was never individually archived by Wayback Machine, Google Cache, or archive.today. Existence confirmed by Wayback Machine snapshot of the /industry-updates listing page from Dec 18, 2025; screenshot saved in `paper/data/omnius-wayback-listing-20251218.png`. Corroborating source only; primary sources for claim 4.3 are schwartz2025x and infante2025bsky.)_
- 365i. (2025). "Google tests llms.txt then removes it." https://www.365i.co.uk/blog/2025/12/09/google-llms-discover-ai-mode-2025/
- 365i. (2026). "Google Says Markdown for AI Is 'a Stupid Idea.' They're Half Right." https://www.365iwebdesign.co.uk/news/2026/02/08/google-markdown-ai-stupid-idea-discovery-files/

## Primary Sources (Social Media)

- Schwartz, B. (2025). X post: Google Search Central llms.txt discovery. December 3, 2025. https://x.com/rustybrick/status/1996192945486111193
- Martinez, R. (2025). X post: GPTBot 15-minute llms.txt crawling. https://x.com/RayMartinezSEO/status/1947357454292889874

## Technical Documentation

- W3Techs. (2026). "Usage statistics of Cloudflare." https://w3techs.com/technologies/details/cn-cloudflare
- Cloudflare. (2025). "Bot detection engines." Developer documentation. https://developers.cloudflare.com/bots/concepts/bot-detection-engines/
- Cloudflare. (2025). "AI Crawl Control." Developer documentation. https://developers.cloudflare.com/ai-crawl-control/
- Cloudflare. (2025). "AI Crawl Control with WAF." Developer documentation. https://developers.cloudflare.com/ai-crawl-control/configuration/ai-crawl-control-with-waf/

## Academic and Research

- Aggarwal, P., et al. (2024). "GEO: Generative Engine Optimization." Princeton University. arXiv:2311.09735.
- Chroma Research. (2025). "Context Rot." https://research.trychroma.com/context-rot
- Emergent Mind. (2025). "Context Collapse." https://www.emergentmind.com/topics/context-collapse

---

> **Maintenance note:** When adding a new reference, check whether it's already listed here before creating a duplicate. If a source is only used in one deliverable and is unlikely to be reused, it's fine to cite it inline in that deliverable rather than adding it here. This list is for frequently-cited or cross-deliverable references.
