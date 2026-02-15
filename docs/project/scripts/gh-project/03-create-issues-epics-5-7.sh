#!/usr/bin/env bash
# ==============================================================================
# 03-create-issues-epics-5-7.sh
# Create GitHub issues for Epics 5-7 (Blog Series, Blog Dogfooding, Infrastructure)
#
# v2.0 UPDATES:
#   - New Lane naming: [L{lane}-E{epic}] {Story Name}
#   - Lane 5 = Blog & Content (Epics 5, 6)
#   - Lane 6 = Cross-Cutting Infrastructure (Epic 7)
#   - All stories include lane labels
#   - Blog posts include new task 5.x.4: Apply GEO best practices
#   - Infrastructure story 7.5 adds ongoing tasks 7.5.4 and 7.5.5
# ==============================================================================

set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
source "${SCRIPT_DIR}/_helpers.sh"

# ==============================================================================
# EPIC 5: BLOG SERIES — 8-Post Publication Pipeline
# ==============================================================================

echo ""
echo "╔══════════════════════════════════════════════════════════════════════════╗"
echo "║ EPIC 5: BLOG SERIES — 8-Post Publication Pipeline                       ║"
echo "║ Repository: llmstxt-research                                             ║"
echo "║ Lane 5 (Blog & Content) | 8 stories | 49 points total                    ║"
echo "╚══════════════════════════════════════════════════════════════════════════╝"
echo ""

# Epic 5 issue
create_issue "llmstxt-research" "[EPIC] Blog Series — 8-Post Publication Pipeline" "$(cat <<'EOF' | sed 's/^    //'
    # Epic 5: Blog Series — 8-Post Publication Pipeline

**Scope:** Create and publish 8-post blog series spanning research findings, technical deep dives, and synthesis articles.

**Strategy:**
- Biweekly publication cadence
- Mix of personal narrative, research summaries, technical tutorials, and practitioner guides
- Sequential posts with upstream dependencies on other lanes (research, toolkit, validator)
- Posts range from 2,000–4,500 words
- SEO and GEO-optimized for search engines and generative AI indexing

**Success Criteria:**
- All 8 posts written, reviewed, and published on Docusaurus blog
- 2,000+ combined impressions across platforms within 8 weeks of publication
- At least 2 community discussions or retweets per post on average
- GEO best practices applied to all posts (structured data, definitive statements, citations)

**Timeline:** Weeks 1–18 | **Points:** 49
EOF
)" "type:epic,domain:blog,lane:blog"

# Story 5.1: Blog Post 1: My Own Firewall Said No
create_issue "llmstxt-research" "[L5-E5] Blog Post 1: My Own Firewall Said No" "$(cat <<'EOF' | sed 's/^    //'
    ## Story 5.1: My Own Firewall Said No

**Epic:** Blog Series | **Lane:** Lane 5 (Blog & Content) | **Lane Phase:** Execution | **Target Weeks:** 1–2 | **Points:** 5
**Dependencies:** None

### Description
Personal narrative + technical deep dive. Sets the voice and tone for the entire blog series. Opens with a human story (corporate firewall blocking research), then pivots to technical implications and research motivation. 2,000–2,500 words.

### Acceptance Criteria
- [ ] Post written, self-reviewed, and technically accurate
- [ ] Title, meta description, and H2 headers follow SEO guidelines
- [ ] Structured data (Article schema) included
- [ ] Published on Docusaurus blog
- [ ] Shared across platforms (LinkedIn, Twitter, Reddit)

### Tasks
- [ ] **5.1.1** Outline and research (1 pt) — Craft narrative arc. Research technical context (LLM access, enterprise policies).
- [ ] **5.1.2** Write first draft (1 pt) — 2,000–2,500 words. Personal story + technical transition.
- [ ] **5.1.3** Self-review and revision (1 pt) — Check clarity, tone, accuracy. Revise for flow.
- [ ] **5.1.4** Apply GEO best practices (1 pt) — Add structured data, definitive opening statements, internal links, FAQ schema where appropriate.
- [ ] **5.1.5** Adapt for Docusaurus and publish (1 pt) — Format frontmatter, images, code blocks. Test rendering.
- [ ] **5.1.6** Share on platforms (0 pts) — Post on LinkedIn, Twitter, Reddit, HN.
EOF
)" "type:story,domain:blog,lane:blog,priority:high"

