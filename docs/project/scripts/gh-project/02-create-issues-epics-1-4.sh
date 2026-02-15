#!/usr/bin/env bash
# ==============================================================================
# 02-create-issues-epics-1-4.sh
#
# Creates GitHub issues for Epics 1-4 and their component stories using the
# gh CLI. Epics covered:
#   - Epic 1: Analytical Paper (Lane 1, Paper)
#   - Epic 2: DocStratum Validator (Lane 3, Validator)
#   - Epic 3: LlmsTxtKit (Lane 2, Toolkit)
#   - Epic 4: Empirical Benchmark (Lane 4, Benchmark)
#
# v2.0 NAMING CONVENTION:
#   Epics:   [EPIC] {Epic Name}
#   Stories: [L{lane}-E{epic}] {Story Name}
#
# LANE MAPPING:
#   Lane 1 (Paper)      → Epic 1
#   Lane 2 (Toolkit)    → Epic 3
#   Lane 3 (Validator)  → Epic 2
#   Lane 4 (Benchmark)  → Epic 4
#
# ==============================================================================

set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
source "${SCRIPT_DIR}/_helpers.sh"

# ==============================================================================
# EPIC 1: ANALYTICAL PAPER — "The llms.txt Access Paradox"
# ==============================================================================

echo ""
echo "╔════════════════════════════════════════════════════════════════════════╗"
echo "║ EPIC 1: ANALYTICAL PAPER — \"The llms.txt Access Paradox\"              ║"
echo "║ Lane 1 (Paper) | Repo: llmstxt-research | 49 points across 6 stories   ║"
echo "╚════════════════════════════════════════════════════════════════════════╝"
echo ""

# EPIC 1 issue
create_issue "llmstxt-research" \
  "[EPIC] Analytical Paper — \"The llms.txt Access Paradox\"" \
  "$(cat <<'EPIC1BODY'
## Epic Overview

Comprehensive analytical paper examining the tension between llms.txt adoption and platform access restrictions (the "Access Paradox"). Paper synthesizes evidence from four key threads: the inference gap, infrastructure paradox, trust architecture, and standards fragmentation.

### Scope
- 6 component stories
- 49 total points
- Deliverable: Peer-reviewable analytical paper (PDF)
- Target completion: Week 9

### Stories (49 pts)
1. **1.1: Research Consolidation and Evidence Gathering** (8 pts) — Catalog and synthesize sources across four threads
2. **1.2: Paper Outline and Structure** (5 pts) — Create formal outline and section hierarchy
3. **1.3: First Draft** (13 pts) — Write complete draft with sections and evidence integration
4. **1.4: Review, Revision, and Data Verification** (13 pts) — Peer review, revise, verify all claims
5. **1.5: Paper Publication** (5 pts) — Format for publication, peer review, and release
6. **1.6: Benchmark-Informed Revision** (5 pts) — Incorporate empirical findings from Lane 4, Stories 4.4–4.5

### Key Artifacts
- `/docs/llms-txt-access-paradox-v1.0.pdf` (final paper)
- Evidence inventory (organized by thread)
- Revision log and peer review feedback

### Dependencies
- Depends on: Lane 4, Stories 4.4 (Data Collection and Scoring), 4.5 (Analysis) for final revision cycle
EPIC1BODY
)" \
  "type:epic,domain:paper,lane:paper"

echo ""

# Story 1.1: Research Consolidation and Evidence Gathering
create_issue "llmstxt-research" \
  "[L1-E1] Research Consolidation and Evidence Gathering" \
  "$(cat <<'STORY11BODY'
## Story 1.1: Research Consolidation and Evidence Gathering

**Epic:** Analytical Paper | **Lane:** Lane 1 (Paper) | **Lane Phase:** Gather | **Target Weeks:** 1-2 | **Points:** 8
**Dependencies:** None

### Description

Consolidate and catalog evidence sources across four threads:
1. **Thread 1: Inference Gap** — Evidence that inference deployments do not benefit from llms.txt as training sources do; server log evidence; platform statements about training vs. inference
2. **Thread 2: Infrastructure Paradox** — WAF blocks, Cloudflare policies, AI Crawl Control, firsthand blocking data
3. **Thread 3: Trust Architecture** — Google Mueller/Illyes statements, keyword tag comparisons, cloaking concerns, LLM manipulation research
4. **Thread 4: Standards Fragmentation** — Competing specs (llms.txt, Content Signals, CC Signals, IETF aipref), robots.txt history

Perform gap analysis to identify missing sources. Cross-reference adoption data from reference repo.

### Acceptance Criteria

- [ ] Evidence inventory template created and documented
- [ ] Thread 1 sources cataloged (≥15 sources): inference gap, server logs, platform statements
- [ ] Thread 2 sources cataloged (≥10 sources): WAF, Cloudflare, AI Crawl Control
- [ ] Thread 3 sources cataloged (≥12 sources): trust, Google statements, cloaking concerns
- [ ] Thread 4 sources cataloged (≥8 sources): standards fragmentation, spec docs
- [ ] Gap analysis completed; all major missing sources identified
- [ ] Reference repo `domains.md` cross-referenced with adoption statistics
- [ ] Reference parser behavior analyzed for §2 claims 2.6–2.7

### Tasks

- [ ] **1.1.1** Create evidence inventory template (1 pt) — Define structure: Thread, Source, Citation, Relevance, Status
- [ ] **1.1.2** Catalog Thread 1 sources: inference gap (2 pts) — Server log evidence, platform statements, training vs. inference. Key: Yoast, Mintlify, Profound data, developer screenshots.
- [ ] **1.1.3** Catalog Thread 2 sources: infrastructure paradox (2 pts) — WAF documentation, Cloudflare policy posts, AI Crawl Control, firsthand blocking data.
- [ ] **1.1.4** Catalog Thread 3 sources: trust architecture (1 pt) — Google statements (Mueller, Illyes), keywords meta tag comparison, cloaking concerns, LLM manipulation research.
- [ ] **1.1.5** Catalog Thread 4 sources: standards fragmentation (1 pt) — Spec documents for llms.txt, Content Signals, CC Signals, IETF aipref, robots.txt history.
- [ ] **1.1.6** Gap analysis and source acquisition (1 pt) — Identify and acquire missing primary sources
- [ ] **1.1.7** Cross-reference ref repo `domains.md` with adoption stats (0 pt) — Verify adoption landscape and alignment
- [ ] **1.1.8** Analyze reference parser behavior for §2 claims 2.6–2.7 (0 pt) — Document expected behavior for implementation stories

STORY11BODY
)" \
  "type:story,domain:paper,priority:high,lane:paper"

echo ""

# Story 1.2: Paper Outline and Structure
create_issue "llmstxt-research" \
  "[L1-E1] Paper Outline and Structure" \
  "$(cat <<'STORY12BODY'
## Story 1.2: Paper Outline and Structure

**Epic:** Analytical Paper | **Lane:** Lane 1 (Paper) | **Lane Phase:** Analyze | **Target Weeks:** 1-2 | **Points:** 5
**Dependencies:** None

### Description

Create a formal paper outline and section hierarchy. Define thesis, argument structure, and evidence mapping. Establish citation format and figure/table placeholders.

### Acceptance Criteria

- [ ] Formal outline created with main thesis and 5–7 major sections
- [ ] Evidence-to-section mapping completed for all four threads
- [ ] Citation format defined (APA or IEEE, consistent throughout)
- [ ] Figure and table placeholders defined with captions
- [ ] Outline reviewed and approved by lead researcher

### Tasks

- [ ] **1.2.1** Define thesis and main argument (1 pt) — Concise statement of paper's central claim
- [ ] **1.2.2** Create section hierarchy with key points per section (2 pts) — Abstract, Introduction, Threads 1–4, Conclusion, Appendices
- [ ] **1.2.3** Map evidence sources to sections and subsections (1 pt) — Cross-reference with Story 1.1 inventory
- [ ] **1.2.4** Define figures, tables, and visual elements (1 pt) — Placeholder captions and references

STORY12BODY
)" \
  "type:story,domain:paper,priority:high,lane:paper"

echo ""

# Story 1.3: First Draft
create_issue "llmstxt-research" \
  "[L1-E1] First Draft" \
  "$(cat <<'STORY13BODY'
## Story 1.3: First Draft

**Epic:** Analytical Paper | **Lane:** Lane 1 (Paper) | **Lane Phase:** Write | **Target Weeks:** 3-4 | **Points:** 13
**Dependencies:** Stories 1.1, 1.2

### Description

Write complete first draft incorporating all evidence, outline structure, and citations. Include reference implementation evidence (claims 2.6–2.7) and reference repo `domains.md` cross-reference for adoption landscape.

