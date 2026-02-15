# Manual Follow-Up Guide — GitHub Project Configuration

**Purpose:** This guide covers the configuration steps that cannot be automated through the `gh` CLI: creating the Iteration field, creating project views, and populating the "Blocked By" cross-references. Complete these after running `04-set-custom-fields.sh` (or `run-all.sh`).

**v2.0 changes:** Added "By Lane" view (View 6). Updated issue title patterns to use lane-based naming (`[L{lane}-E{epic}]`). Noted that Lane, Lane Phase, Epic, Story Points, Phase, and Target Week are now script-populated — only Blocked By, Repository, and Iteration require manual work.

**Project URL:** `https://github.com/users/southpawriter02/projects/<NUMBER>`
(Replace `<NUMBER>` with the value in `.project-number`)

---

## Table of Contents

1. [Create the Iteration Field](#1-set-up-the-iteration-field)
2. [Create Project Views](#2-create-project-views)
3. [Populate Blocked By Cross-References](#3-populate-blocked-by-cross-references)
4. [Optionally Populate the Repository Field](#4-optionally-populate-the-repository-field)
5. [Verification Checklist](#5-verification-checklist)

---

## 1. Set Up the Iteration Field

The Iteration field is a special GitHub Projects V2 field type that represents time-boxed sprints. Unlike other custom fields, it can only be created through the project settings UI — the `gh` CLI and GraphQL API don't support creating iteration fields.

### Why You Need It

The Iteration field enables two key features:

1. **Sprint Board filtering:** Filter the Sprint Board view to `@current` iteration, so you only see work planned for this sprint.
2. **Roadmap positioning:** The Roadmap view can use iteration start/end dates to position items on the timeline.

### How to Create It

1. Open your project settings: Click the **`⋯`** (three dots) menu in the top-right of the project → **Settings**.
2. Scroll down to **Custom fields**.
3. Click **New field**.
4. Set the field name to **`Iteration`**.
5. Set the field type to **Iteration**.
6. Configure the iteration:
   - **Duration:** 2 weeks (aligns with the blog's publication cadence and the roadmap's biweekly rhythm).
   - **Start date:** Your actual project start date (e.g., Feb 17, 2026, the Monday after today).
   - **Create iterations:** Click the `+` to add iterations. Create 9 iterations to cover the full 18-week timeline:

     | Iteration | Dates (example: starting Feb 17) | Phase Alignment |
     |---|---|---|
     | Sprint 1 | Feb 17 – Feb 28 | Phase 0 / Phase 1 start |
     | Sprint 2 | Mar 2 – Mar 13 | Phase 1 |
     | Sprint 3 | Mar 16 – Mar 27 | Phase 1 / Phase 2 start |
     | Sprint 4 | Mar 30 – Apr 10 | Phase 2 |
     | Sprint 5 | Apr 13 – Apr 24 | Phase 2 / Phase 3 start |
     | Sprint 6 | Apr 27 – May 8 | Phase 3 |
     | Sprint 7 | May 11 – May 22 | Phase 3 |
     | Sprint 8 | May 25 – Jun 5 | Phase 3 / Phase 4 start |
     | Sprint 9 | Jun 8 – Jun 19 | Phase 4 |

7. Click **Save**.

### Assigning Items to Iterations

For the complete sprint-by-sprint assignment plan with capacity math, dependency chains, and item-level notes, see **`llmstxt-sprint-assignment-plan.docx`** in the project root. That document maps every story to a specific sprint with real GitHub issue titles.

Once the Iteration field exists, you can assign items to sprints either:

- **In the table view:** Click the Iteration cell for an item and select a sprint from the dropdown.
- **In the board view:** Drag items into the appropriate column for their iteration.
- **During sprint planning:** At the start of each sprint, pull items from the Backlog view into the current iteration based on their Phase, dependencies, and your capacity.

Quick reference for initial assignment (see the sprint plan document for the full breakdown with all issue titles):

| Sprint | Weeks | Points | Key Items |
|---|---|---|---|
| Sprint 1 | Feb 17 – Feb 28 | 39 pts | Project setup, Research Consolidation, Extension Labeling Audit, Blog Post 1, Shared Artifacts |
| Sprint 2 | Mar 2 – Mar 13 | 39 pts | LlmsTxtKit Specs, Output Tier Spec (ROOT BLOCKER), Paper Outline, Corpus Selection, CI/CD |
| Sprint 3 | Mar 16 – Mar 27 | 42 pts | Paper First Draft, Remediation Framework, Rule Registry, Parser/Fetcher |
| Sprint 4 | Mar 30 – Apr 10 | 47 pts | Paper Review, Validation Profiles, Validator/Cache/Context, Methodology, Blog Post 2 |
| Sprint 5 | Apr 13 – Apr 24 | 34 pts | Paper Publication, Report Generation, MCP Server, Blog Post 3, Baseline Validation |
| Sprint 6 | Apr 27 – May 8 | 45 pts | Integration Testing, Data Collection Infra, L0-L1 Checks, Blog Posts 4-5 |
| Sprint 7 | May 11 – May 22 | 39 pts | LlmsTxtKit v1.0 Release, Data Collection, L2-L3 Checks, Blog Post 7 |
| Sprint 8 | May 25 – Jun 5 | 46 pts | Benchmark Analysis, Quality Scoring/CLI, Paper Revision, Bug Fixes, Blog Post 6, Field Testing |
| Sprint 9 | Jun 8 – Jun 19 | 18 pts | Benchmark Publication, Blog Post 8 (synthesis), LLM Consumption Observation |

---

## 2. Create Project Views

GitHub Projects V2 supports multiple "views" of the same data — each view can have its own layout, grouping, filtering, and sorting. The blueprint calls for six views (one more than v1.1, adding "By Lane"), described below with step-by-step setup instructions.

### How to Create a View

1. Open your project at the URL above.
2. Click the **`+`** tab to the right of the existing "View 1" tab.
3. Give the view a name (see below).
4. Choose a layout type (Table, Board, or Roadmap).
5. Configure grouping, filtering, and sorting as described for each view.

### View 1: Backlog (Table)

This is your default "full inventory" view — every open item, grouped by epic so you can see the breakdown at a glance.

| Setting | Value |
|---|---|
| **Layout** | Table |
| **Name** | Backlog |
| **Group by** | Epic (custom field) |
| **Sort by** | Phase (ascending), then Story Points (descending) |
| **Filter** | `is:open` (shows only open items) |
| **Visible columns** | Title, Status, Epic, Lane, Lane Phase, Story Points, Phase, Target Week, Repository, Labels |

**Steps:**

1. Rename the default "View 1" tab to "Backlog" by double-clicking the tab name.
2. Make sure the layout is "Table" (it's the default).
3. Click the **down arrow** next to the view name → **Group by** → select **Epic**.
4. Click the **down arrow** → **Sort by** → add **Phase** ascending, then **Story Points** descending.
5. Click the **down arrow** → **Fields** → ensure all listed columns are visible. Hide anything you don't need (like "Assignees" if you're solo).

### View 2: Sprint Board (Kanban)

This is your day-to-day working view — a board with columns for workflow stages, filtered to the current iteration (once the Iteration field is set up).

| Setting | Value |
|---|---|
| **Layout** | Board |
| **Name** | Sprint Board |
| **Column field** | Status |
| **Columns** | Todo, In Progress, In Review, Done |
| **Filter** | (Initially) `is:open` — later, filter by Iteration field once configured |
| **Card fields** | Epic, Lane, Story Points, Labels |

**Steps:**

1. Click `+` to create a new view. Name it "Sprint Board."
2. Switch the layout to **Board** (icon at the top of the view).
3. The board will default to using Status as columns. GitHub's default statuses are "Todo," "In Progress," and "Done." You can add "In Review" by:
   - Clicking the **`+`** at the right side of the board columns.
   - Typing "In Review" and pressing Enter.
4. Drag the "In Review" column to sit between "In Progress" and "Done."
5. Click the **down arrow** → **Fields** to choose which fields appear on each card. Select **Epic**, **Lane**, **Story Points**, and **Labels**.
6. Later (after setting up the Iteration field), add a filter: **Iteration** → **is** → **@current** to scope the board to the current sprint.

### View 3: Dependency Tracker (Table)

A filtered view that shows only items with the `blocked` label — your at-a-glance blocker radar.

| Setting | Value |
|---|---|
| **Layout** | Table |
| **Name** | Dependency Tracker |
| **Group by** | Lane |
| **Filter** | `label:blocked` |
| **Sort by** | Phase ascending |
| **Visible columns** | Title, Status, Lane, Epic, Blocked By, Phase, Repository |

**Steps:**

1. Click `+` to create a new view. Name it "Dependency Tracker."
2. Keep the layout as Table.
3. Click the **down arrow** → **Filter** → type `label:blocked` in the filter bar.
4. Group by **Lane** (changed from Epic in v1.1 — lanes give better visibility into which workstreams are blocked).
5. Sort by **Phase** ascending.
6. Adjust visible columns to show **Blocked By** prominently (this is where the cross-reference URLs go).

**Note:** This view will initially be empty unless you've applied the `blocked` label to items. As you begin work and encounter blockers, add the `blocked` label to those issues. The "Blocked By" text field should contain the URL(s) of the blocking issue(s).

### View 4: Timeline (Roadmap)

A phase-level progress view using GitHub's Roadmap layout. This gives you a Gantt-style visualization of when each epic and story is expected to land.

| Setting | Value |
|---|---|
| **Layout** | Roadmap |
| **Name** | Timeline |
| **Date field** | (See note below) |
| **Group by** | Lane |
| **Filter** | `label:type:epic OR label:type:story` (only high-level items) |

**Steps:**

1. Click `+` to create a new view. Name it "Timeline."
2. Switch the layout to **Roadmap** (timeline icon at the top).
3. GitHub's Roadmap view requires date fields (start date and target date) on items. Since we're using Target Week (a number field) rather than actual dates, you have two options:

   **Option A — Use Iteration field as the date source:** Once you create the Iteration field (see Section 1), the Roadmap can use iteration start/end dates to position items on the timeline. This is the recommended approach.

   **Option B — Add Start Date / End Date fields:** Create two new Date-type custom fields (`Start Date`, `Target Date`) and populate them based on the week numbers from the blueprint. This gives you the most precise timeline but requires manual date entry. The 18-week timeline starting from your actual start date would map like this:

   | Week | Start Date (if starting Feb 17, 2026) |
   |---|---|
   | 1 | Feb 17 |
   | 3 | Mar 2 |
   | 5 | Mar 16 |
   | 7 | Mar 30 |
   | 9 | Apr 13 |
   | 11 | Apr 27 |
   | 13 | May 11 |
   | 15 | May 25 |
   | 17 | Jun 8 |
   | 18 | Jun 15 |

4. Group by **Lane** so you see swimlanes per workstream.
5. Filter to show only epics and stories (not individual tasks) to keep the timeline readable.

### View 5: By Repository (Table)

A simple table view grouped by repository — useful when you're focused on a single codebase and want to see only its work items.

| Setting | Value |
|---|---|
| **Layout** | Table |
| **Name** | By Repository |
| **Group by** | Repository |
| **Sort by** | Phase ascending, Story Points descending |
| **Filter** | `is:open` |
| **Visible columns** | Title, Status, Lane, Epic, Story Points, Phase, Labels |

**Steps:**

1. Click `+` to create a new view. Name it "By Repository."
2. Keep the layout as Table.
3. Group by **Repository**. GitHub auto-detects which repo each issue belongs to, so the "Repository" grouping is built in — you don't need a custom field for it.
4. Sort by Phase ascending, then Story Points descending.

### View 6: By Lane (Board) — NEW in v2.0

A board view that groups work by lane — the primary organizational axis for v2.0. This gives you a swimlane-style overview of progress across all six lanes simultaneously.

| Setting | Value |
|---|---|
| **Layout** | Board |
| **Name** | By Lane |
| **Column field** | Lane (custom field) |
| **Columns** | Paper, LlmsTxtKit, DocStratum, Benchmark, Blog & Content, Cross-Cutting |
| **Filter** | `is:open` |
| **Card fields** | Epic, Lane Phase, Story Points, Phase |

**Steps:**

1. Click `+` to create a new view. Name it "By Lane."
2. Switch the layout to **Board**.
3. Set the column field to **Lane** (the custom field created by the scripts). The board will show one column per lane, with items sorted into their respective lanes.
4. Click the **down arrow** → **Fields** to choose which fields appear on each card. Select **Epic**, **Lane Phase**, **Story Points**, and **Phase**.
5. Optionally add a filter for `is:open` to hide completed items.

**Tip:** This view is especially useful for sprint planning — you can see at a glance which lanes have the most items in flight and which have capacity for more work.

---

## 3. Populate Blocked By Cross-References

The "Blocked By" field is a text field containing URLs to the blocking issue(s). Now that all issues exist with real GitHub URLs, you can populate these cross-references. This is the mapping from the blueprint's dependency map.

**Important:** Issue titles in v2.0 use the lane-based naming convention: `[L{lane}-E{epic}] Story Name`. Use these patterns when searching.

### Cross-Epic Dependencies

For each blocked story below, open the story's issue, find the "Blocked By" custom field, and paste the URL of the blocking issue.

| Blocked Story | Blocking Story | How to Find the Blocking Issue |
|---|---|---|
| Story 4.3 (Benchmark infrastructure) | Story 3.4 (MCP server) | Search `LlmsTxtKit` repo issues for "[L2-E3]" |
| Story 1.6 (Paper revision) | Story 4.5 (Benchmark analysis) | Search `llmstxt-research` issues for "[L4-E4] Quantitative Analysis" |
| Story 5.2 (Blog Post 2) | Story 1.3 (Paper first draft) | Search `llmstxt-research` issues for "[L1-E1] First Draft" |
| Story 5.3 (Blog Post 3) | Story 3.1 (LlmsTxtKit specs) | Search `LlmsTxtKit` issues for "[L2-E3] Complete Spec" |
| Story 5.6 (Blog Post 6) | Story 4.5 (Benchmark analysis) | Search `llmstxt-research` issues for "[L4-E4] Quantitative Analysis" |
| Story 5.7 (Blog Post 7) | Story 3.6 (LlmsTxtKit v1.0) | Search `LlmsTxtKit` issues for "[L2-E3] Release" |
| Story 5.8 (Blog Post 8) | All other epics | Note: "All epics substantially complete" — enter URLs of all epic issues |
| Story 6.2 (Validation field testing) | Stories 2.6, 2.7 (DocStratum validation) | Search `docstratum` issues for "[L3-E2] Implement L0" and "[L3-E2] Implement L2" |
| Story 6.3 (LLM consumption) | Story 3.3 (LlmsTxtKit context gen) | Search `LlmsTxtKit` issues for "[L2-E3] Advanced Features" |
| Story 3.7 (Post-release fixes) | Story 4.4 (Benchmark data collection) | Search `llmstxt-research` issues for "[L4-E4] Data Collection" |

### Intra-Epic Dependencies (DocStratum Chain — Lane 3)

DocStratum's documentation backlog has a strict dependency chain. Each story blocks the next:

```
[L3-E2] Output Tier Specification (Story 2.1)
  → blocks [L3-E2] Remediation Action Framework (Story 2.2)
  → blocks [L3-E2] Unified Rule Registry (Story 2.3)
    → blocks [L3-E2] Validation Profiles (Story 2.4)
      → blocks [L3-E2] Report Generation and Calibration (Story 2.5)
        → blocks [L3-E2] Extension Labeling Audit (Story 2.5a)
          → blocks [L3-E2] Implement L0–L1 (Story 2.6)
            → blocks [L3-E2] Implement L2–L3 (Story 2.7)
              → blocks [L3-E2] Quality Scoring and CLI (Story 2.8)
```

For each of these, open the blocked story and add the URL of its predecessor to the "Blocked By" field.

### Intra-Epic Dependencies (LlmsTxtKit Chain — Lane 2)

```
[L2-E3] Complete Spec Documents (Story 3.1)
  → blocks [L2-E3] Core Parser and Fetcher (Story 3.2)
    → blocks [L2-E3] Advanced Features (Story 3.3)
      → blocks [L2-E3] MCP Server (Story 3.4)
        → blocks [L2-E3] Integration Testing (Story 3.5)
          → blocks [L2-E3] Release v1.0 (Story 3.6)
```

### Intra-Epic Dependencies (Benchmark Chain — Lane 4)

```
[L4-E4] Corpus Selection (Story 4.1) → blocks [L4-E4] Methodology Design (Story 4.2)
Stories 4.1 + 4.2 + 4.3 → block [L4-E4] Data Collection (Story 4.4)
[L4-E4] Data Collection (Story 4.4) → blocks [L4-E4] Quantitative Analysis (Story 4.5)
[L4-E4] Quantitative Analysis (Story 4.5) → blocks [L4-E4] Publication (Story 4.6)
```

### Intra-Epic Dependencies (Paper Chain — Lane 1)

```
[L1-E1] Research Consolidation (Story 1.1) → blocks [L1-E1] Structural Analysis (Story 1.2)
Stories 1.1 + 1.2 → block [L1-E1] First Draft (Story 1.3)
[L1-E1] First Draft (Story 1.3) → blocks [L1-E1] Peer Review (Story 1.4)
[L1-E1] Peer Review (Story 1.4) → blocks [L1-E1] Revision (Story 1.5)
```

### Adding the `blocked` Label

For every story that has a "Blocked By" entry, also add the `blocked` label. This makes the story visible in the Dependency Tracker view. You can do this in bulk:

```bash
# Example: Mark Story 4.3 as blocked (use the lane-based title to find it)
gh issue list --repo southpawriter02/llmstxt-research --search "[L4-E4] Infrastructure" --json number,url

# Then add the label
gh issue edit <NUMBER> --repo southpawriter02/llmstxt-research --add-label "blocked"
```

**Tip:** Not all dependent stories need to be marked `blocked` right now. Only mark items as `blocked` if their blocker is not yet complete. As work progresses and blockers are resolved, remove the `blocked` label from unblocked stories. The Dependency Tracker view will naturally shrink as blockers are cleared.

---

## 4. Optionally Populate the Repository Field

The "Repository" custom field was created by the scripts with options for all 4 repos (`llmstxt-research`, `LlmsTxtKit`, `docstratum`, `southpawriter-blog`). However, this field cannot be auto-populated because the GitHub API doesn't expose a way to derive an issue's repo during `item-edit` operations.

You have two choices:

1. **Populate it manually** in the project board UI by clicking the Repository cell for each item and selecting the correct repo. This takes about 5 minutes for 51 items.
2. **Skip it entirely.** GitHub's built-in "Repository" grouping (available in any view) already knows which repo each issue belongs to. The custom field is only needed if you want to filter or sort by repository in project-level queries.

---

## 5. Verification Checklist

After completing all manual follow-up steps, walk through this checklist to verify everything is set up correctly:

- [ ] **Views exist:** Backlog, Sprint Board, Dependency Tracker, Timeline, By Repository, By Lane — all 6 tabs visible in the project.
- [ ] **Backlog view:** Items are grouped by Epic. All 7 epic groups appear. Each story shows its Story Points, Lane, Lane Phase, and Phase.
- [ ] **Sprint Board:** Board layout with at least 3 columns (Todo, In Progress, Done). "In Review" column added if desired.
- [ ] **Dependency Tracker:** Filtered to `label:blocked`. Shows "Blocked By" column with URLs. Grouped by Lane.
- [ ] **Timeline:** Roadmap layout with items positioned on a timeline (via Iteration or Date fields). Grouped by Lane.
- [ ] **By Repository:** Items grouped by their source repository. All 4 repos appear as groups.
- [ ] **By Lane:** Board layout with 6 lane columns. All lanes have items.
- [ ] **Iteration field:** Exists in project settings with 9 two-week iterations defined.
- [ ] **Custom fields populated (scripted):** Spot-check 5–10 items across different lanes to verify Epic, Story Points, Phase, Lane, Lane Phase, and Target Week are set correctly.
- [ ] **Blocked By populated:** At least the cross-epic dependencies (10 entries from the table above) have URLs in the "Blocked By" field.
- [ ] **Blocked labels applied:** Stories with active blockers have the `blocked` label.

---

## What's Next?

With the project fully configured, you're ready to begin Phase 1 work. The recommended first sprint (Sprint 1) should pull from these parallelizable Phase 1 stories across all 6 lanes:

- **[L1-E1] Story 1.1** — Research Consolidation and Evidence Gathering (Paper)
- **[L3-E2] Story 2.1** — Output Tier Specification (DocStratum — root blocker for the longest dependency chain)
- **[L2-E3] Story 3.1** — Complete Spec Documents (LlmsTxtKit)
- **[L4-E4] Story 4.1** — Corpus Selection and Domain Mapping (Benchmark)
- **[L5-E5] Story 5.1** — Blog Post 1: "What Is llms.txt?" (Blog Series)
- **[L6-E7] Story 7.4** — CI/CD Pipeline Setup (Infrastructure)
- **[L6-E7] Story 7.5** — Shared Research Artifacts (Infrastructure)

These seven stories have no mutual dependencies and represent ~52 story points of parallel work. Prioritize Story 2.1 (Output Tier Specification) since it's the root blocker for the longest dependency chain in the project.