# Story 5.2: Blog Post 2: What the Data Shows
create_issue "llmstxt-research" "[L5-E5] Blog Post 2: What the Data Shows" "$(cat <<'EOF' | sed 's/^    //'
    ## Story 5.2: What the Data Shows

**Epic:** Blog Series | **Lane:** Lane 5 (Blog & Content) | **Lane Phase:** Execution | **Target Weeks:** 4–5 | **Points:** 5
**Dependencies:** Lane 1, Story 1.3 (Research complete)

### Description
Research summary distilling key findings from the published paper into accessible language. Bridges academic rigor and practitioner appeal. 3,000–4,000 words. Condenses paper results, introduces data visualizations, and frames implications for LLM developers.

### Acceptance Criteria
- [ ] Post accurately reflects paper findings
- [ ] Data visualizations (charts, tables) included and properly captioned
- [ ] Accessible to non-academic audience
- [ ] Structured data and definitive statements for GEO
- [ ] Published and social-shared

### Tasks
- [ ] **5.2.1** Outline and research (1 pt) — Extract key findings. Plan visualization strategy.
- [ ] **5.2.2** Write first draft (1.5 pts) — 3,000–4,000 words. Data interpretation + implications.
- [ ] **5.2.3** Self-review and revision (1 pt) — Check accuracy against paper. Revise for clarity.
- [ ] **5.2.4** Apply GEO best practices (0.5 pts) — Add schema, headers, citations to paper.
- [ ] **5.2.5** Adapt for Docusaurus and publish (1 pt) — Render visualizations. Test links.
- [ ] **5.2.6** Share on platforms (0 pts) — Social distribution.
EOF
)" "type:story,domain:blog,lane:blog,priority:high"

# Story 5.3: Blog Post 3: Zero .NET Tools
create_issue "llmstxt-research" "[L5-E5] Blog Post 3: Zero .NET Tools" "$(cat <<'EOF' | sed 's/^    //'
    ## Story 5.3: Zero .NET Tools

**Epic:** Blog Series | **Lane:** Lane 5 (Blog & Content) | **Lane Phase:** Execution | **Target Weeks:** 6–7 | **Points:** 5
**Dependencies:** Lane 2, Story 3.1 (LlmsTxtKit announced)

### Description
Project announcement + ecosystem survey. Announces the LlmsTxtKit open-source release and reviews existing .NET tooling in the llms.txt space. 2,500–3,000 words. Positions LlmsTxtKit as addressing a gap in the ecosystem.

### Acceptance Criteria
- [ ] LlmsTxtKit features and architecture clearly described
- [ ] Competitor/peer analysis included
- [ ] Links to repo and getting-started guide
- [ ] GEO optimized for toolkit discovery
- [ ] Published and promoted

### Tasks
- [ ] **5.3.1** Outline and research (1 pt) — Document LlmsTxtKit architecture. Survey .NET landscape.
- [ ] **5.3.2** Write first draft (1.5 pts) — 2,500–3,000 words. Announcement + ecosystem framing.
- [ ] **5.3.3** Self-review and revision (0.5 pts) — Verify feature claims. Check links.
- [ ] **5.3.4** Apply GEO best practices (0.5 pts) — Add schema, definitive claims, code examples.
- [ ] **5.3.5** Adapt for Docusaurus and publish (1 pt) — Embed GitHub card or link. Code blocks.
- [ ] **5.3.6** Share on platforms (0 pts) — Tech communities (Dev.to, Hacker News, .NET forums).
EOF
)" "type:story,domain:blog,lane:blog,priority:high"

# Story 5.4: Blog Post 4: Tech Writer's GEO Guide
create_issue "llmstxt-research" "[L5-E5] Blog Post 4: Tech Writer's GEO Guide" "$(cat <<'EOF' | sed 's/^    //'
    ## Story 5.4: Tech Writer's GEO Guide

**Epic:** Blog Series | **Lane:** Lane 5 (Blog & Content) | **Lane Phase:** Execution | **Target Weeks:** 8–9 | **Points:** 8
**Dependencies:** None (original synthesis)

### Description
Practitioner guide to Generative Engine Optimization (GEO). Full original research and synthesis work. Draws on Princeton GEO study and applies findings to technical writing. 3,000–3,500 words. Becomes a reference resource for the community.

### Acceptance Criteria
- [ ] Comprehensive GEO framework presented
- [ ] Actionable techniques with examples
- [ ] Cites Princeton study and other research
- [ ] Case studies or before/after examples
- [ ] Positions as definitive guide (GEO-optimized itself)