### Acceptance Criteria

- [ ] Abstract written (150–250 words)
- [ ] Introduction written with reference implementation evidence (claims 2.6–2.7)
- [ ] Adoption Landscape section written with ref repo `domains.md` cross-reference (claim 3.6)
- [ ] All four Thread sections drafted with evidence integrated
- [ ] Conclusion drafted with implications and future work
- [ ] Figures and tables inserted with captions
- [ ] All sources cited consistently
- [ ] Draft passes spell-check and readability review
- [ ] Draft reviewed by lead researcher for structure and flow

### Tasks

- [ ] **1.3.1** Write Abstract (1 pt) — Summary of thesis, methods, and key findings
- [ ] **1.3.2** Write Introduction (2 pts) — Context, motivation, thesis statement. Include reference implementation evidence (claims 2.6–2.7).
- [ ] **1.3.3** Write Adoption Landscape section (2 pts) — Global and platform adoption. Include ref repo `domains.md` cross-reference (claim 3.6).
- [ ] **1.3.4** Write Thread 1: Inference Gap section (2 pts) — Evidence synthesis, analysis, implications
- [ ] **1.3.5** Write Thread 2: Infrastructure Paradox section (2 pts) — WAF, Cloudflare, blocking evidence
- [ ] **1.3.6** Write Thread 3: Trust Architecture section (2 pts) — Trust, cloaking, manipulation research
- [ ] **1.3.7** Write Thread 4: Standards Fragmentation section (1 pt) — Spec competition, future direction
- [ ] **1.3.8** Write Conclusion and Implications (1 pt) — Summary, open questions, future work
- [ ] **1.3.9** Final draft review and polish (0 pt) — Spell-check, flow review, citation verification

STORY13BODY
)" \
  "type:story,domain:paper,priority:high,lane:paper"

echo ""

# Story 1.4: Review, Revision, and Data Verification
create_issue "llmstxt-research" \
  "[L1-E1] Review, Revision, and Data Verification" \
  "$(cat <<'STORY14BODY'
## Story 1.4: Review, Revision, and Data Verification

**Epic:** Analytical Paper | **Lane:** Lane 1 (Paper) | **Lane Phase:** Review | **Target Weeks:** 5-8 | **Points:** 13
**Dependencies:** Story 1.3

### Description

Conduct peer review cycle. Verify all claims against source evidence. Revise for clarity, logic, and impact. Address reviewer feedback and ensure factual accuracy.

### Acceptance Criteria

- [ ] Internal peer review completed (≥2 reviewers)
- [ ] All sources re-verified for accuracy and correct citation
- [ ] Revisions addressing major feedback incorporated
- [ ] Claims checked against raw evidence and source documents
- [ ] Argument structure validated for logical flow
- [ ] Figures and tables updated based on feedback
- [ ] Manuscript reaches readability level suitable for publication
- [ ] Final version approved by lead researcher

### Tasks

- [ ] **1.4.1** Conduct internal peer review (2 pts) — Two independent reviewers provide feedback
- [ ] **1.4.2** Verify Thread 1 claims against source evidence (2 pts) — Server logs, platform statements
- [ ] **1.4.3** Verify Thread 2 claims against blocking data (2 pts) — WAF logs, Cloudflare policies
- [ ] **1.4.4** Verify Thread 3 claims against trust research (2 pts) — Google statements, cloaking studies
- [ ] **1.4.5** Verify Thread 4 claims against spec documents (1 pt) — Standards and proposal texts
- [ ] **1.4.6** Revise for clarity, logic, and impact (3 pts) — Incorporate feedback, strengthen arguments
- [ ] **1.4.7** Final quality check and approval (1 pt) — Lead reviewer sign-off

STORY14BODY
)" \
  "type:story,domain:paper,priority:high,lane:paper"

echo ""

# Story 1.5: Paper Publication
create_issue "llmstxt-research" \
  "[L1-E1] Paper Publication" \
  "$(cat <<'STORY15BODY'
## Story 1.5: Paper Publication

**Epic:** Analytical Paper | **Lane:** Lane 1 (Paper) | **Lane Phase:** Review | **Target Week:** 9 | **Points:** 5
**Dependencies:** Story 1.4

### Description

Format paper for publication. Submit to academic venue or preprint service. Handle reviews and post-publication updates.

### Acceptance Criteria

- [ ] Paper formatted according to publication venue requirements
- [ ] Submission package prepared (including abstract, keywords, author info)
- [ ] Paper submitted to chosen venue (journal, preprint service, or conference)
- [ ] Submission acknowledgment received and tracked
- [ ] Public link published (arXiv, ResearchGate, or institutional repo)
- [ ] Social media announcement prepared (optional)

### Tasks

- [ ] **1.5.1** Format paper for publication venue (1 pt) — LaTeX or Word template, correct formatting
- [ ] **1.5.2** Prepare submission package and metadata (1 pt) — Abstract, keywords, author bios
- [ ] **1.5.3** Submit to chosen venue (1 pt) — Handle submission process, confirm receipt
- [ ] **1.5.4** Publish to preprint/open access repository (2 pts) — arXiv or ResearchGate; prepare release notes

STORY15BODY
)" \
  "type:story,domain:paper,priority:medium,lane:paper"

echo ""

# Story 1.6: Benchmark-Informed Revision
create_issue "llmstxt-research" \
  "[L1-E1] Benchmark-Informed Revision" \
  "$(cat <<'STORY16BODY'
## Story 1.6: Benchmark-Informed Revision

**Epic:** Analytical Paper | **Lane:** Lane 1 (Paper) | **Lane Phase:** Review | **Target Weeks:** 15-16 | **Points:** 5
**Dependencies:** Lane 4, Stories 4.4 (Data Collection and Scoring), 4.5 (Analysis Notebook and Write-Up)

### Description

Incorporate empirical benchmark findings from Lane 4 to strengthen claims and add quantitative evidence. Publish final revised version.

### Acceptance Criteria

- [ ] Lane 4 benchmark results reviewed and key findings extracted
- [ ] Paper revised to incorporate empirical evidence (≥3 revisions)
- [ ] New figures/tables from benchmark data added with captions
- [ ] Conclusion and implications updated based on empirical findings
- [ ] Final revised manuscript approved by lead researcher
- [ ] Final version published and version control updated

### Tasks

- [ ] **1.6.1** Extract key findings from Lane 4 benchmark results (1 pt) — Context collapse metrics, mitigation effectiveness
- [ ] **1.6.2** Revise Thread sections with empirical evidence (2 pts) — Strengthen claims with quantitative data
- [ ] **1.6.3** Create and integrate benchmark-derived figures and tables (1 pt) — Visualizations from analysis notebook
- [ ] **1.6.4** Update conclusion and publish final version (1 pt) — Revised conclusion, final publication

STORY16BODY
)" \
  "type:story,domain:paper,priority:medium,lane:paper"

echo ""

# ==============================================================================
# EPIC 2: DOCSTRATUM VALIDATOR — v0.3.x Through v1.0
# ==============================================================================

echo "╔════════════════════════════════════════════════════════════════════════╗"
echo "║ EPIC 2: DOCSTRATUM VALIDATOR — v0.3.x Through v1.0                    ║"
echo "║ Lane 3 (Validator) | Repo: docstratum | ~84 points across 9 stories    ║"
echo "╚════════════════════════════════════════════════════════════════════════╝"
echo ""

# EPIC 2 issue
create_issue "docstratum" \
  "[EPIC] DocStratum Validator — v0.3.x Through v1.0" \
  "$(cat <<'EPIC2BODY'
## Epic Overview

Evolution of the DocStratum validator from v0.3.x (spec-compliant parsing) through v1.0 (full governance and reporting). Introduces tiered validation, remediation framework, unified rule registry, validation profiles, and ecosystem calibration.

### Scope
- 9 component stories (including 2.5a: Extension Labeling Audit)
- ~84 total points
- Deliverables: Validator v1.0, documentation, governance framework
- Target completion: Weeks 8–12

### Key Features in v1.0
- **Output Tiers (L0–L4):** Tiered validation results from strict parsing to guidance
- **Remediation Framework:** Actionable remediation suggestions for each violation
- **Rule Registry:** Unified, extensible rule store with `spec_origin` field (`spec-compliant` or `docstratum-extension`)
- **Validation Profiles:** Composition of rules to enable different validation scenarios
- **Quality Scoring:** Numeric scoring of document quality and compliance
- **Ecosystem Calibration:** Framework for evaluating validator against third-party parsers

