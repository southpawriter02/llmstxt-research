#!/usr/bin/env bash
# ==============================================================================
# 01-create-project.sh
# Creates the user-level GitHub Project (V2) and configures custom fields.
#
# v2.0 changes: Added 3 new custom fields (Lane, Lane Phase, Repository).
# Total scripted fields: 8. Iteration field still requires manual UI creation.
#
# NOTE: GitHub Projects V2 custom fields must be created through the GraphQL
# API. The gh CLI's `project` commands support this.
#
# Usage:
#   chmod +x 01-create-project.sh
#   ./01-create-project.sh
#
# Output:
#   Prints the project number and URL.
#   Writes the project number to .project-number for use by later scripts.
# ==============================================================================

set -euo pipefail

OWNER="southpawriter02"
PROJECT_TITLE="llms.txt Research & Tooling Initiative"

# ---------------------------------------------------------------------------
# Step 1: Create the project (user-owned)
# ---------------------------------------------------------------------------
echo "=== Creating GitHub Project: ${PROJECT_TITLE} ==="

# gh project create returns the project URL
PROJECT_URL=$(gh project create \
  --owner "@me" \
  --title "$PROJECT_TITLE" \
  --format json 2>/dev/null | jq -r '.url' 2>/dev/null) || true

if [ -z "$PROJECT_URL" ] || [ "$PROJECT_URL" = "null" ]; then
  # Fallback: try without json format (older gh versions)
  PROJECT_URL=$(gh project create \
    --owner "@me" \
    --title "$PROJECT_TITLE" 2>&1)
fi

echo "Project created: ${PROJECT_URL}"

# Extract the project number from the URL (last path segment)
PROJECT_NUMBER=$(echo "$PROJECT_URL" | grep -oE '[0-9]+$')

if [ -z "$PROJECT_NUMBER" ]; then
  echo ""
  echo "WARNING: Could not extract project number automatically."
  echo "Please find your project at: https://github.com/users/${OWNER}/projects"
  echo "Then run:  echo <NUMBER> > .project-number"
  echo ""
  exit 1
fi

echo "$PROJECT_NUMBER" > .project-number
echo "Project number: ${PROJECT_NUMBER} (saved to .project-number)"

# ---------------------------------------------------------------------------
# Step 2: Create custom fields (8 total — Iteration requires manual UI)
# ---------------------------------------------------------------------------
echo ""
echo "=== Creating custom fields (8 scripted + 1 manual) ==="

# --- Field 1: Epic (Single Select) ---
echo "  [+] Epic"
gh project field-create "$PROJECT_NUMBER" \
  --owner "@me" \
  --name "Epic" \
  --data-type "SINGLE_SELECT" \
  --single-select-options "Paper,DocStratum,LlmsTxtKit,Benchmark,Blog Series,Blog Dogfooding,Infrastructure" \
  2>/dev/null || echo "    (may already exist)"

# --- Field 2: Story Points (Number) ---
echo "  [+] Story Points"
gh project field-create "$PROJECT_NUMBER" \
  --owner "@me" \
  --name "Story Points" \
  --data-type "NUMBER" \
  2>/dev/null || echo "    (may already exist)"

# --- Field 3: Phase (Single Select) ---
echo "  [+] Phase"
gh project field-create "$PROJECT_NUMBER" \
  --owner "@me" \
  --name "Phase" \
  --data-type "SINGLE_SELECT" \
  --single-select-options "Phase 0 (Setup),Phase 1 (Foundations),Phase 2 (Implementation),Phase 3 (Experimentation),Phase 4 (Synthesis)" \
  2>/dev/null || echo "    (may already exist)"

# --- Field 4: Blocked By (Text) ---
echo "  [+] Blocked By"
gh project field-create "$PROJECT_NUMBER" \
  --owner "@me" \
  --name "Blocked By" \
  --data-type "TEXT" \
  2>/dev/null || echo "    (may already exist)"

# --- Field 5: Target Week (Number) ---
echo "  [+] Target Week"
gh project field-create "$PROJECT_NUMBER" \
  --owner "@me" \
  --name "Target Week" \
  --data-type "NUMBER" \
  2>/dev/null || echo "    (may already exist)"

# --- Field 6: Lane (Single Select) — NEW in v2.0 ---
echo "  [+] Lane"
gh project field-create "$PROJECT_NUMBER" \
  --owner "@me" \
  --name "Lane" \
  --data-type "SINGLE_SELECT" \
  --single-select-options "Paper,LlmsTxtKit,DocStratum,Benchmark,Blog & Content,Cross-Cutting" \
  2>/dev/null || echo "    (may already exist)"

# --- Field 7: Lane Phase (Single Select) — NEW in v2.0 ---
echo "  [+] Lane Phase"
gh project field-create "$PROJECT_NUMBER" \
  --owner "@me" \
  --name "Lane Phase" \
  --data-type "SINGLE_SELECT" \
  --single-select-options "Gather,Analyze,Write,Review,Spec,Build,Test,Ship,Design,Collect,Run,Calibrate,Post,Infra,Setup,Ongoing" \
  2>/dev/null || echo "    (may already exist)"

# --- Field 8: Repository (Single Select) — NEW in v2.0 ---
# NOTE: This field cannot be auto-populated by the script. GitHub does not
# expose a way to derive the issue's repo and set it via item-edit. Populate
# manually in the project board UI, or leave it for GitHub's built-in
# Repository grouping (which works without a custom field).
echo "  [+] Repository"
gh project field-create "$PROJECT_NUMBER" \
  --owner "@me" \
  --name "Repository" \
  --data-type "SINGLE_SELECT" \
  --single-select-options "llmstxt-research,LlmsTxtKit,docstratum,southpawriter-blog" \
  2>/dev/null || echo "    (may already exist)"

# --- Field 9: Iteration (MANUAL — requires UI) ---
# The Iteration field type can only be created through the GitHub Projects UI.
# See MANUAL-FOLLOWUP-GUIDE.md for step-by-step instructions.

echo ""
echo "=== Project setup complete ==="
echo ""
echo "Next steps:"
echo "  1. Visit ${PROJECT_URL} to verify the project"
echo "  2. Manually create the 'Iteration' field (requires UI — 2-week iterations)"
echo "     See MANUAL-FOLLOWUP-GUIDE.md for detailed instructions."
echo "  3. Manually create the project views (Backlog, Sprint Board, etc.)"
echo "     (Views require the UI — gh CLI cannot create project views)"
echo "  4. Run 02-create-issues-epics-1-4.sh to populate issues"
echo ""
echo "  Custom fields created: 8 of 9"
echo "  Custom fields requiring manual creation: 1 (Iteration)"
