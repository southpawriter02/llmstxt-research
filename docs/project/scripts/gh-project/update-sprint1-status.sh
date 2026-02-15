#!/usr/bin/env bash
# ==============================================================================
# update-sprint1-status.sh
# Updates the Status field on Sprint 1 items in the GitHub Project.
#
# This script sets the built-in "Status" field (which GitHub Projects V2
# creates by default) on issues that have been completed or are in progress.
#
# STATUS VALUES (GitHub Projects default):
#   - "Todo"        — not started
#   - "In Progress" — actively being worked on
#   - "Done"        — completed
#
# WHAT THIS UPDATES (as of February 15, 2026):
#
# DONE:
#   [L6-E7] GitHub Project Setup               — Project created, fields configured
#   [L6-E7] Repository Label Standardization    — Labels applied via script
#   [L6-E7] Issue Population from Blueprint     — 51 issues created via script
#   [L1-E1] Research Consolidation and Evidence  — Evidence inventory v2.0 complete
#     Gathering                                    (49 claims, 33 verified, 12 new refs)
#
# IN PROGRESS:
#   [L6-E7] Shared Research Artifacts           — ~70% done (references.md expanded
#                                                  13→27 sources, glossary current,
#                                                  remaining work is ongoing maintenance)
#   [L3-E2] Extension Labeling Audit            — Sprint 1, not yet started but
#                                                  next in queue (marking Todo)
#
# USAGE:
#   chmod +x update-sprint1-status.sh
#   ./update-sprint1-status.sh
#
# PREREQUISITES:
#   - gh CLI authenticated with `project` scope
#   - jq installed
#   - The project exists and has issues populated
# ==============================================================================

set -euo pipefail

OWNER="southpawriter02"

# ---------------------------------------------------------------------------
# Step 0: Find the project number
# ---------------------------------------------------------------------------
echo "=== Updating Sprint 1 Status ==="
echo ""

# Try reading from .project-number first (if run from the scripts directory)
if [ -f .project-number ]; then
  PROJECT_NUMBER=$(cat .project-number)
  echo "Found project number from .project-number: ${PROJECT_NUMBER}"
elif [ -f "$(dirname "$0")/.project-number" ]; then
  PROJECT_NUMBER=$(cat "$(dirname "$0")/.project-number")
  echo "Found project number from script directory: ${PROJECT_NUMBER}"
else
  echo "No .project-number file found. Discovering project..."
  # List projects and find ours by title
  PROJECT_NUMBER=$(gh project list --owner "@me" --format json 2>/dev/null \
    | jq -r '.projects[] | select(.title == "llms.txt Research & Tooling Initiative") | .number' \
    | head -1)

  if [ -z "$PROJECT_NUMBER" ] || [ "$PROJECT_NUMBER" = "null" ]; then
    echo "ERROR: Could not find project 'llms.txt Research & Tooling Initiative'."
    echo "       Please create a .project-number file with the project number."
    exit 1
  fi
  echo "Discovered project number: ${PROJECT_NUMBER}"
fi

echo ""

# ---------------------------------------------------------------------------
# Step 1: Discover the Status field ID and option IDs
# ---------------------------------------------------------------------------
echo "--- Discovering Status field ---"

FIELDS_JSON=$(gh project field-list "$PROJECT_NUMBER" \
  --owner "@me" \
  --format json 2>/dev/null)

STATUS_FIELD_ID=$(echo "$FIELDS_JSON" | jq -r '.fields[] | select(.name == "Status") | .id')

if [ -z "$STATUS_FIELD_ID" ] || [ "$STATUS_FIELD_ID" = "null" ]; then
  echo "ERROR: Could not find Status field."
  exit 1
fi

echo "  Status field ID: ${STATUS_FIELD_ID}"

# Get option IDs for each status value
STATUS_TODO_ID=$(echo "$FIELDS_JSON" | jq -r \
  '.fields[] | select(.name == "Status") | .options[]? | select(.name == "Todo") | .id')
STATUS_INPROGRESS_ID=$(echo "$FIELDS_JSON" | jq -r \
  '.fields[] | select(.name == "Status") | .options[]? | select(.name == "In Progress") | .id')