### Stories (~84 pts)
1. **2.1: Output Tier Specification** (8 pts) — Define L0–L4 tiers and output schemas
2. **2.2: Remediation Framework** (8 pts) — Design and specify remediation suggestion engine
3. **2.3: Unified Rule Registry** (8 pts) — Implement registry with spec-compliant/extension labels
4. **2.4: Validation Profiles & Module Composition** (8 pts) — Profile design and composition logic
5. **2.5: Report Generation Stage and Ecosystem Calibration** (13 pts) — Final reporting, ecosystem calibration
6. **2.5a: Extension Labeling Audit (NEW)** (5 pts) — Audit and label all criteria as spec or extension
7. **2.6: Implement L0–L1 Validation Checks** (13 pts) — Core spec-compliant implementation
8. **2.7: Implement L2–L3 Validation and Anti-Pattern Detection** (13 pts) — Extended and anti-pattern checks
9. **2.8: Quality Scoring and CLI Implementation** (13 pts) — Scoring engine and final CLI interface

### Key Artifacts
- `/docs/validator-governance-v1.0.md` (governance framework)
- `/docs/output-tiers-v1.0.md` (tier specifications)
- `/docs/remediation-framework-v1.0.md` (remediation design)
- `/validator/rules/registry.yaml` (unified rule registry with `spec_origin` field)
- Validator v1.0 release
- Extension labeling audit results

### Special Note on Extensions
All L2+ criteria are DocStratum-specific extensions beyond the reference parser behavior. Story 2.5a audits and explicitly labels these in the formal grammar and canonical standards (DS-CN-011, etc.).

### Dependencies
- Depends on: Existing v0.2.x parser as foundation
- Parallel to: Lane 2, Stories 3.1–3.3 (toolkit spec and parser alignment)
EPIC2BODY
)" \
  "type:epic,domain:ds-design,lane:validator"

echo ""

# Story 2.1: Output Tier Specification
create_issue "docstratum" \
  "[L3-E2] Output Tier Specification" \
  "$(cat <<'STORY21BODY'
## Story 2.1: Output Tier Specification

**Epic:** DocStratum Validator | **Lane:** Lane 3 (Validator) | **Lane Phase:** Design | **Points:** 8 | **Priority:** Critical
**Dependencies:** None

### Description

Design and specify the five output tiers (L0–L4) that categorize validation findings by severity and actionability. Define JSON schema for each tier's output, including fields for rules, violations, remediation hints, and metadata.

### Acceptance Criteria

- [ ] L0 (Parsing) tier defined and schema specified
- [ ] L1 (Spec Compliance) tier defined and schema specified
- [ ] L2 (Best Practices) tier defined and schema specified
- [ ] L3 (Optimization) tier defined and schema specified
- [ ] L4 (Guidance) tier defined and schema specified
- [ ] Cross-tier rollup and aggregation rules defined
- [ ] Example outputs for each tier created and documented
- [ ] JSON schema files created and validated

### Tasks

- [ ] **2.1.1** Design L0 (Parsing) tier: parse errors, structure validity (1 pt) — Schema with error types, line/col references
- [ ] **2.1.2** Design L1 (Spec Compliance) tier: RFC compliance, ABNF validation (2 pts) — Rules from formal spec; violation details
- [ ] **2.1.3** Design L2 (Best Practices) tier: anti-patterns, common issues (2 pts) — Content quality, readability, consistency
- [ ] **2.1.4** Design L3 (Optimization) tier: performance, efficiency improvements (1 pt) — Caching hints, structure suggestions
- [ ] **2.1.5** Design L4 (Guidance) tier: advice, recommendations (1 pt) — Non-binding guidance, optional improvements
- [ ] **2.1.6** Create tier examples and aggregation logic (1 pt) — Sample outputs, rollup rules, priority ordering

STORY21BODY
)" \
  "type:story,domain:ds-design,priority:critical,lane:validator"

echo ""

# Story 2.2: Remediation Framework
create_issue "docstratum" \
  "[L3-E2] Remediation Framework" \
  "$(cat <<'STORY22BODY'
## Story 2.2: Remediation Framework

**Epic:** DocStratum Validator | **Lane:** Lane 3 (Validator) | **Lane Phase:** Design | **Points:** 8 | **Priority:** High
**Dependencies:** Story 2.1

### Description

Design a framework for generating actionable remediation suggestions. Each violation should include hints on how to fix it, including code examples where applicable. Define the structure, templates, and logic for suggestion generation.

### Acceptance Criteria

- [ ] Remediation suggestion schema defined (description, fix, example)
- [ ] Categorization system for suggestion types created (rewording, restructure, add, remove)
- [ ] Template system for code/example generation designed
- [ ] Integration with tier system defined (which tiers get remediation)
- [ ] Remediation priority logic specified
- [ ] Example remediation chains documented (multi-step fixes)
- [ ] Accessibility and clarity guidelines for suggestions defined

### Tasks

- [ ] **2.2.1** Design remediation schema and suggestion structure (1 pt) — Fields: rule, violation, suggestion type, template
- [ ] **2.2.2** Create suggestion type categories and templates (2 pts) — Rewording, restructure, add content, remove
- [ ] **2.2.3** Define suggestion generation logic and workflow (2 pts) — Which rules get suggestions; severity-based ordering
- [ ] **2.2.4** Specify integration with Output Tiers (1 pt) — L1–L4 suggestions; L0 errors only
- [ ] **2.2.5** Create example remediation chains and documentation (2 pts) — Multi-step fix walkthroughs

STORY22BODY
)" \
  "type:story,domain:ds-design,priority:high,lane:validator"

echo ""

# Story 2.3: Unified Rule Registry
create_issue "docstratum" \
  "[L3-E2] Unified Rule Registry" \
  "$(cat <<'STORY23BODY'
## Story 2.3: Unified Rule Registry

**Epic:** DocStratum Validator | **Lane:** Lane 3 (Validator) | **Lane Phase:** Design | **Points:** 8 | **Priority:** High
**Dependencies:** Story 2.1

### Description

Design a unified, extensible rule registry that stores all validation rules. Each rule includes metadata: ID, name, description, tier, severity, remediation template, and crucially, `spec_origin` field indicating whether the rule is `spec-compliant` (from llms.txt spec) or `docstratum-extension` (beyond reference parser).

### Acceptance Criteria

- [ ] Rule schema designed with all required fields including `spec_origin`
- [ ] Rule registry structure (YAML/JSON) defined and exemplified
- [ ] Rule ID naming convention established (tier-based, hierarchical)
- [ ] Spec-compliant vs. extension classification scheme defined
- [ ] Rule inheritance and composition patterns defined
- [ ] Registry loading and hot-reload mechanism designed
- [ ] Extensibility hooks for custom rules specified
- [ ] Initial rule set (L0–L1 spec-compliant rules) documented

### Tasks

- [ ] **2.3.1** Design rule schema with `spec_origin` field (1 pt) — ID, name, tier, severity, remediation, spec_origin
- [ ] **2.3.2** Define rule registry format and organization (1 pt) — YAML structure, directory layout, versioning
- [ ] **2.3.3** Establish rule ID naming convention (1 pt) — Hierarchical naming for scoping and reference
- [ ] **2.3.4** Classify all L0–L1 criteria as spec-compliant or extension (2 pts) — Map to reference parser behavior; document discrepancies
- [ ] **2.3.5** Design extensibility hooks and custom rule interface (2 pts) — Allowing projects to add domain-specific rules
- [ ] **2.3.6** Create initial rule set and registry example (1 pt) — First 20–30 rules documented

STORY23BODY
)" \
  "type:story,domain:ds-design,priority:high,lane:validator"

echo ""

# Story 2.4: Validation Profiles & Module Composition
create_issue "docstratum" \
  "[L3-E2] Validation Profiles and Module Composition" \
  "$(cat <<'STORY24BODY'
## Story 2.4: Validation Profiles and Module Composition

**Epic:** DocStratum Validator | **Lane:** Lane 3 (Validator) | **Lane Phase:** Design | **Points:** 8 | **Priority:** High
**Dependencies:** Stories 2.1, 2.3

### Description

Design validation profiles: named collections of rules that can be composed to create different validation scenarios. Profiles enable users to customize which rules are enforced, severity levels, and optional features. Define composition logic and profile templates for common use cases.

### Acceptance Criteria

- [ ] Profile schema and structure designed
- [ ] Composition mechanism (rule selection, rule override) defined
- [ ] At least 4 standard profiles created (Minimal, Recommended, Strict, Custom)
- [ ] Profile inheritance/extension mechanism specified
- [ ] CLI interface for profile selection designed
- [ ] Profile examples and documentation created
- [ ] Profile loading and validation logic specified

### Tasks

