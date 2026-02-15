# GitHub Project Population Scripts

Automated scripts to create the GitHub Project, labels, and issues defined in the [Project Management Blueprint](../../llmstxt-project-management-blueprint.md) (v2.0 — Lane-Based).

## Overview

These scripts set up the complete GitHub Project for the **llms.txt Research & Tooling Initiative**, organized around 6 parallel lanes of work spanning 4 repositories. The scripts create 51 issues (7 epics + 44 stories), 30 labels, and 9 custom fields — then populate each issue's field values automatically.

## Prerequisites

1. **Install the GitHub CLI:** https://cli.github.com/
2. **Install jq** (used by `04-set-custom-fields.sh` for field ID discovery):
   ```bash
   # macOS
   brew install jq
   # Ubuntu/Debian
   sudo apt install jq
   ```
3. **Authenticate with the right scopes:**
   ```bash
   gh auth login --scopes "project,repo"
   ```
4. **Verify access** to all four repositories:
   - `southpawriter02/llmstxt-research`
   - `southpawriter02/LlmsTxtKit`
   - `southpawriter02/docstratum`
   - `southpawriter02/southpawriter-blog`

## Usage

### Option A: Run everything at once

```bash
cd scripts/gh-project
chmod +x *.sh
./run-all.sh
```

This runs all five scripts in sequence with a confirmation prompt. Estimated runtime: ~6 minutes.

### Option B: Run scripts individually

```bash
cd scripts/gh-project
chmod +x *.sh

# Step 1: Create labels in all repos (30 labels × 4 repos)
./00-setup-labels.sh

# Step 2: Create GitHub Project and 8 custom fields
./01-create-project.sh

# Step 3: Create issues for Epics 1–4 (Lanes 1–4: Paper, DocStratum, LlmsTxtKit, Benchmark)
./02-create-issues-epics-1-4.sh

# Step 4: Create issues for Epics 5–7 (Lanes 5–6: Blog & Content, Cross-Cutting)
./03-create-issues-epics-5-7.sh

# Step 5: Set custom field values on all 51 project items
./04-set-custom-fields.sh
```

## What gets created

| Script | Creates |
|---|---|
| `00-setup-labels.sh` | 30 labels × 4 repos = ~120 label operations |
| `01-create-project.sh` | 1 GitHub Project + 8 custom fields (Lane, Epic, Story Points, Lane Phase, Phase, Blocked By, Target Week, Repository) |
| `02-create-issues-epics-1-4.sh` | 4 epic issues + 28 story issues (Lanes 1–4) |
| `03-create-issues-epics-5-7.sh` | 3 epic issues + 16 story issues (Lanes 5–6) |
| `04-set-custom-fields.sh` | Sets Epic, Story Points, Phase, Lane, Lane Phase, Target Week on all 51 items |
| **Total** | 1 project, ~120 labels, 51 issues, 51 × 6 field assignments |

## Lane structure

| Lane | Epic(s) | Primary Repo | Stories |
|---|---|---|---|
| Lane 1: Paper | Epic 1 | llmstxt-research | 6 |
| Lane 2: LlmsTxtKit | Epic 3 | LlmsTxtKit | 7 |
| Lane 3: DocStratum | Epic 2 | docstratum | 9 (includes Story 2.5a) |
| Lane 4: Benchmark | Epic 4 | llmstxt-research | 6 |
| Lane 5: Blog & Content | Epics 5, 6 | southpawriter-blog | 11 (8 blog posts + 3 dogfooding) |
| Lane 6: Cross-Cutting | Epic 7 | llmstxt-research | 5 |
| **Total** | **7 epics** | **4 repos** | **44 stories** |

## Custom fields (9 total)

| Field | Type | Populated by Script? | Notes |
|---|---|---|---|
| Epic | Single Select | Yes | 7 options (one per epic) |
| Story Points | Number | Yes | Fibonacci-ish: 1, 2, 3, 5, 8, 13 |
| Phase | Single Select | Yes | Phases 0–4 |
| Lane | Single Select | Yes | 6 lanes |
| Lane Phase | Single Select | Yes | 16 lane-specific sub-phases (Gather, Analyze, Write, etc.) |
| Blocked By | Text | No | Manually enter blocking issue URLs |
| Target Week | Number | Yes | Week 1–18 |
| Repository | Single Select | No | Manually select; or use GitHub's built-in repo grouping |
| Iteration | Iteration | No | Must be created in project settings UI (2-week sprints) |

## After running

The scripts handle labels, project creation, issue creation, project membership, and field population. The following steps require manual work through the GitHub UI (see [MANUAL-FOLLOWUP-GUIDE.md](./MANUAL-FOLLOWUP-GUIDE.md) for detailed instructions):

1. **Iteration field:** Create a 2-week iteration field in the project settings and assign items to sprints.
2. **Project views:** Create the 6 views (Backlog, Sprint Board, Dependency Tracker, Timeline, By Repository, By Lane).
3. **Blocked By links:** Add cross-repo issue URLs to the "Blocked By" text field on blocked issues.
4. **Repository field:** Optionally populate the Repository custom field per item.

## Important notes

- **Run once only.** These scripts do not check for existing issues. Running them a second time will create duplicates.
- **Rate limiting.** Each issue creation includes a 1-second delay to avoid GitHub API rate limits. Total runtime is approximately 6 minutes.
- **Idempotent labels.** The label script is safe to re-run — it creates or updates labels without duplicating.
- **jq required.** The field population script (`04-set-custom-fields.sh`) uses `jq` to parse field and option IDs from the GitHub API.