### Tasks
- [ ] **5.4.1** Outline and research (2 pts) — Deep-dive into Princeton GEO study. Synthesize with tech writing best practices.
- [ ] **5.4.2** Write first draft (3 pts) — 3,000–3,500 words. Framework + techniques + examples.
- [ ] **5.4.3** Self-review and revision (2 pts) — Polish, fact-check citations, refine examples.
- [ ] **5.4.4** Apply GEO best practices (1 pt) — Heavy emphasis: structured data, FAQ schema, definitive headers.
- [ ] **5.4.5** Adapt for Docusaurus and publish (0 pts) — Included in prior points.
- [ ] **5.4.6** Share on platforms (0 pts) — Target UX/writing communities (Write the Docs, Substack, LinkedIn).
EOF
)" "type:story,domain:blog,lane:blog,priority:high"

# Story 5.5: Blog Post 5: Content Signals Landscape
create_issue "llmstxt-research" "[L5-E5] Blog Post 5: Content Signals Landscape" "$(cat <<'EOF' | sed 's/^    //'
    ## Story 5.5: Content Signals Landscape

**Epic:** Blog Series | **Lane:** Lane 5 (Blog & Content) | **Lane Phase:** Execution | **Target Weeks:** 10–11 | **Points:** 8
**Dependencies:** Lane 1, Story 1.3 (Thread 4 content signals analysis)

### Description
Comparative analysis of how LLMs and search engines evaluate content signals. Reference guide for developers and content creators. 3,500–4,500 words. Covers metadata, structured data, semantic richness, citation patterns.

### Acceptance Criteria
- [ ] Comprehensive signal taxonomy presented
- [ ] Comparative table (LLM vs. search engine priorities)
- [ ] Multiple worked examples
- [ ] GEO and SEO approaches contextualized
- [ ] Published and cross-referenced

### Tasks
- [ ] **5.5.1** Outline and research (2 pts) — Compile signal types. Research comparative priorities.
- [ ] **5.5.2** Write first draft (2 pts) — 3,500–4,500 words. Taxonomy + tables + examples.
- [ ] **5.5.3** Self-review and revision (2 pts) — Verify claims. Check examples. Polish.
- [ ] **5.5.4** Apply GEO best practices (1 pt) — Strong headers, table schema, internal linking strategy.
- [ ] **5.5.5** Adapt for Docusaurus and publish (1 pt) — Format tables and comparative diagrams.
- [ ] **5.5.6** Share on platforms (0 pts) — SEO and AI communities.
EOF
)" "type:story,domain:blog,lane:blog,priority:medium"

# Story 5.6: Blog Post 6: Does Clean Markdown Help?
create_issue "llmstxt-research" "[L5-E5] Blog Post 6: Does Clean Markdown Help?" "$(cat <<'EOF' | sed 's/^    //'
    ## Story 5.6: Does Clean Markdown Help?

**Epic:** Blog Series | **Lane:** Lane 5 (Blog & Content) | **Lane Phase:** Execution | **Target Weeks:** 14–16 | **Points:** 5
**Dependencies:** Lane 4, Story 4.5 (Benchmark results available)

### Description
Benchmark results post. Condenses benchmark findings on markdown formatting impact. 3,000–4,000 words. Translates technical benchmark data into practitioner insights and recommendations.

### Acceptance Criteria
- [ ] Benchmark methodology explained
- [ ] Results clearly presented (graphs, tables)
- [ ] Practical recommendations derived
- [ ] Data visualizations clear and labeled
- [ ] Published and promoted

### Tasks
- [ ] **5.6.1** Outline and research (1 pt) — Extract benchmark data. Plan visualization.
- [ ] **5.6.2** Write first draft (1.5 pts) — 3,000–4,000 words. Methods + results + recommendations.
- [ ] **5.6.3** Self-review and revision (1 pt) — Verify benchmark accuracy. Clarify findings.
- [ ] **5.6.4** Apply GEO best practices (0.5 pts) — Add structured data, definitive claims.
- [ ] **5.6.5** Adapt for Docusaurus and publish (1 pt) — Render benchmark charts. Code snippets.
- [ ] **5.6.6** Share on platforms (0 pts) — Tech and markdown communities.
EOF
)" "type:story,domain:blog,lane:blog,priority:medium"

# Story 5.7: Blog Post 7: MCP Server in C#
create_issue "llmstxt-research" "[L5-E5] Blog Post 7: MCP Server in C#" "$(cat <<'EOF' | sed 's/^    //'
    ## Story 5.7: MCP Server in C#