- [ ] **2.4.1** Design profile schema and structure (1 pt) — Name, description, rules, severity overrides
- [ ] **2.4.2** Define profile composition and inheritance logic (2 pts) — Merging, overriding, extending profiles
- [ ] **2.4.3** Create standard profiles (Minimal, Recommended, Strict) (2 pts) — Rule sets for each profile
- [ ] **2.4.4** Design CLI profile selection and custom profile support (2 pts) — `--profile` flag, profile files
- [ ] **2.4.5** Document profile examples and use cases (1 pt) — Best practices for profile selection

STORY24BODY
)" \
  "type:story,domain:ds-design,priority:high,lane:validator"

echo ""

# Story 2.5: Report Generation Stage and Ecosystem Calibration
create_issue "docstratum" \
  "[L3-E2] Report Generation Stage and Ecosystem Calibration" \
  "$(cat <<'STORY25BODY'
## Story 2.5: Report Generation Stage and Ecosystem Calibration

**Epic:** DocStratum Validator | **Lane:** Lane 3 (Validator) | **Lane Phase:** Design | **Points:** 13 | **Priority:** Medium
**Dependencies:** Stories 2.1, 2.2, 2.3, 2.4

### Description

Design the final report generation stage that produces human-readable and machine-parseable outputs. Establish framework for ecosystem calibration: evaluating validator behavior against reference implementations, third-party parsers, and historical benchmarks.

### Acceptance Criteria

- [ ] Report format designs completed (JSON, Markdown, HTML)
- [ ] Report template system defined with customizable sections
- [ ] Summary statistics and metrics defined (pass rate, tier distribution, etc.)
- [ ] Export formats for integration tools specified
- [ ] Ecosystem calibration framework designed (reference comparison, scoring)
- [ ] Baseline benchmark data collected from reference parser
- [ ] Calibration metrics and deviation thresholds defined
- [ ] Documentation on comparing validator outputs completed

### Tasks

- [ ] **2.5.1** Design report JSON schema (2 pts) — Flat and hierarchical representations
- [ ] **2.5.2** Design human-readable report templates (Markdown, HTML) (2 pts) — Summary, tier breakdown, recommendations
- [ ] **2.5.3** Define report export formats for tools integration (1 pt) — SARIF, GitHub annotations, YAML/CSV
- [ ] **2.5.4** Design ecosystem calibration framework (2 pts) — Comparing against reference parser, scoring deviation
- [ ] **2.5.5** Collect baseline data from reference implementation (2 pts) — Run reference parser on corpus; document behavior
- [ ] **2.5.6** Define calibration metrics and thresholds (2 pts) — Agreement percentage, false positive/negative rates
- [ ] **2.5.7** Create calibration documentation and scoring guide (2 pts) — How to use ecosystem calibration

STORY25BODY
)" \
  "type:story,domain:ds-design,priority:medium,lane:validator"

echo ""

# Story 2.5a: Extension Labeling Audit (NEW)
create_issue "docstratum" \
  "[L3-E2] Extension Labeling Audit" \
  "$(cat <<'STORY25ABODY'
## Story 2.5a: Extension Labeling Audit

**Epic:** DocStratum Validator | **Lane:** Lane 3 (Validator) | **Lane Phase:** Design | **Points:** 5 | **Priority:** High
**Dependencies:** None (can start immediately using reference repo analysis)

### Description

Audit and classify all validation criteria (L0–L4) as either `spec-compliant` (defined in llms.txt spec) or `docstratum-extension` (beyond reference parser behavior). Incorporate findings from reference repo analysis (llms-txt-reference-repo-analysis.md). Annotate formal ABNF grammar with extension points. Update canonical standards (DS-CN-011, etc.) to note Optional section alias extensions.

### Acceptance Criteria

- [ ] L0–L1 criteria classified against reference parser behavior
- [ ] L2–L4 criteria classified (most will be extensions)
- [ ] Rationale documented for each classification with reference to llms-txt-reference-repo-analysis.md
- [ ] ABNF grammar annotated at extension points
- [ ] DS-CN-011 and related canonical standards updated with extension notes
- [ ] Classification audit report generated

### Tasks

- [ ] **2.5a.1** Classify all L0–L1 criteria as spec-compliant or extension (1 pt) — Compare each against reference parser behavior documented in llms-txt-reference-repo-analysis.md
- [ ] **2.5a.2** Classify all L2–L4 criteria as spec-compliant or extension (2 pts) — Most L2+ will be extensions since the reference parser doesn't validate. Document rationale.
- [ ] **2.5a.3** Annotate ABNF grammar extension points (1 pt) — Add inline comments to the formal grammar where rules extend beyond reference behavior
- [ ] **2.5a.4** Update DS-CN-011 and related canonical standards (1 pt) — Note that Optional section aliases are DocStratum extensions

STORY25ABODY
)" \
  "type:story,domain:ds-design,priority:high,lane:validator"

echo ""

# Story 2.6: Implement L0–L1 Validation Checks
create_issue "docstratum" \
  "[L3-E2] Implement L0-L1 Validation Checks" \
  "$(cat <<'STORY26BODY'
## Story 2.6: Implement L0-L1 Validation Checks

**Epic:** DocStratum Validator | **Lane:** Lane 3 (Validator) | **Lane Phase:** Build | **Points:** 13 | **Priority:** High
**Dependencies:** Stories 2.1-2.4, existing v0.2.x parser

### Description

Implement L0 (parsing) and L1 (spec compliance) validation checks. Build on existing v0.2.x parser. Integrate Output Tier framework, rule registry, and validation profiles. Ensure all checks are classified as spec-compliant in the registry.

### Acceptance Criteria

- [ ] L0 check implementation complete (parse errors, structure validation)
- [ ] L1 check implementation complete (ABNF compliance, required fields)
- [ ] Rule registry integration completed
- [ ] Output Tier L0 and L1 schemas implemented
- [ ] Validation profile support integrated
- [ ] Unit tests for all L0–L1 rules (>90% coverage)
- [ ] Integration tests with real documents passing
- [ ] All L0–L1 rules marked as spec-compliant in registry

### Tasks

- [ ] **2.6.1** Implement L0 parsing validation engine (2 pts) — Structure checks, encoding, line-ending handling
- [ ] **2.6.2** Implement L1 ABNF compliance checks (3 pts) — Section hierarchy, field formats, required sections
- [ ] **2.6.3** Integrate rule registry and tier outputs (2 pts) — Load rules, execute checks, format L0–L1 output
- [ ] **2.6.4** Implement validation profile support (2 pts) — Rule filtering, severity overrides, profile composition
- [ ] **2.6.5** Write comprehensive unit tests (2 pts) — Test each rule type; edge cases
- [ ] **2.6.6** Create integration test suite with real documents (2 pts) — End-to-end validation workflow

STORY26BODY
)" \
  "type:story,domain:ds-impl,priority:high,lane:validator"

echo ""

# Story 2.7: Implement L2–L3 Validation and Anti-Pattern Detection
create_issue "docstratum" \
  "[L3-E2] Implement L2-L3 Validation and Anti-Pattern Detection" \
  "$(cat <<'STORY27BODY'
## Story 2.7: Implement L2-L3 Validation and Anti-Pattern Detection

**Epic:** DocStratum Validator | **Lane:** Lane 3 (Validator) | **Lane Phase:** Build | **Points:** 13 | **Priority:** High
**Dependencies:** Story 2.6

### Description

Implement L2 (best practices) and L3 (optimization) validation checks. Detect common anti-patterns, content quality issues, and optimization opportunities. Integrate remediation suggestions. Mark rules appropriately as spec-compliant or extension in registry.

### Acceptance Criteria

- [ ] L2 best practices checks implemented (≥15 rules)
- [ ] L3 optimization checks implemented (≥10 rules)
- [ ] Anti-pattern detection engine built and integrated
- [ ] Remediation suggestions generated for all violations
- [ ] Output Tier L2 and L3 schemas implemented
- [ ] Rules classified in registry with correct spec_origin labels
- [ ] Unit tests for all L2–L3 rules (>85% coverage)
- [ ] Integration tests passing with real-world documents

### Tasks

- [ ] **2.7.1** Implement L2 best practices checks (3 pts) — Content quality, completeness, consistency across sections
- [ ] **2.7.2** Implement L3 optimization checks (2 pts) — Caching hints, structure efficiency, redundancy detection
- [ ] **2.7.3** Build anti-pattern detection engine (3 pts) — Identify and report common mistakes and bad practices
- [ ] **2.7.4** Integrate remediation suggestion generation (3 pts) — Link each violation to fix templates
- [ ] **2.7.5** Write comprehensive tests for L2–L3 rules (2 pts) — Unit and integration tests

STORY27BODY
)" \
  "type:story,domain:ds-impl,priority:high,lane:validator"

