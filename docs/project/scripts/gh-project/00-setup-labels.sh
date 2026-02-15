#!/usr/bin/env bash
# ==============================================================================
# 00-setup-labels.sh
# Creates the standardized label taxonomy across all four repositories.
#
# Labels are idempotent: if a label already exists, gh will update its color
# and description rather than failing.
#
# v2.0 changes: Added 6 lane labels (lane:paper, lane:toolkit, lane:validator,
# lane:benchmark, lane:blog, lane:crosscut). Total labels: 30.
#
# Usage:
#   chmod +x 00-setup-labels.sh
#   ./00-setup-labels.sh
#
# Prerequisites:
#   - gh CLI installed and authenticated (gh auth login)
#   - Write access to all four repositories
# ==============================================================================

set -euo pipefail

# ---------------------------------------------------------------------------
# Configuration: GitHub username / org prefix
# ---------------------------------------------------------------------------
OWNER="southpawriter02"

REPOS=(
  "${OWNER}/llmstxt-research"
  "${OWNER}/LlmsTxtKit"
  "${OWNER}/docstratum"
  "${OWNER}/southpawriter-blog"
)

# ---------------------------------------------------------------------------
# Helper: create or update a label in a given repo
# Usage: ensure_label <repo> <name> <color_hex> <description>
# ---------------------------------------------------------------------------
ensure_label() {
  local repo="$1" name="$2" color="$3" desc="$4"

  # Try to create; if it already exists, edit it instead
  if ! gh label create "$name" \
    --repo "$repo" \
    --color "$color" \
    --description "$desc" \
    2>/dev/null; then
    gh label edit "$name" \
      --repo "$repo" \
      --color "$color" \
      --description "$desc" \
      2>/dev/null || true
  fi
}

# ---------------------------------------------------------------------------
# Label definitions
# Format: "name|color|description"
# ---------------------------------------------------------------------------
LABELS=(
  # --- Type labels (mutually exclusive) ---
  "type:epic|6A0DAD|Top-level work bucket. Contains stories."
  "type:story|1D76DB|User-facing chunk of value. Contains tasks."
  "type:task|0E8A16|Individual work item. Assignable and completable."
  "type:spike|FBCA04|Research or investigation needed before a task can be defined."
  "type:bug|D93F0B|Defect in existing functionality."

  # --- Lane labels (one per issue — v2.0) ---
  "lane:paper|1B4F72|Lane 1: Research Paper"
  "lane:toolkit|6C3483|Lane 2: LlmsTxtKit"
  "lane:validator|117A65|Lane 3: DocStratum"
  "lane:benchmark|B9770E|Lane 4: Benchmark Study"
  "lane:blog|922B21|Lane 5: Blog & Content"
  "lane:crosscut|566573|Lane 6: Cross-Cutting"

  # --- Domain labels ---
  "domain:paper|C5DEF5|Analytical paper work"
  "domain:benchmark|C5DEF5|Benchmark study work"
  "domain:blog|C5DEF5|Blog post drafting/publishing"
  "domain:kit-core|C5DEF5|LlmsTxtKit.Core library"
  "domain:kit-mcp|C5DEF5|LlmsTxtKit.Mcp server"
  "domain:kit-spec|C5DEF5|LlmsTxtKit specification documents"
  "domain:ds-design|C5DEF5|DocStratum design specifications"
  "domain:ds-impl|C5DEF5|DocStratum implementation"
  "domain:ds-test|C5DEF5|DocStratum testing"
  "domain:site|C5DEF5|Blog site infrastructure"
  "domain:ops|C5DEF5|CI/CD, GitHub Actions, project management"

  # --- Status labels ---
  "blocked|B60205|Waiting on a dependency (cross-repo or intra-repo)"
  "needs-spec|D4C5F9|Cannot proceed until a specification is written"
  "needs-review|0E8A16|Work is complete but requires review before closing"
  "deferred|BFDADC|Explicitly moved to a later phase"

  # --- Priority labels ---
  "priority:critical|B60205|Blocks multiple other items. Must be resolved first."
  "priority:high|D93F0B|Important for the current phase."
  "priority:medium|FBCA04|Should be done in the current phase if time permits."
  "priority:low|0E8A16|Nice to have. Can slip to next phase."
)

# ---------------------------------------------------------------------------
# Main: iterate repos × labels
# ---------------------------------------------------------------------------
echo "=== Setting up labels across ${#REPOS[@]} repositories (${#LABELS[@]} labels each) ==="
echo ""

for repo in "${REPOS[@]}"; do
  echo "--- ${repo} ---"
  for entry in "${LABELS[@]}"; do
    IFS='|' read -r name color desc <<< "$entry"
    echo "  [+] ${name}"
    ensure_label "$repo" "$name" "$color" "$desc"
  done
  echo ""
done

echo "=== Label setup complete (${#LABELS[@]} labels × ${#REPOS[@]} repos) ==="