**Epic:** Blog Series | **Lane:** Lane 5 (Blog & Content) | **Lane Phase:** Execution | **Target Weeks:** 12–14 | **Points:** 5
**Dependencies:** Lane 2, Story 3.6 (MCP server implementation)

### Description
Technical tutorial on building an MCP (Model Context Protocol) server in C#. Code-heavy walkthrough with examples and best practices. 3,000–4,000 words. Serves as both documentation and SEO-optimized educational content.

### Acceptance Criteria
- [ ] Clear step-by-step tutorial structure
- [ ] Working code examples (runnable, tested)
- [ ] Architecture explanation
- [ ] Troubleshooting section
- [ ] Published with code repo links

### Tasks
- [ ] **5.7.1** Outline and research (1 pt) — Plan tutorial structure. Review MCP spec.
- [ ] **5.7.2** Write first draft (1.5 pts) — 3,000–4,000 words. Tutorial + code + examples.
- [ ] **5.7.3** Self-review and revision (1 pt) — Test code. Verify accuracy. Refine explanation.
- [ ] **5.7.4** Apply GEO best practices (0.5 pts) — Add code schema, structured examples.
- [ ] **5.7.5** Adapt for Docusaurus and publish (1 pt) — Code syntax highlighting. Test all links.
- [ ] **5.7.6** Share on platforms (0 pts) — Dev communities (.NET, API design).
EOF
)" "type:story,domain:blog,lane:blog,priority:medium"

# Story 5.8: Blog Post 8: What Howard Got Right
create_issue "llmstxt-research" "[L5-E5] Blog Post 8: What Howard Got Right" "$(cat <<'EOF' | sed 's/^    //'
    ## Story 5.8: What Howard Got Right

**Epic:** Blog Series | **Lane:** Lane 5 (Blog & Content) | **Lane Phase:** Execution | **Target Weeks:** 16–18 | **Points:** 8
**Dependencies:** All lanes substantially complete (research, toolkit, validator, benchmark)

### Description
Synthesis article tying the entire research journey together. Honors Howard Rheingold's "net-smart" philosophy in the context of LLM-native content. 3,500–4,500 words. Final piece establishes thought leadership and positions the author as researcher/practitioner bridge.

### Acceptance Criteria
- [ ] Comprehensive synthesis of all research findings
- [ ] References and ties to all prior blog posts
- [ ] Philosophical framing (Rheingold connection)
- [ ] Forward-looking implications
- [ ] GEO-optimized for long-form thought leadership

### Tasks
- [ ] **5.8.1** Outline and research (2 pts) — Review all prior work. Identify synthesis themes. Research Rheingold.
- [ ] **5.8.2** Write first draft (3 pts) — 3,500–4,500 words. Comprehensive synthesis + philosophy + implications.
- [ ] **5.8.3** Self-review and revision (2 pts) — Ensure coherence across all references. Polish prose.
- [ ] **5.8.4** Apply GEO best practices (1 pt) — Heavy cross-linking, definitive statements, structured citations.
- [ ] **5.8.5** Adapt for Docusaurus and publish (0 pts) — Included in prior points.
- [ ] **5.8.6** Share on platforms (0 pts) — Broad promotion. HN, Reddit, LinkedIn Pulse.
EOF
)" "type:story,domain:blog,lane:blog,priority:medium"

# ==============================================================================
# EPIC 6: BLOG DOGFOODING — Living Test Subject
# ==============================================================================

echo ""
echo "╔══════════════════════════════════════════════════════════════════════════╗"
echo "║ EPIC 6: BLOG DOGFOODING — Living Test Subject                            ║"
echo "║ Repository: southpawriter-blog                                           ║"
echo "║ Lane 5 (Blog & Content) | 3 stories | 13 points total                    ║"
echo "╚══════════════════════════════════════════════════════════════════════════╝"
echo ""

# Epic 6 issue
create_issue "southpawriter-blog" "[EPIC] Blog llms.txt Dogfooding — Living Test Subject" "$(cat <<'EOF' | sed 's/^    //'
    # Epic 6: Blog llms.txt Dogfooding — Living Test Subject

**Scope:** Use the blog itself as a living test subject for llms.txt validation, structure, and LLM consumption patterns.