echo ""

# Story 2.8: Quality Scoring and CLI Implementation
create_issue "docstratum" \
  "[L3-E2] Quality Scoring and CLI Implementation" \
  "$(cat <<'STORY28BODY'
## Story 2.8: Quality Scoring and CLI Implementation

**Epic:** DocStratum Validator | **Lane:** Lane 3 (Validator) | **Lane Phase:** Build | **Points:** 13 | **Priority:** High
**Dependencies:** Stories 2.6, 2.7, 2.1-2.4

### Description

Implement quality scoring engine that produces a numeric score (0–100) aggregating results across all tiers. Build final CLI interface supporting profile selection, output format options, and integration with CI/CD pipelines. Create documentation and user guides.

### Acceptance Criteria

- [ ] Quality scoring algorithm defined and implemented (0–100 scale)
- [ ] Scoring incorporates all four tiers with appropriate weighting
- [ ] CLI tool supports profile selection (--profile flag)
- [ ] Multiple output formats supported (JSON, Markdown, HTML)
- [ ] CI/CD integration examples documented (GitHub Actions, etc.)
- [ ] CLI help and usage documentation complete
- [ ] End-to-end validation workflow tested and verified
- [ ] Performance benchmarks documented (validation speed)

### Tasks

- [ ] **2.8.1** Design and implement quality scoring algorithm (2 pts) — Weighted aggregation across tiers; penalty structure
- [ ] **2.8.2** Build CLI interface and argument parsing (2 pts) — Profile selection, output format, file input/output
- [ ] **2.8.3** Implement multiple output format support (2 pts) — JSON, Markdown, HTML renderers
- [ ] **2.8.4** Integrate report generation stage (1 pt) — Full report generation with tier breakdowns
- [ ] **2.8.5** Create CI/CD integration examples (2 pts) — GitHub Actions, GitLab CI, and generic CI examples
- [ ] **2.8.6** Write comprehensive CLI documentation (2 pts) — Usage guide, examples, best practices
- [ ] **2.8.7** Conduct performance testing and optimization (2 pts) — Benchmark validation speed; optimize hot paths

STORY28BODY
)" \
  "type:story,domain:ds-impl,priority:high,lane:validator"

echo ""

# ==============================================================================
# EPIC 3: LLMSTXTKIT — C#/.NET Library & MCP Server
# ==============================================================================

echo "╔════════════════════════════════════════════════════════════════════════╗"
echo "║ EPIC 3: LLMSTXTKIT — C#/.NET Library & MCP Server                      ║"
echo "║ Lane 2 (Toolkit) | Repo: LlmsTxtKit | 63 points across 7 stories       ║"
echo "╚════════════════════════════════════════════════════════════════════════╝"
echo ""

# EPIC 3 issue
create_issue "LlmsTxtKit" \
  "[EPIC] LlmsTxtKit — C#/.NET Library & MCP Server" \
  "$(cat <<'EPIC3BODY'
## Epic Overview

Comprehensive C#/.NET library and Model Context Protocol (MCP) server for parsing, validating, and serving llms.txt documents. Built with reference to miniparse.py as behavioral oracle for parsing correctness.

### Scope
- 7 component stories
- 63 total points
- Deliverables: NuGet package, MCP server, documentation
- Target completion: Weeks 13-14

### Key Components
- **LlmsDocumentParser:** Full-featured parser supporting all llms.txt features
- **LlmsDocumentFetcher:** HTTP fetcher with caching and retry logic
- **DocumentValidator:** Validation against spec and best practices
- **ContextGenerator:** Context extraction for LLM consumption
- **MCP Server:** Model Context Protocol implementation for tool usage
- **Comprehensive test suite** with behavioral equivalence verification against reference parser

### Design Philosophy
- Parse behavior verified against miniparse.py reference implementation
- Single-line blockquotes per ref impl
- H2-only section splitting
- Case-sensitive exact "Optional" match
- Canonical regex patterns from reference implementation
- Real-world corpus sourced from ref repo nbs/domains.md

### Stories (63 pts)
1. **3.1: Complete Specification Documents** (8 pts) — API specs, design docs, reference alignment
2. **3.2: Implement Parser and Fetcher** (13 pts) — Core parsing, fetching, and caching
3. **3.3: Implement Validator, Cache, and Context Generator** (13 pts) — Validation and context extraction
4. **3.4: Implement MCP Server** (8 pts) — MCP protocol implementation and tool definitions
5. **3.5: Integration Testing** (8 pts) — End-to-end testing and quality assurance
6. **3.6: Packaging, Documentation, and Release** (8 pts) — NuGet packaging, docs, and v1.0 release
7. **3.7: Post-Release Bug Fixes from Benchmark Usage** (5 pts) — Fixes based on Lane 4 benchmark findings

### Key Artifacts
- `/LlmsTxtKit/Parser/LlmsDocumentParser.cs` (main parser)
- `/LlmsTxtKit/Fetcher/LlmsDocumentFetcher.cs` (HTTP fetcher)
- `/LlmsTxtKit/Validator/DocumentValidator.cs` (validation engine)
- `/LlmsTxtKit/Context/ContextGenerator.cs` (context extraction)
- `/LlmsTxtKit.Mcp/LlmsTxtMcpServer.cs` (MCP server)
- NuGet package: `LlmsTxtKit`
- Comprehensive API documentation
- Test corpus from ref repo domains.md

### Dependencies
- Depends on: Lane 1, Story 1.1 (reference parser behavior documentation)
- Depends on: Lane 4, Story 3.4 (MCP server integration in benchmark)
- Parallel to: Lane 3, Stories 2.1–2.3 (validation specs and registry)
EPIC3BODY
)" \
  "type:epic,domain:kit-core,lane:toolkit"

echo ""

# Story 3.1: Complete Specification Documents
create_issue "LlmsTxtKit" \
  "[L2-E3] Complete Specification Documents" \
  "$(cat <<'STORY31BODY'
## Story 3.1: Complete Specification Documents

**Epic:** LlmsTxtKit | **Lane:** Lane 2 (Toolkit) | **Lane Phase:** Spec | **Target Weeks:** 3-4 | **Points:** 8
**Dependencies:** None

### Description

Complete all specification and design documents for the library. Define API surface, class hierarchies, method signatures, and behavioral contracts. Verify alignment with reference implementation (miniparse.py).

### Acceptance Criteria

- [ ] API Reference document completed (all public classes and methods)
- [ ] Design document completed (architecture, data flow, design decisions)
- [ ] Parser specification document completed (behavior, edge cases, reference alignment)
- [ ] Validator specification document completed (rules, output format)
- [ ] MCP server specification document completed (tools, resources, protocols)
- [ ] Reference implementation alignment verified (miniparse.py behavior comparison)
- [ ] Specification documents reviewed and approved by lead architect
- [ ] All specs checked into repository with version control

### Tasks

- [ ] **3.1.1** Create API Reference document (2 pts) — Class hierarchies, method signatures, examples
- [ ] **3.1.2** Create Architecture and Design document (2 pts) — Component relationships, data flow
- [ ] **3.1.3** Create Parser Specification document (2 pts) — Parsing rules, edge cases, reference alignment
- [ ] **3.1.4** Create Validator and Context Generator specification (1 pt) — Validation rules, context extraction rules
- [ ] **3.1.5** Verify reference implementation alignment and document (1 pt) — Verify miniparse.py behavior; document expected outputs

STORY31BODY
)" \
  "type:story,domain:kit-spec,priority:high,lane:toolkit"

echo ""

# Story 3.2: Implement Parser and Fetcher
create_issue "LlmsTxtKit" \
  "[L2-E3] Implement Parser and Fetcher" \
  "$(cat <<'STORY32BODY'
## Story 3.2: Implement Parser and Fetcher

**Epic:** LlmsTxtKit | **Lane:** Lane 2 (Toolkit) | **Lane Phase:** Build | **Target Weeks:** 5-6 | **Points:** 13
**Dependencies:** Story 3.1

### Description

Implement core parsing and fetching functionality. Build LlmsDocumentParser with single-line blockquote per ref impl, H2-only section splitting, case-sensitive "Optional" matching, and canonical regex patterns. Implement LlmsDocumentFetcher with HTTP, caching, and retry logic. Curate test corpus from ref repo domains.md.

### Acceptance Criteria

