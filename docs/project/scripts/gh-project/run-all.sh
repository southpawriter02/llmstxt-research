#!/usr/bin/env bash
# ==============================================================================
# run-all.sh
# Master orchestrator: runs all setup and population scripts in order.
#
# v2.0 changes: Added Step 5 (custom field population), updated counts to
# reflect 51 issues, 30 labels, and 9 custom fields (8 scripted + 1 manual).
#
# Usage:
#   cd scripts/gh-project
#   chmod +x *.sh
#   ./run-all.sh
#
# This script will:
#   1. Create standardized labels across all 4 repositories (30 labels each)
#   2. Create the GitHub Project with 8 custom fields (+ 1 manual)
#   3. Populate issues for Epics 1–4 (Lanes 1–4): 4 epics + 28 stories
#   4. Populate issues for Epics 5–7 (Lanes 5–6): 3 epics + 16 stories
#   5. Set custom field values (Epic, Points, Phase, Lane, Lane Phase, Target
#      Week) on all 51 project items
#
# Prerequisites:
#   - gh CLI installed (https://cli.github.com/)
#   - gh auth login completed with sufficient scopes:
#       gh auth login --scopes "project,repo"
#   - Write access to all four repositories:
#       southpawriter02/llmstxt-research
#       southpawriter02/LlmsTxtKit
#       southpawriter02/docstratum
#       southpawriter02/southpawriter-blog
#
# Estimated runtime: ~6 minutes (51 issues × 1s rate-limit delay + API calls
#   + field discovery + 51 × 6 field-edit operations)
#
# IMPORTANT: This script is designed to be run ONCE. Running it again will
# create duplicate issues. If you need to re-run, delete the existing issues
# first or modify the scripts to check for existing issues.
# ==============================================================================

set -euo pipefail
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
cd "$SCRIPT_DIR"

echo "╔══════════════════════════════════════════════════════════════════╗"
echo "║  llms.txt Research & Tooling Initiative — v2.0 (Lane-Based)    ║"
echo "║  GitHub Project Population Script                              ║"
echo "╚══════════════════════════════════════════════════════════════════╝"
echo ""

# ---------------------------------------------------------------------------
# Pre-flight checks
# ---------------------------------------------------------------------------
echo "--- Pre-flight checks ---"

# Check gh CLI
if ! command -v gh &> /dev/null; then
  echo "ERROR: gh CLI not found. Install it from https://cli.github.com/"
  exit 1
fi
echo "  [✓] gh CLI found: $(gh --version | head -1)"

# Check authentication
if ! gh auth status &> /dev/null; then
  echo "ERROR: gh not authenticated. Run: gh auth login --scopes 'project,repo'"
  exit 1
fi
echo "  [✓] gh authenticated"

# Check jq (needed by 04-set-custom-fields.sh)
if ! command -v jq &> /dev/null; then
  echo "ERROR: jq not found. Install it: brew install jq / apt install jq"
  exit 1
fi
echo "  [✓] jq found: $(jq --version)"

# Check repo access
OWNER="southpawriter02"
REPOS=("llmstxt-research" "LlmsTxtKit" "docstratum" "southpawriter-blog")
for repo in "${REPOS[@]}"; do
  if ! gh repo view "${OWNER}/${repo}" &> /dev/null; then
    echo "ERROR: Cannot access ${OWNER}/${repo}. Check permissions."
    exit 1
  fi
  echo "  [✓] ${OWNER}/${repo} accessible"
done

echo ""
echo "All pre-flight checks passed."
echo ""

# ---------------------------------------------------------------------------
# Confirmation prompt
# ---------------------------------------------------------------------------
echo "This script will:"
echo "  1. Create 30 labels in each of 4 repositories (~120 label operations)"
echo "  2. Create 1 GitHub Project with 8 custom fields"
echo "  3. Create 51 GitHub Issues across 4 repositories (7 epics + 44 stories)"
echo "  4. Add all 51 issues to the project"
echo "  5. Set 6 custom field values on each of the 51 items (~306 field edits)"
echo ""
echo "Estimated runtime: ~6 minutes"
echo ""
read -p "Proceed? (y/N) " -n 1 -r
echo ""
if [[ ! $REPLY =~ ^[Yy]$ ]]; then
  echo "Aborted."
  exit 0
fi

# ---------------------------------------------------------------------------
# Execute scripts in order
# ---------------------------------------------------------------------------
echo ""
echo "╔══════════════════════════════════════════════════════════════════╗"
echo "║  Step 1/5: Setting up labels (30 × 4 repos)                   ║"
echo "╚══════════════════════════════════════════════════════════════════╝"
bash "${SCRIPT_DIR}/00-setup-labels.sh"

echo ""
echo "╔══════════════════════════════════════════════════════════════════╗"
echo "║  Step 2/5: Creating GitHub Project + 8 custom fields           ║"
echo "╚══════════════════════════════════════════════════════════════════╝"
bash "${SCRIPT_DIR}/01-create-project.sh"

echo ""
echo "╔══════════════════════════════════════════════════════════════════╗"
echo "║  Step 3/5: Creating issues — Epics 1–4 (Lanes 1–4)           ║"
echo "╚══════════════════════════════════════════════════════════════════╝"
bash "${SCRIPT_DIR}/02-create-issues-epics-1-4.sh"

echo ""
echo "╔══════════════════════════════════════════════════════════════════╗"
echo "║  Step 4/5: Creating issues — Epics 5–7 (Lanes 5–6)           ║"
echo "╚══════════════════════════════════════════════════════════════════╝"
bash "${SCRIPT_DIR}/03-create-issues-epics-5-7.sh"

echo ""
echo "╔══════════════════════════════════════════════════════════════════╗"
echo "║  Step 5/5: Setting custom fields on all 51 items               ║"
echo "╚══════════════════════════════════════════════════════════════════╝"
bash "${SCRIPT_DIR}/04-set-custom-fields.sh"

echo ""
echo "╔══════════════════════════════════════════════════════════════════╗"
echo "║  COMPLETE                                                       ║"
echo "╚══════════════════════════════════════════════════════════════════╝"
echo ""
echo "Your GitHub Project is set up with all 51 issues and custom field values."
echo ""
echo "Scripted fields populated per item:"
echo "  - Epic, Story Points, Phase, Lane, Lane Phase, Target Week"
echo ""
echo "Manual follow-up steps (see MANUAL-FOLLOWUP-GUIDE.md):"
echo "  1. Create the 'Iteration' field (requires project settings UI — 2-week sprints)"
echo "  2. Create 6 project views (Backlog, Sprint Board, Dependency Tracker,"
echo "     Timeline, By Repository, By Lane)"
echo "  3. Add 'Blocked By' URLs to blocked issues using the text field"
echo "  4. Populate the 'Repository' custom field per item (optional — GitHub's"
echo "     built-in repo grouping works without it)"
echo ""
echo "See the Project Management Blueprint for the full dependency map"
echo "and field values for each issue."