**Strategy:**
- Establish baseline: Parse blog llms.txt with DocStratum reference parser
- Field-test validation rules developed in Lane 3 (Validator epic)
- Observe how LLMs consume and reason about the blog's structured content
- Document findings for future optimization

**Success Criteria:**
- Baseline parser report completed and issues filed
- All Lane 3 validation rules successfully tested against blog content
- LLM consumption observations documented and patterns identified
- Blog structure proven as valid test case for other projects

**Timeline:** Weeks 4–12 | **Points:** 13
EOF
)" "type:epic,domain:blog,lane:blog"

# Story 6.1: Baseline Validation
create_issue "southpawriter-blog" "[L5-E6] Baseline Validation" "$(cat <<'EOF' | sed 's/^    //'
    ## Story 6.1: Baseline Validation

**Epic:** Blog llms.txt Dogfooding | **Lane:** Lane 5 (Blog & Content) | **Lane Phase:** Baseline | **Target Weeks:** 4–5 | **Points:** 3
**Dependencies:** None

### Description
Establish baseline: run DocStratum reference parser against blog llms.txt. Document all output. Note any parser limitations or surprises (e.g., blog uses H3 sub-sections within H2, valid but structurally invisible to reference parser).

### Acceptance Criteria
- [ ] DocStratum parser run against blog llms.txt
- [ ] Output logged and documented
- [ ] Any parser issues or limitations identified
- [ ] Baseline report filed in research repo
- [ ] Issues created for any parser gaps

### Tasks
- [ ] **6.1.1** Run DocStratum parser against blog llms.txt (1 pt) — Execute parser. Capture output.
- [ ] **6.1.2** Document baseline results (1 pt) — Summarize findings. Note any surprises or limitations.
- [ ] **6.1.3** File any parser issues discovered (1 pt) — Create GitHub issues for gaps (e.g., H3 sub-section invisibility).
EOF
)" "type:story,domain:blog,lane:blog"

# Story 6.2: Validation Rule Field Testing
create_issue "southpawriter-blog" "[L5-E6] Validation Rule Field Testing" "$(cat <<'EOF' | sed 's/^    //'
    ## Story 6.2: Validation Rule Field Testing

**Epic:** Blog llms.txt Dogfooding | **Lane:** Lane 5 (Blog & Content) | **Lane Phase:** Field Test | **Target Weeks:** 6–8 | **Points:** 5
**Dependencies:** Lane 3, Stories 2.6, 2.7 (Validation rules created)

### Description
Field-test all validation rules developed in Lane 3 against the blog's actual structure. Verify rules work in practice. Document any edge cases. Propose refinements.

### Acceptance Criteria
- [ ] All Lane 3 validation rules tested against blog
- [ ] Edge cases and failures documented
- [ ] Refinement proposals submitted
- [ ] Field test report completed
- [ ] Blog structure deemed valid baseline for future projects

### Tasks
- [ ] **6.2.1** Set up test environment (1 pt) — Import Lane 3 validation rules. Prepare blog llms.txt.
- [ ] **6.2.2** Execute validation rules (1.5 pts) — Run all rules. Log results and failures.
- [ ] **6.2.3** Document edge cases and failures (1.5 pts) — Identify why rules failed or had surprises.
- [ ] **6.2.4** Propose refinements (1 pt) — Suggest rule improvements based on blog structure.
EOF
)" "type:story,domain:blog,lane:blog"

# Story 6.3: LLM Consumption Observation
create_issue "southpawriter-blog" "[L5-E6] LLM Consumption Observation" "$(cat <<'EOF' | sed 's/^    //'
    ## Story 6.3: LLM Consumption Observation

**Epic:** Blog llms.txt Dogfooding | **Lane:** Lane 5 (Blog & Content) | **Lane Phase:** Observe | **Target Weeks:** 9–12 | **Points:** 5
**Dependencies:** Story 6.2, Lane 2 (LlmsTxtKit for content retrieval)

### Description
Observe how LLMs consume the blog's llms.txt and structured content. Use LlmsTxtKit to fetch content programmatically. Query LLMs with questions about blog content. Document patterns in how LLMs understand and reason about the structured data. Identify optimization opportunities.

### Acceptance Criteria
- [ ] LlmsTxtKit integration with blog complete
- [ ] LLM queries executed and logged
- [ ] Consumption patterns documented
- [ ] Observations on structure effectiveness recorded
- [ ] Recommendations for future optimization included