- [ ] LlmsDocumentParser class fully implemented
- [ ] Parser handles all llms.txt features correctly
- [ ] Single-line blockquote behavior matches reference implementation
- [ ] H2-only section splitting implemented
- [ ] Case-sensitive exact "Optional" matching verified
- [ ] Canonical regex patterns from reference implementation integrated
- [ ] LlmsDocumentFetcher class fully implemented with HTTP support
- [ ] Caching mechanism implemented and working
- [ ] Retry logic implemented with exponential backoff
- [ ] Test corpus curated from ref repo nbs/domains.md
- [ ] Parser unit tests passing with 90%+ coverage
- [ ] Behavioral equivalence verified with reference parser on corpus

### Tasks

- [ ] **3.2.1** Implement LlmsDocumentParser foundation (2 pts) — Base class, section parsing, field parsing
- [ ] **3.2.2** Implement LlmsDocumentParser features (2 pts) — Single-line blockquote per ref impl, H2-only splitting, case-sensitive exact Optional match, canonical regex pattern
- [ ] **3.2.3** Implement LlmsDocumentFetcher with HTTP and caching (2 pts) — HTTP client, ETag caching, conditional requests
- [ ] **3.2.4** Implement retry logic and error handling (1 pt) — Exponential backoff, timeout handling, error recovery
- [ ] **3.2.5** Curate real-world test corpus (2 pts) — Source from ref repo nbs/domains.md; prepare test fixtures
- [ ] **3.2.6** Write parser unit tests (2 pts) — Test all parsing rules; verify behavioral equivalence with reference parser
- [ ] **3.2.7** Conduct integration testing of parser and fetcher (2 pts) — End-to-end fetch and parse workflows

STORY32BODY
)" \
  "type:story,domain:kit-core,priority:high,lane:toolkit"

echo ""

# Story 3.3: Implement Validator, Cache, and Context Generator
create_issue "LlmsTxtKit" \
  "[L2-E3] Implement Validator, Cache, and Context Generator" \
  "$(cat <<'STORY33BODY'
## Story 3.3: Implement Validator, Cache, and Context Generator

**Epic:** LlmsTxtKit | **Lane:** Lane 2 (Toolkit) | **Lane Phase:** Build | **Target Weeks:** 7-8 | **Points:** 13
**Dependencies:** Stories 3.1, 3.2

### Description

Implement DocumentValidator for basic validation, caching layer for parser results, and ContextGenerator for LLM-friendly context extraction. ContextGenerator strips HTML comments and base64 images per reference implementation, excludes Optional sections by default (IncludeOptional=false), and wraps output in XML sections.

### Acceptance Criteria

- [ ] DocumentValidator class fully implemented
- [ ] Basic validation rules implemented and working
- [ ] Validation output formatted correctly
- [ ] Caching layer integrated with parser and fetcher
- [ ] Cache invalidation strategy implemented
- [ ] ContextGenerator class fully implemented
- [ ] HTML comment stripping per reference impl verified
- [ ] Base64 image stripping implemented correctly
- [ ] Optional section exclusion working (IncludeOptional=false default)
- [ ] XML section wrapping implemented
- [ ] Unit tests for validator and context generator (85%+ coverage)
- [ ] Integration tests with real documents passing

### Tasks

- [ ] **3.3.1** Implement DocumentValidator class (2 pts) — Validation rules, error detection, output formatting
- [ ] **3.3.2** Implement caching layer (2 pts) — Cache interface, invalidation, TTL management
- [ ] **3.3.3** Implement ContextGenerator foundation (2 pts) — Section extraction, content organization
- [ ] **3.3.4** Implement ContextGenerator features (2 pts) — Strip HTML comments and base64 images per ref impl, Optional excluded by default (IncludeOptional=false), XML section wrapping
- [ ] **3.3.5** Write validator and context generator unit tests (2 pts) — Test each major feature; edge cases
- [ ] **3.3.6** Conduct integration testing with real documents (2 pts) — End-to-end validation and context extraction
- [ ] **3.3.7** Optimize performance and memory usage (1 pt) — Profile code; optimize hot paths

STORY33BODY
)" \
  "type:story,domain:kit-core,priority:high,lane:toolkit"

echo ""

# Story 3.4: Implement MCP Server
create_issue "LlmsTxtKit" \
  "[L2-E3] Implement MCP Server" \
  "$(cat <<'STORY34BODY'
## Story 3.4: Implement MCP Server

**Epic:** LlmsTxtKit | **Lane:** Lane 2 (Toolkit) | **Lane Phase:** Build | **Target Weeks:** 9-10 | **Points:** 8
**Dependencies:** Stories 3.1-3.3

### Description

Implement full Model Context Protocol (MCP) server exposing LlmsTxtKit functionality as MCP tools and resources. Define tools for fetching and parsing documents, and resources for accessing parsed content and validation results.

### Acceptance Criteria

- [ ] MCP server base implementation complete
- [ ] MCP protocol initialization and communication working
- [ ] MCP tools for fetch, parse, validate implemented
- [ ] MCP resources for document access implemented
- [ ] Tool schemas documented in MCP format
- [ ] Error handling and protocol compliance verified
- [ ] Integration tests with MCP clients passing
- [ ] Documentation for tool usage and schema completed
- [ ] Server performance meets requirements (sub-second response times)

### Tasks

- [ ] **3.4.1** Implement MCP server foundation (1 pt) — Protocol initialization, message handling
- [ ] **3.4.2** Implement MCP tools (fetch, parse, validate) (2 pts) — Tool definitions, input/output schemas
- [ ] **3.4.3** Implement MCP resources (document content, metadata) (1 pt) — Resource URIs, content serving
- [ ] **3.4.4** Document tool schemas and usage (1 pt) — JSON schema definitions, examples
- [ ] **3.4.5** Implement error handling and edge cases (1 pt) — Timeout handling, invalid input recovery
- [ ] **3.4.6** Write unit and integration tests for MCP server (1 pt) — Test all tools and resources
- [ ] **3.4.7** Conduct performance testing and optimization (1 pt) — Measure latency; optimize as needed

STORY34BODY
)" \
  "type:story,domain:kit-mcp,priority:high,lane:toolkit"

echo ""

# Story 3.5: Integration Testing
create_issue "LlmsTxtKit" \
  "[L2-E3] Integration Testing" \
  "$(cat <<'STORY35BODY'
## Story 3.5: Integration Testing

**Epic:** LlmsTxtKit | **Lane:** Lane 2 (Toolkit) | **Lane Phase:** Test | **Target Weeks:** 11-12 | **Points:** 8
**Dependencies:** Stories 3.2-3.4

### Description

Comprehensive integration testing across all components. Test parser, fetcher, validator, context generator, and MCP server working together. Use real-world documents and various llms.txt configurations.

### Acceptance Criteria

- [ ] End-to-end parsing and context generation workflow tested
- [ ] MCP server integration with parser/fetcher/validator working
- [ ] Real-world document corpus tested (≥50 documents from ref repo)
- [ ] Edge cases and error conditions covered
- [ ] Performance benchmarks documented
- [ ] Test coverage exceeds 85% across library
- [ ] All integration tests passing
- [ ] Documentation for running tests completed

### Tasks

- [ ] **3.5.1** Create comprehensive integration test suite (2 pts) — End-to-end workflows, real documents
- [ ] **3.5.2** Test all components together (parser, fetcher, validator, MCP server) (2 pts) — Component interaction tests
- [ ] **3.5.3** Test edge cases and error handling (2 pts) — Malformed documents, network errors, missing sections
- [ ] **3.5.4** Document test results and coverage metrics (2 pts) — Coverage report, performance benchmarks, test documentation

STORY35BODY
)" \
  "type:story,domain:kit-core,priority:high,lane:toolkit"

echo ""

# Story 3.6: Packaging, Documentation, and Release
create_issue "LlmsTxtKit" \
  "[L2-E3] Packaging, Documentation, and Release" \
  "$(cat <<'STORY36BODY'
## Story 3.6: Packaging, Documentation, and Release

**Epic:** LlmsTxtKit | **Lane:** Lane 2 (Toolkit) | **Lane Phase:** Ship | **Target Weeks:** 13-14 | **Points:** 8
**Dependencies:** Stories 3.3-3.5

### Description

Package library for NuGet distribution. Create comprehensive documentation including API docs, quickstart guide, and usage examples. Release v1.0 to NuGet and announce publicly.

### Acceptance Criteria

- [ ] NuGet package created and validated
- [ ] Package metadata complete (description, authors, tags)
- [ ] README.md written with quickstart guide
- [ ] API documentation generated and formatted
- [ ] Usage examples documented (parser, validator, context, MCP)
- [ ] Installation and setup instructions clear and tested
- [ ] CHANGELOG.md created for v1.0
- [ ] Package published to nuget.org
- [ ] GitHub release created with artifacts
- [ ] Social media announcement prepared

### Tasks