STATUS_DONE_ID=$(echo "$FIELDS_JSON" | jq -r \
  '.fields[] | select(.name == "Status") | .options[]? | select(.name == "Done") | .id')

echo "  Todo option ID:        ${STATUS_TODO_ID}"
echo "  In Progress option ID: ${STATUS_INPROGRESS_ID}"
echo "  Done option ID:        ${STATUS_DONE_ID}"

# Verify we have all three
for opt_name in "Todo" "In Progress" "Done"; do
  case "$opt_name" in
    "Todo")        oid="$STATUS_TODO_ID" ;;
    "In Progress") oid="$STATUS_INPROGRESS_ID" ;;
    "Done")        oid="$STATUS_DONE_ID" ;;
  esac
  if [ -z "$oid" ] || [ "$oid" = "null" ]; then
    echo ""
    echo "WARNING: Could not find Status option '${opt_name}'."
    echo "         Your project may use different status names."
    echo "         Available options:"
    echo "$FIELDS_JSON" | jq -r '.fields[] | select(.name == "Status") | .options[]? | "  - \(.name) (\(.id))"'
    echo ""
    echo "If your status names differ, edit the STATUS_*_ID variables above."
    exit 1
  fi
done

echo ""

# ---------------------------------------------------------------------------
# Step 2: List all project items
# ---------------------------------------------------------------------------
echo "--- Loading project items ---"

ITEMS_JSON=$(gh project item-list "$PROJECT_NUMBER" \
  --owner "@me" \
  --format json \
  --limit 100 2>/dev/null)

ITEM_COUNT=$(echo "$ITEMS_JSON" | jq '.items | length')
echo "  Found ${ITEM_COUNT} items."
echo ""

# ---------------------------------------------------------------------------
# Step 3: Helper function to set status on an item by title
# ---------------------------------------------------------------------------
set_status() {
  local title_pattern="$1"
  local status_option_id="$2"
  local status_label="$3"

  # Find the item ID by matching the title pattern
  local item_id
  item_id=$(echo "$ITEMS_JSON" | jq -r --arg pat "$title_pattern" \
    '.items[] | select(.title | contains($pat)) | .id' | head -1)

  if [ -z "$item_id" ] || [ "$item_id" = "null" ]; then
    echo "  [!] NOT FOUND: ${title_pattern}"
    return 1
  fi

  gh project item-edit \
    --project-id "$PROJECT_NUMBER" \
    --owner "@me" \
    --id "$item_id" \
    --field-id "$STATUS_FIELD_ID" \
    --single-select-option-id "$status_option_id" \
    2>/dev/null

  echo "  [${status_label}] ${title_pattern}"
  sleep 1  # Rate limit
}

# ---------------------------------------------------------------------------
# Step 4: Update statuses
# ---------------------------------------------------------------------------

echo "=== MARKING DONE ==="
echo ""

# Sprint 1 items that are DONE:
set_status "[L6-E7] GitHub Project Setup"                                  "$STATUS_DONE_ID" "DONE"
set_status "[L6-E7] Repository Label Standardization"                      "$STATUS_DONE_ID" "DONE"
set_status "[L6-E7] Issue Population from Blueprint"                       "$STATUS_DONE_ID" "DONE"
set_status "[L1-E1] Research Consolidation and Evidence Gathering"         "$STATUS_DONE_ID" "DONE"

echo ""
echo "=== MARKING IN PROGRESS ==="
echo ""

# Sprint 1 items that are IN PROGRESS:
set_status "[L6-E7] Shared Research Artifacts"                             "$STATUS_INPROGRESS_ID" "IN PROGRESS"

echo ""
echo "=== STATUS UPDATE COMPLETE ==="
echo ""
echo "Summary:"
echo "  4 items → Done"
echo "  1 item  → In Progress"
echo ""
echo "Remaining Sprint 1 items (still Todo):"
echo "  - [L3-E2] Extension Labeling Audit"
echo "  - [L5-E5] Blog Post 1"
echo "  - [L1-E1] Paper Outline and Structure"
echo ""
echo "View project: https://github.com/users/${OWNER}/projects/${PROJECT_NUMBER}"