### Tasks
- [ ] **6.3.1** Integrate LlmsTxtKit with blog (1.5 pts) — Set up programmatic content retrieval.
- [ ] **6.3.2** Design LLM query suite (1 pt) — Create questions testing various content types and structures.
- [ ] **6.3.3** Execute queries and log results (1.5 pts) — Query multiple LLMs. Log responses. Analyze patterns.
- [ ] **6.3.4** Document observations and recommendations (1 pt) — Summarize findings. Propose optimizations.
EOF
)" "type:story,domain:blog,lane:blog"

# ==============================================================================
# EPIC 7: CROSS-CUTTING INFRASTRUCTURE
# ==============================================================================

echo ""
echo "╔══════════════════════════════════════════════════════════════════════════╗"
echo "║ EPIC 7: CROSS-CUTTING INFRASTRUCTURE                                     ║"
echo "║ Repository: llmstxt-research                                             ║"
echo "║ Lane 6 (Cross-Cutting) | 5 stories | 26 points total                     ║"
echo "╚══════════════════════════════════════════════════════════════════════════╝"
echo ""

# Epic 7 issue
create_issue "llmstxt-research" "[EPIC] Cross-Cutting Infrastructure — CI/CD, Project Scaffolding & Ops" "$(cat <<'EOF' | sed 's/^    //'
    # Epic 7: Cross-Cutting Infrastructure — CI/CD, Project Scaffolding & Ops

**Scope:** Establish shared infrastructure supporting all lanes: GitHub Project management, CI/CD pipelines, repository standards, and shared research artifacts.

**Strategy:**
- GitHub Project with custom fields and views for all-lanes visibility
- Standardized labels, milestones, and repository configuration
- CI/CD pipelines for code quality and docs publishing
- Shared research bibliography and glossary
- Weekly progress reviews against lane-based roadmap

**Success Criteria:**
- GitHub Project fully configured with 6 views and 9 custom fields
- All 44 stories created as GitHub issues and linked to project
- CI/CD pipelines passing for all repositories
- Shared artifacts (bibliography, glossary) populated and maintained
- Weekly roadmap reviews conducted and documented

**Timeline:** Weeks 1–18 (ongoing) | **Points:** 26
EOF
)" "type:epic,domain:ops,lane:crosscut"

# Story 7.1: GitHub Project Setup
create_issue "llmstxt-research" "[L6-E7] GitHub Project Setup" "$(cat <<'EOF' | sed 's/^    //'
    ## Story 7.1: GitHub Project Setup

**Epic:** Cross-Cutting Infrastructure | **Lane:** Lane 6 (Cross-Cutting) | **Lane Phase:** Setup | **Target Weeks:** 1 | **Points:** 5
**Dependencies:** v2.0 Blueprint approved

### Description
Create and configure the GitHub Project (v3) that serves as the central hub for all lanes. Configure all 9 custom fields, create all 6 views, and link all 4 repositories.

**Custom Fields (9 total):**
1. **Lane** (Single Select) — Paper, Toolkit, Validator, Benchmark, Blog, Cross-Cut
2. **Epic** (Single Select) — Epic 1–7
3. **Points** (Number) — Story estimation
4. **Phase** (Single Select) — Planning, Baseline, Field Test, Execute, Observe, Setup, Ongoing
5. **Target Weeks** (Text) — Date range or week numbers
6. **Status** (Single Select) — Not Started, In Progress, Blocked, In Review, Complete
7. **Priority** (Single Select) — Critical, High, Medium, Low
8. **Dependencies** (Text) — Linked stories or external dependencies
9. **Linked PRs** (Text) — GitHub PR URLs (auto-populated when PRs reference issues)

**Views (6 total):**
1. **All Stories (Board)** — Grouped by Status
2. **By Lane (Table)** — Grouped by Lane, sorted by Epic
3. **By Phase (Board)** — Grouped by Phase
4. **Blocked Items** — Filter: Status = Blocked
5. **Weekly Roadmap** — Table sorted by Target Weeks, all lanes
6. **Completed (Archive)** — Filter: Status = Complete

### Acceptance Criteria
- [ ] GitHub Project (v3) created
- [ ] All 9 custom fields configured with correct types and options
- [ ] All 6 views created with proper grouping and filtering
- [ ] All 4 repositories linked (llmstxt-research, llmstxt-toolkit, llmstxt-validator, southpawriter-blog)
- [ ] Project is publicly visible (or team-accessible)