- [ ] **3.6.1** Create NuGet package configuration (.csproj, .nuspec) (1 pt) — Metadata, dependencies, build configuration
- [ ] **3.6.2** Generate and format API documentation (1 pt) — XML docs, Docfx or similar tool
- [ ] **3.6.3** Write README and quickstart guide (1 pt) — Installation, basic usage, examples
- [ ] **3.6.4** Create comprehensive usage documentation (2 pts) — Parser API, validator, context generator, MCP server usage
- [ ] **3.6.5** Prepare and publish NuGet package (1 pt) — Package creation, test publish, public release
- [ ] **3.6.6** Create GitHub release and announcement (2 pts) — Release notes, changelog, public announcement

STORY36BODY
)" \
  "type:story,domain:kit-core,priority:medium,lane:toolkit"

echo ""

# Story 3.7: Post-Release Bug Fixes from Benchmark Usage
create_issue "LlmsTxtKit" \
  "[L2-E3] Post-Release Bug Fixes from Benchmark Usage" \
  "$(cat <<'STORY37BODY'
## Story 3.7: Post-Release Bug Fixes from Benchmark Usage

**Epic:** LlmsTxtKit | **Lane:** Lane 2 (Toolkit) | **Lane Phase:** Ship | **Target Weeks:** 15-16 | **Points:** 5
**Dependencies:** Lane 4, Story 4.4 (Data Collection and Scoring)

### Description

Monitor and address issues discovered during Lane 4 benchmark data collection. Apply bug fixes, performance improvements, and enhancements based on real-world usage patterns.

### Acceptance Criteria

- [ ] All critical bugs from Lane 4 usage reported and fixed
- [ ] Performance improvements identified and implemented
- [ ] Edge cases discovered in benchmark integrated into test suite
- [ ] v1.1 patch release prepared
- [ ] Release notes documenting fixes created
- [ ] v1.1 published to NuGet

### Tasks

- [ ] **3.7.1** Monitor Lane 4 benchmark execution for issues (1 pt) — Track errors, performance issues, edge cases
- [ ] **3.7.2** Triage and fix critical bugs (2 pts) — Prioritize issues; implement fixes
- [ ] **3.7.3** Add discovered edge cases to test suite (1 pt) — Regression test coverage
- [ ] **3.7.4** Release v1.1 patch with fixes (1 pt) — Package, release notes, NuGet publish

STORY37BODY
)" \
  "type:story,domain:kit-core,priority:medium,lane:toolkit"

echo ""

# ==============================================================================
# EPIC 4: EMPIRICAL BENCHMARK — Context Collapse Mitigation Study
# ==============================================================================

echo "╔════════════════════════════════════════════════════════════════════════╗"
echo "║ EPIC 4: EMPIRICAL BENCHMARK — Context Collapse Mitigation Study        ║"
echo "║ Lane 4 (Benchmark) | Repo: llmstxt-research | 60 points across 6 stories ║"
echo "╚════════════════════════════════════════════════════════════════════════╝"
echo ""

# EPIC 4 issue
create_issue "llmstxt-research" \
  "[EPIC] Empirical Benchmark — Context Collapse Mitigation Study" \
  "$(cat <<'EPIC4BODY'
## Epic Overview

Rigorous empirical benchmark studying how llms.txt and structured documentation mitigate context collapse in language models. Measures answer accuracy with/without llms.txt context and evaluates toolkit effectiveness.

### Scope
- 6 component stories
- 60 total points
- Deliverables: Benchmark dataset, analysis notebook, paper findings
- Target completion: Weeks 15-16

### Benchmark Design
- **Corpus:** 20-30 carefully selected sites (sourced from ref repo nbs/domains.md)
- **Question Set:** 5-10 questions per site (factual retrieval, structural understanding)
- **Methodology:** A/B testing with/without llms.txt context
- **Metrics:** Accuracy, context efficiency, latency
- **Models:** Multiple LLMs (GPT-4, Claude, Llama, etc.)
- **Artifact:** Jupyter notebook with analysis, visualizations, and findings

### Key Metrics
- Context collapse severity without llms.txt
- Mitigation effectiveness with llms.txt
- Performance by document structure type
- Toolkit efficiency (latency, compression)
- LLM model differences

### Stories (60 pts)
1. **4.1: Corpus Selection and Question Authoring** (13 pts) — Select sites, create questions, establish baselines
2. **4.2: Methodology Specification and Review** (8 pts) — Test protocol, metrics, evaluation criteria
3. **4.3: Data Collection Infrastructure** (8 pts) — Benchmarking scripts, LlmsTxtKit integration
4. **4.4: Data Collection and Scoring** (13 pts) — Run experiments, evaluate results, gather data
5. **4.5: Analysis Notebook and Write-Up** (13 pts) — Jupyter analysis, visualizations, findings summary
6. **4.6: Benchmark Publication** (5 pts) — Prepare benchmark dataset, publish as research artifact

### Key Artifacts
- `/research/benchmark/corpus-selection.md` (selected sites and rationale)
- `/research/benchmark/test-protocol.md` (benchmark methodology)
- `/research/benchmark/data/` (benchmark results, CSV)
- `/research/benchmark/analysis.ipynb` (Jupyter notebook with analysis and visualizations)
- `/research/benchmark/README.md` (benchmark documentation)

### Dependencies
- Depends on: Lane 2, Story 3.4 (LlmsTxtKit MCP server for context generation)
- Provides findings to: Lane 1, Story 1.6 (Benchmark-Informed Paper Revision)
EPIC4BODY
)" \
  "type:epic,domain:benchmark,lane:benchmark"

echo ""

# Story 4.1: Corpus Selection and Question Authoring
create_issue "llmstxt-research" \
  "[L4-E4] Corpus Selection and Question Authoring" \
  "$(cat <<'STORY41BODY'
## Story 4.1: Corpus Selection and Question Authoring

**Epic:** Empirical Benchmark | **Lane:** Lane 4 (Benchmark) | **Lane Phase:** Design | **Target Weeks:** 3-6 | **Points:** 13
**Dependencies:** None

### Description

Select 20-30 representative sites for the benchmark corpus. For each site, author 5-10 factual and structural comprehension questions. Evaluate baseline difficulty and establish question quality standards. Cross-reference with ref repo nbs/domains.md for curated candidates.

### Acceptance Criteria

- [ ] 20-30 sites selected with documented rationale
- [ ] Corpus covers diverse site types and structures
- [ ] 100-200 total questions authored (5-10 per site)
- [ ] Questions validated for clarity and factual correctness
- [ ] Baseline difficulty established (manual evaluation on 2-3 sites)
- [ ] Question answer keys created and verified
- [ ] Cross-reference with ref repo nbs/domains.md completed
- [ ] Corpus and questions documented in benchmark-corpus-selection.md

### Tasks

- [ ] **4.1.1** Establish site selection criteria (1 pt) — Diversity, llms.txt quality, question difficulty
- [ ] **4.1.2** Source and evaluate candidate sites (3 pts) — Cross-reference with ref repo nbs/domains.md for curated candidates; document reasoning
- [ ] **4.1.3** Author factual retrieval questions (3 pts) — 2-3 questions per site testing factual knowledge
- [ ] **4.1.4** Author structural comprehension questions (3 pts) — 2-3 questions per site testing document structure understanding
- [ ] **4.1.5** Validate questions and answer keys (2 pts) — Manual verification; establish baseline accuracy
- [ ] **4.1.6** Document corpus and methodology (1 pt) — Benchmark-corpus-selection.md

STORY41BODY
)" \
  "type:story,domain:benchmark,priority:high,lane:benchmark"

echo ""

# Story 4.2: Methodology Specification and Review
create_issue "llmstxt-research" \
  "[L4-E4] Methodology Specification and Review" \
  "$(cat <<'STORY42BODY'
## Story 4.2: Methodology Specification and Review

**Epic:** Empirical Benchmark | **Lane:** Lane 4 (Benchmark) | **Lane Phase:** Design | **Target Weeks:** 5-7 | **Points:** 8
**Dependencies:** None

### Description

Specify detailed benchmark methodology: test protocol, metric definitions, evaluation criteria, and LLM model selection. Define data collection workflow and analysis plan. Conduct peer review of methodology to ensure rigor and validity.

### Acceptance Criteria

- [ ] Test protocol documented (with/without llms.txt A/B test design)
- [ ] LLM models selected (≥3 models: GPT-4, Claude, Llama, etc.)
- [ ] Metrics defined (accuracy, latency, token efficiency, context compression)
- [ ] Evaluation criteria established (scoring rubric for answers)
- [ ] Data collection workflow specified (scripts, automation, validation)
- [ ] Analysis plan defined (statistical tests, visualizations)
- [ ] Methodology reviewed by independent peers
- [ ] Review feedback incorporated and documented
- [ ] Final methodology document published (test-protocol.md)