### Tasks
- [ ] **7.1.1** Create GitHub Project (1 pt) — Create v3 project under the org. Set visibility.
- [ ] **7.1.2** Configure custom fields (1 pt) — Add all 9 fields. Set types and valid options.
- [ ] **7.1.3** Create project views (2 pts) — Build all 6 views. Configure grouping, sorting, filters.
- [ ] **7.1.4** Link repositories (1 pt) — Add all 4 repos to the project.
EOF
)" "type:story,domain:ops,priority:critical,lane:crosscut"

# Story 7.2: Repository Label Standardization
create_issue "llmstxt-research" "[L6-E7] Repository Label Standardization" "$(cat <<'EOF' | sed 's/^    //'
    ## Story 7.2: Repository Label Standardization

**Epic:** Cross-Cutting Infrastructure | **Lane:** Lane 6 (Cross-Cutting) | **Lane Phase:** Setup | **Target Weeks:** 1–2 | **Points:** 3
**Dependencies:** Story 7.1

### Description
Standardize GitHub labels across all 4 repositories. Create consistent label taxonomy for issue categorization: type (epic, story, task), domain (paper, toolkit, validator, benchmark, blog, ops), lane (paper, toolkit, validator, benchmark, blog, crosscut), and priority (critical, high, medium, low).

**Standard Labels:**
- **Type:** type:epic, type:story, type:task, type:doc, type:bug, type:chore
- **Domain:** domain:paper, domain:toolkit, domain:validator, domain:benchmark, domain:blog, domain:ops
- **Lane:** lane:paper, lane:toolkit, lane:validator, lane:benchmark, lane:blog, lane:crosscut
- **Priority:** priority:critical, priority:high, priority:medium, priority:low
- **Status:** (maintained via custom field, not label)

### Acceptance Criteria
- [ ] All labels created in all 4 repositories
- [ ] Label naming convention documented
- [ ] All repositories have consistent label sets
- [ ] Existing issues updated with new labels (if any)

### Tasks
- [ ] **7.2.1** Design label taxonomy (1 pt) — Finalize label names and colors. Document convention.
- [ ] **7.2.2** Create labels in all 4 repos (1 pt) — Batch-create via gh CLI or web UI.
- [ ] **7.2.3** Verify and test (1 pt) — Confirm labels appear in issue creation. Document for team.
EOF
)" "type:story,domain:ops,priority:high,lane:crosscut"

# Story 7.3: Issue Population from Blueprint
create_issue "llmstxt-research" "[L6-E7] Issue Population from Blueprint" "$(cat <<'EOF' | sed 's/^    //'
    ## Story 7.3: Issue Population from Blueprint

**Epic:** Cross-Cutting Infrastructure | **Lane:** Lane 6 (Cross-Cutting) | **Lane Phase:** Setup | **Target Weeks:** 1–3 | **Points:** 8
**Dependencies:** Stories 7.1, 7.2

### Description
Populate the GitHub Project with all 44 stories from the v2.0 blueprint. This is the execution of the issue creation scripts (02-* and 03-*). All stories must be created with proper titles, bodies, labels, custom field values, and linked to the project.

**Scope:**
- Epic 1 (Paper): Story 1.1–1.3 (3 stories)
- Epic 2 (Validator): Stories 2.1–2.7, 2.5a (8 stories)
- Epic 3 (Toolkit): Stories 3.1–3.6 (6 stories)
- Epic 4 (Benchmark): Stories 4.1–4.5 (5 stories)
- Epic 5 (Blog Series): Stories 5.1–5.8 (8 stories)
- Epic 6 (Blog Dogfooding): Stories 6.1–6.3 (3 stories)
- Epic 7 (Infrastructure): Stories 7.1–7.5 (5 stories)
- **Total: 44 stories** (43 original + Story 2.5a)

### Acceptance Criteria
- [ ] All 44 stories created as GitHub issues
- [ ] All issues linked to GitHub Project
- [ ] Custom fields populated for all issues (Lane, Epic, Points, Phase, Target Weeks, Priority)
- [ ] Labels applied correctly (type, domain, lane, priority)
- [ ] Issue bodies match blueprint specification
- [ ] All dependency information captured (in issue body or custom field)

### Tasks
- [ ] **7.3.1** Create Epic issues (1 pt) — Create all 7 epic issues.
- [ ] **7.3.2** Execute issue creation scripts (3 pts) — Run 02-create-issues-epics-1-4.sh and 03-create-issues-epics-5-7.sh.
- [ ] **7.3.3** Populate custom fields (2 pts) — Batch-update all issues with Lane, Epic, Points, Phase via gh CLI or project API.
- [ ] **7.3.4** Verify project integrity (1 pt) — Confirm all 44 issues in project. Check labels and custom fields.
- [ ] **7.3.5** Create dependency documentation (1 pt) — Document all cross-story dependencies. Highlight critical path.
EOF
)" "type:story,domain:ops,priority:high,lane:crosscut"

# Story 7.4: CI/CD Pipeline Setup
create_issue "llmstxt-research" "[L6-E7] CI/CD Pipeline Setup" "$(cat <<'EOF' | sed 's/^    //'
    ## Story 7.4: CI/CD Pipeline Setup

**Epic:** Cross-Cutting Infrastructure | **Lane:** Lane 6 (Cross-Cutting) | **Lane Phase:** Setup | **Target Weeks:** 2–3 | **Points:** 5
**Dependencies:** None

### Description
Establish CI/CD pipelines for code quality, testing, and documentation publishing. Create GitHub Actions workflows for:
- Code linting and formatting (eslint, prettier, shellcheck)
- Unit tests (dotnet test for C#, jest for JS, pytest for Python)
- Documentation build and validation
- Docusaurus blog build and deploy

### Acceptance Criteria
- [ ] GitHub Actions workflows created for all repositories
- [ ] All linting and testing steps passing
- [ ] Code coverage tracked (target: >80%)
- [ ] Documentation builds without warnings
- [ ] Docusaurus blog deploys to GitHub Pages

### Tasks
- [ ] **7.4.1** Create GitHub Actions templates (1.5 pts) — Lint, test, build workflows for each repo type.
- [ ] **7.4.2** Implement workflows in all repos (2 pts) — Add .github/workflows files. Customize per repo.
- [ ] **7.4.3** Test and debug pipelines (1.5 pts) — Ensure all workflows pass. Fix failures.
EOF
)" "type:story,domain:ops,priority:high,lane:crosscut"

# Story 7.5: Shared Research Artifacts
create_issue "llmstxt-research" "[L6-E7] Shared Research Artifacts" "$(cat <<'EOF' | sed 's/^    //'
    ## Story 7.5: Shared Research Artifacts

**Epic:** Cross-Cutting Infrastructure | **Lane:** Lane 6 (Cross-Cutting) | **Lane Phase:** Ongoing | **Target Weeks:** 1–18 | **Points:** 5
**Dependencies:** None

### Description
Create and maintain shared research artifacts accessible across all lanes: a bibliography of referenced papers/articles and a glossary of domain-specific terms. These become reference materials for all writing and technical work.

**Bibliography:**
- Canonical list of all referenced papers, studies, articles, blogs
- Includes citation metadata (authors, date, URL, DOI)
- Links to PDF or official source
- Community-contributed entries welcomed

**Glossary:**
- Definitions of key terms: llms.txt, GEO (Generative Engine Optimization), SEO, LLM, MCP (Model Context Protocol), structured data, markdown, Docusaurus, etc.
- Usage examples for clarity
- Cross-references between terms

**Reference Repo Analysis:**
- Track AnswerDotAI/llms-txt repository evolution
- Document new tools, spec changes, community contributions
- Update glossary and bibliography as needed

### Acceptance Criteria
- [ ] Shared bibliography created and populated (≥20 sources)
- [ ] Shared glossary created and populated (≥30 terms)
- [ ] Both published in research repo docs or wiki
- [ ] Maintenance process documented
- [ ] Weekly progress review process established
- [ ] Reference repo analysis document started

### Tasks
- [ ] **7.5.1** Populate shared bibliography (2 pts) — Compile all referenced sources. Add metadata. Verify links.
- [ ] **7.5.2** Populate shared glossary (2 pts) — Define all key terms. Add examples. Create cross-references.
- [ ] **7.5.3** Document maintenance process (1 pt) — How to add entries. When to update. Who maintains.
- [ ] **7.5.4** Weekly progress review against roadmap (0 pts, ongoing) — Every Friday, review progress against Lane-Based Roadmap. Document in wiki. Not a completable task.
- [ ] **7.5.5** Keep reference repo analysis doc current (0 pts, ongoing) — As AnswerDotAI/llms-txt evolves, update analysis. Not a completable task.
EOF
)" "type:story,domain:ops,priority:medium,lane:crosscut"


echo ""
echo "✓ All Epic 5–7 issues created successfully!"
echo ""