### Tasks

- [ ] **4.2.1** Define A/B test protocol and experimental design (1 pt) — Control/treatment setup, randomization, replication
- [ ] **4.2.2** Select LLM models and testing frameworks (1 pt) — Model selection, API configuration
- [ ] **4.2.3** Define metrics and scoring rubric (2 pts) — Accuracy, latency, token metrics; manual/automatic scoring
- [ ] **4.2.4** Specify data collection and validation workflow (2 pts) — Collection scripts, error handling, validation checks
- [ ] **4.2.5** Conduct peer review of methodology (2 pts) — Independent review; document feedback and responses

STORY42BODY
)" \
  "type:story,domain:benchmark,priority:high,lane:benchmark"

echo ""

# Story 4.3: Data Collection Infrastructure
create_issue "llmstxt-research" \
  "[L4-E4] Data Collection Infrastructure" \
  "$(cat <<'STORY43BODY'
## Story 4.3: Data Collection Infrastructure

**Epic:** Empirical Benchmark | **Lane:** Lane 4 (Benchmark) | **Lane Phase:** Collect | **Target Weeks:** 7-10 | **Points:** 8
**Dependencies:** Lane 2, Story 3.4 (LlmsTxtKit MCP Server)

### Description

Build automated data collection infrastructure. Integrate LlmsTxtKit for context generation, LLM APIs for evaluation, and result logging. Implement error handling, retries, and progress tracking. Prepare for large-scale benchmark execution.

### Acceptance Criteria

- [ ] Data collection scripts fully implemented and tested
- [ ] LlmsTxtKit integration complete (fetch, parse, context generation)
- [ ] LLM API integration working for all selected models
- [ ] Context generation pipeline verified (HTML comment and base64 image stripping per ref impl)
- [ ] Result logging and storage configured
- [ ] Error handling and retry logic implemented
- [ ] Progress tracking and monitoring in place
- [ ] Dry-run executed successfully on test corpus
- [ ] Documentation for running data collection completed

### Tasks

- [ ] **4.3.1** Build benchmark execution framework (1 pt) — Experiment runner, result storage, progress tracking
- [ ] **4.3.2** Integrate LlmsTxtKit (2 pts) — Fetch, parse, validate documents; strip HTML comments and base64 images from Markdown content per reference implementation behavior
- [ ] **4.3.3** Integrate LLM APIs and evaluation logic (2 pts) — API clients, prompt engineering, response evaluation
- [ ] **4.3.4** Implement error handling and monitoring (1 pt) — Retry logic, error logging, alerts
- [ ] **4.3.5** Conduct dry-run and validation (2 pts) — Test on small corpus; verify data quality

STORY43BODY
)" \
  "type:story,domain:benchmark,priority:high,lane:benchmark"

echo ""

# Story 4.4: Data Collection and Scoring
create_issue "llmstxt-research" \
  "[L4-E4] Data Collection and Scoring" \
  "$(cat <<'STORY44BODY'
## Story 4.4: Data Collection and Scoring

**Epic:** Empirical Benchmark | **Lane:** Lane 4 (Benchmark) | **Lane Phase:** Run | **Target Weeks:** 9-14 | **Points:** 13
**Dependencies:** Stories 4.1-4.3

### Description

Execute full benchmark across all sites, questions, and LLM models. Collect results, evaluate answers, and compile scoring data. Monitor for issues and document anomalies.

### Acceptance Criteria

- [ ] Full benchmark executed across all 20-30 sites
- [ ] All ~150-200 questions evaluated with/without llms.txt
- [ ] All LLM models tested (≥3 models, multiple runs)
- [ ] All results scored according to rubric
- [ ] Raw data collected and validated
- [ ] Results compiled into structured database (CSV/JSON)
- [ ] Data quality checks passed (no significant anomalies)
- [ ] Anomalies documented and explained
- [ ] Intermediate results reviewed and approved

### Tasks

- [ ] **4.4.1** Execute benchmark on all sites and questions (4 pts) — Run all experiments; monitor progress
- [ ] **4.4.2** Evaluate and score all responses (3 pts) — Apply rubric; handle edge cases; manual review where needed
- [ ] **4.4.3** Compile and validate results data (2 pts) — Organize results; verify completeness and accuracy
- [ ] **4.4.4** Document anomalies and deviations (2 pts) — Log unusual results; investigate root causes
- [ ] **4.4.5** Generate preliminary summary statistics (2 pts) — Calculate accuracy, latency, efficiency metrics by site/model

STORY44BODY
)" \
  "type:story,domain:benchmark,priority:high,lane:benchmark"

echo ""

# Story 4.5: Analysis Notebook and Write-Up
create_issue "llmstxt-research" \
  "[L4-E4] Analysis Notebook and Write-Up" \
  "$(cat <<'STORY45BODY'
## Story 4.5: Analysis Notebook and Write-Up

**Epic:** Empirical Benchmark | **Lane:** Lane 4 (Benchmark) | **Lane Phase:** Analyze | **Target Weeks:** 12-16 | **Points:** 13
**Dependencies:** Story 4.4

### Description

Analyze benchmark results in Jupyter notebook. Create visualizations, perform statistical analysis, and write findings summary. Identify key insights about context collapse mitigation effectiveness and toolkit performance.

### Acceptance Criteria

- [ ] Jupyter notebook created with full analysis
- [ ] Descriptive statistics calculated for all metrics
- [ ] Statistical significance testing performed (A/B test results)
- [ ] Visualizations created (plots, charts, heatmaps)
- [ ] Key findings identified and documented
- [ ] Analysis reviewed by lead researcher
- [ ] Write-up of findings completed (≥2000 words)
- [ ] Methodology and limitations discussed
- [ ] Recommendations for future work included
- [ ] Notebook and write-up committed to repository

### Tasks

- [ ] **4.5.1** Load and explore benchmark results data (1 pt) — Data import, validation, initial exploration
- [ ] **4.5.2** Conduct descriptive statistical analysis (2 pts) — Mean, median, variance by site/model; comparison tables
- [ ] **4.5.3** Perform significance testing and effect size analysis (2 pts) — T-tests, effect sizes, confidence intervals
- [ ] **4.5.4** Create visualizations (plots, charts, heatmaps) (2 pts) — Accuracy by site/model, context efficiency, latency
- [ ] **4.5.5** Identify and document key findings (2 pts) — Context collapse severity, mitigation effectiveness, toolkit performance
- [ ] **4.5.6** Write findings summary and analysis narrative (4 pts) — 2000+ word write-up; methodology discussion; limitations; future work

STORY45BODY
)" \
  "type:story,domain:benchmark,priority:high,lane:benchmark"

echo ""

# Story 4.6: Benchmark Publication
create_issue "llmstxt-research" \
  "[L4-E4] Benchmark Publication" \
  "$(cat <<'STORY46BODY'
## Story 4.6: Benchmark Publication

**Epic:** Empirical Benchmark | **Lane:** Lane 4 (Benchmark) | **Lane Phase:** Analyze | **Target Weeks:** 15-16 | **Points:** 5
**Dependencies:** Story 4.5

### Description

Prepare and publish benchmark as open research artifact. Create documentation, prepare dataset for sharing, and release publicly. Enable reproducibility and facilitate community use.

### Acceptance Criteria

- [ ] Benchmark documentation completed (methodology, dataset description, results)
- [ ] Dataset prepared for public sharing (anonymized, validated)
- [ ] Reproducibility guide written (how to run benchmark locally)
- [ ] GitHub repository prepared with code and data
- [ ] Zenodo/OSF registration completed for persistent archiving
- [ ] Public release announcement prepared
- [ ] License (CC-BY 4.0 or similar) applied to dataset
- [ ] README with overview and usage instructions created

### Tasks

- [ ] **4.6.1** Prepare comprehensive benchmark documentation (1 pt) — Corpus description, methodology review, dataset overview
- [ ] **4.6.2** Create reproducibility guide (1 pt) — Instructions for running benchmark; environment setup
- [ ] **4.6.3** Package dataset for public release (1 pt) — Organize files, prepare archives, validate integrity
- [ ] **4.6.4** Publish and announce benchmark (2 pts) — GitHub/Zenodo release, DOI registration, public announcement

STORY46BODY
)" \
  "type:story,domain:benchmark,priority:medium,lane:benchmark"

echo ""
echo "╔════════════════════════════════════════════════════════════════════════╗"
echo "║ Issue creation complete. All Epics 1-4 and their stories have been     ║"
echo "║ created and added to the GitHub project.                              ║"
echo "╚════════════════════════════════════════════════════════════════════════╝"
echo ""
