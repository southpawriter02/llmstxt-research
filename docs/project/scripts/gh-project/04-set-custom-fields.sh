#!/usr/bin/env bash
# ==============================================================================
# 04-set-custom-fields.sh
# Sets custom field values on every project item:
#   - Epic (single-select)
#   - Story Points (number)
#   - Phase (single-select)
#   - Target Week (number, where applicable)
#   - Lane (single-select) — NEW in v2.0
#   - Lane Phase (single-select) — NEW in v2.0
#
# This script must be run AFTER the issue creation scripts (02-* and 03-*)
# have completed and the project is populated.
#
# HOW IT WORKS:
# 1. Reads the project number from .project-number (created by 01-*)
# 2. Discovers the field IDs for each custom field via `gh project field-list`
# 3. Discovers the option IDs for single-select fields
# 4. Lists all project items and matches them to issues by title substring
# 5. Sets the appropriate field values on each matched item
#
# v2.0 changes:
#   - Title patterns updated to match [L{lane}-E{epic}] naming convention
#   - Lane and Lane Phase fields added to every item
#   - Story 2.5a (Extension Labeling Audit) included
#   - Total items: 51 (7 epics + 44 stories)
#
# USAGE:
#   chmod +x 04-set-custom-fields.sh
#   ./04-set-custom-fields.sh
#
# PREREQUISITES:
#   - 01-create-project.sh has been run (.project-number exists)
#   - 02-create-issues-epics-1-4.sh has been run
#   - 03-create-issues-epics-5-7.sh has been run
#   - gh CLI authenticated with `project` scope
#
# NOTE: Each item-edit call is a separate API call. There is a 1-second delay
# between calls to avoid rate limiting. Total runtime: ~8–12 minutes
# (51 items × 6 fields = ~306 API calls).
# ==============================================================================

set -euo pipefail

OWNER="southpawriter02"

# ---------------------------------------------------------------------------
# Step 0: Read project number
# ---------------------------------------------------------------------------
if [ -f .project-number ]; then
  PROJECT_NUMBER=$(cat .project-number)
else
  echo "ERROR: .project-number not found. Run 01-create-project.sh first."
  exit 1
fi

echo "=== Setting Custom Fields on Project #${PROJECT_NUMBER} (v2.0) ==="
echo ""

# ---------------------------------------------------------------------------
# Step 1: Discover field IDs
# ---------------------------------------------------------------------------
echo "--- Discovering field IDs ---"

FIELDS_JSON=$(gh project field-list "$PROJECT_NUMBER" \
  --owner "@me" \
  --format json 2>/dev/null)

# Extract field IDs by name
EPIC_FIELD_ID=$(echo "$FIELDS_JSON" | jq -r '.fields[] | select(.name == "Epic") | .id')
POINTS_FIELD_ID=$(echo "$FIELDS_JSON" | jq -r '.fields[] | select(.name == "Story Points") | .id')
PHASE_FIELD_ID=$(echo "$FIELDS_JSON" | jq -r '.fields[] | select(.name == "Phase") | .id')
TARGET_WEEK_FIELD_ID=$(echo "$FIELDS_JSON" | jq -r '.fields[] | select(.name == "Target Week") | .id')
LANE_FIELD_ID=$(echo "$FIELDS_JSON" | jq -r '.fields[] | select(.name == "Lane") | .id')
LANE_PHASE_FIELD_ID=$(echo "$FIELDS_JSON" | jq -r '.fields[] | select(.name == "Lane Phase") | .id')

# Verify we found all required fields
for field_name in "Epic" "Story Points" "Phase" "Target Week" "Lane" "Lane Phase"; do
  case "$field_name" in
    "Epic")         fid="$EPIC_FIELD_ID" ;;
    "Story Points") fid="$POINTS_FIELD_ID" ;;
    "Phase")        fid="$PHASE_FIELD_ID" ;;
    "Target Week")  fid="$TARGET_WEEK_FIELD_ID" ;;
    "Lane")         fid="$LANE_FIELD_ID" ;;
    "Lane Phase")   fid="$LANE_PHASE_FIELD_ID" ;;
  esac
  if [ -z "$fid" ] || [ "$fid" = "null" ]; then
    echo "ERROR: Could not find field ID for '${field_name}'."
    echo "       Make sure 01-create-project.sh created the custom fields."
    exit 1
  fi
  echo "  [OK] ${field_name} → ${fid}"
done

# ---------------------------------------------------------------------------
# Step 2: Discover option IDs for single-select fields
# ---------------------------------------------------------------------------
echo ""
echo "--- Discovering single-select option IDs ---"

# Helper: get option ID by field name and option name
get_option_id() {
  local field_name="$1"
  local option_name="$2"
  echo "$FIELDS_JSON" | jq -r --arg fname "$field_name" --arg oname "$option_name" \
    '.fields[] | select(.name == $fname) | .options[]? | select(.name == $oname) | .id'
}

# Epic options (7 epics)
EPIC_PAPER_ID=$(get_option_id "Epic" "Paper")
EPIC_DOCSTRATUM_ID=$(get_option_id "Epic" "DocStratum")
EPIC_LLMSTXTKIT_ID=$(get_option_id "Epic" "LlmsTxtKit")
EPIC_BENCHMARK_ID=$(get_option_id "Epic" "Benchmark")
EPIC_BLOG_ID=$(get_option_id "Epic" "Blog Series")
EPIC_DOGFOODING_ID=$(get_option_id "Epic" "Blog Dogfooding")
EPIC_INFRA_ID=$(get_option_id "Epic" "Infrastructure")

# Phase options (5 phases)
PHASE_0_ID=$(get_option_id "Phase" "Phase 0 (Setup)")
PHASE_1_ID=$(get_option_id "Phase" "Phase 1 (Foundations)")
PHASE_2_ID=$(get_option_id "Phase" "Phase 2 (Implementation)")
PHASE_3_ID=$(get_option_id "Phase" "Phase 3 (Experimentation)")
PHASE_4_ID=$(get_option_id "Phase" "Phase 4 (Synthesis)")

# Lane options (6 lanes)
LANE_PAPER_ID=$(get_option_id "Lane" "Paper")
LANE_TOOLKIT_ID=$(get_option_id "Lane" "LlmsTxtKit")
LANE_VALIDATOR_ID=$(get_option_id "Lane" "DocStratum")
LANE_BENCHMARK_ID=$(get_option_id "Lane" "Benchmark")
LANE_BLOG_ID=$(get_option_id "Lane" "Blog & Content")
LANE_CROSSCUT_ID=$(get_option_id "Lane" "Cross-Cutting")

# Lane Phase options (16 phases)
LP_GATHER_ID=$(get_option_id "Lane Phase" "Gather")
LP_ANALYZE_ID=$(get_option_id "Lane Phase" "Analyze")
LP_WRITE_ID=$(get_option_id "Lane Phase" "Write")
LP_REVIEW_ID=$(get_option_id "Lane Phase" "Review")
LP_SPEC_ID=$(get_option_id "Lane Phase" "Spec")
LP_BUILD_ID=$(get_option_id "Lane Phase" "Build")
LP_TEST_ID=$(get_option_id "Lane Phase" "Test")
LP_SHIP_ID=$(get_option_id "Lane Phase" "Ship")
LP_DESIGN_ID=$(get_option_id "Lane Phase" "Design")
LP_COLLECT_ID=$(get_option_id "Lane Phase" "Collect")
LP_RUN_ID=$(get_option_id "Lane Phase" "Run")
LP_CALIBRATE_ID=$(get_option_id "Lane Phase" "Calibrate")
LP_POST_ID=$(get_option_id "Lane Phase" "Post")
LP_INFRA_ID=$(get_option_id "Lane Phase" "Infra")
LP_SETUP_ID=$(get_option_id "Lane Phase" "Setup")
LP_ONGOING_ID=$(get_option_id "Lane Phase" "Ongoing")

echo "  Epic options discovered: 7"
echo "  Phase options discovered: 5"
echo "  Lane options discovered: 6"
echo "  Lane Phase options discovered: 16"

# ---------------------------------------------------------------------------
# Step 3: List all project items
# ---------------------------------------------------------------------------
echo ""
echo "--- Listing project items ---"

ITEMS_JSON=$(gh project item-list "$PROJECT_NUMBER" \
  --owner "@me" \
  --format json \
  --limit 100 2>/dev/null)

ITEM_COUNT=$(echo "$ITEMS_JSON" | jq '.items | length')
echo "  Found ${ITEM_COUNT} items in the project."

if [ "$ITEM_COUNT" -eq 0 ]; then
  echo "ERROR: No items found. Run 02-* and 03-* scripts first."
  exit 1
fi

# ---------------------------------------------------------------------------
# Step 4: Helper function to set ALL fields on a project item
#
# set_fields <title_pattern> <epic_option_id> <points> <phase_option_id> \
#            <lane_option_id> <lane_phase_option_id> [target_week]
#
# Finds the project item whose title contains <title_pattern>, then sets
# the Epic, Story Points, Phase, Lane, Lane Phase, and optionally Target Week.
# ---------------------------------------------------------------------------
set_fields() {
  local title_pattern="$1"
  local epic_option_id="$2"
  local points="$3"
  local phase_option_id="$4"
  local lane_option_id="$5"
  local lane_phase_option_id="$6"
  local target_week="${7:-}"

  # Find the item ID by matching the title pattern
  local item_id
  item_id=$(echo "$ITEMS_JSON" | jq -r --arg pat "$title_pattern" \
    '.items[] | select(.title | contains($pat)) | .id' | head -1)

  if [ -z "$item_id" ] || [ "$item_id" = "null" ]; then
    echo "  [!] NOT FOUND: ${title_pattern}"
    return 1
  fi

  # Set Epic (single-select)
  gh project item-edit \
    --project-id "$PROJECT_NUMBER" \
    --owner "@me" \
    --id "$item_id" \
    --field-id "$EPIC_FIELD_ID" \
    --single-select-option-id "$epic_option_id" \
    2>/dev/null || echo "    (Epic field failed)"

  # Set Story Points (number)
  gh project item-edit \
    --project-id "$PROJECT_NUMBER" \
    --owner "@me" \
    --id "$item_id" \
    --field-id "$POINTS_FIELD_ID" \
    --number "$points" \
    2>/dev/null || echo "    (Points field failed)"

  # Set Phase (single-select)
  gh project item-edit \
    --project-id "$PROJECT_NUMBER" \
    --owner "@me" \
    --id "$item_id" \
    --field-id "$PHASE_FIELD_ID" \
    --single-select-option-id "$phase_option_id" \
    2>/dev/null || echo "    (Phase field failed)"

  # Set Lane (single-select) — NEW in v2.0
  gh project item-edit \
    --project-id "$PROJECT_NUMBER" \
    --owner "@me" \
    --id "$item_id" \
    --field-id "$LANE_FIELD_ID" \
    --single-select-option-id "$lane_option_id" \
    2>/dev/null || echo "    (Lane field failed)"

  # Set Lane Phase (single-select) — NEW in v2.0
  gh project item-edit \
    --project-id "$PROJECT_NUMBER" \
    --owner "@me" \
    --id "$item_id" \
    --field-id "$LANE_PHASE_FIELD_ID" \
    --single-select-option-id "$lane_phase_option_id" \
    2>/dev/null || echo "    (Lane Phase field failed)"

  # Set Target Week (number) — only if provided
  if [ -n "$target_week" ]; then
    gh project item-edit \
      --project-id "$PROJECT_NUMBER" \
      --owner "@me" \
      --id "$item_id" \
      --field-id "$TARGET_WEEK_FIELD_ID" \
      --number "$target_week" \
      2>/dev/null || echo "    (Target Week field failed)"
  fi

  echo "  [+] ${title_pattern}"
  sleep 1  # Rate limit
}

# ---------------------------------------------------------------------------
# Step 5: Set fields on ALL 51 issues
#
# Title patterns match the v2.0 naming convention:
#   Epics:   "[EPIC] {Name}"
#   Stories: "[L{lane}-E{epic}] {Name}"
#
# Arguments: title_pattern  epic_id  points  phase_id  lane_id  lane_phase_id  [target_week]
# ---------------------------------------------------------------------------

echo ""
echo "================================================================"
echo "  LANE 1: Research Paper (Epic 1)"
echo "================================================================"

#                          title_pattern                                     epic_id          pts  phase_id     lane_id          lane_phase_id   week
set_fields '[EPIC] Analytical Paper'                                        "$EPIC_PAPER_ID"  49  "$PHASE_1_ID" "$LANE_PAPER_ID" "$LP_GATHER_ID"  1
set_fields '[L1-E1] Research Consolidation and Evidence Gathering'          "$EPIC_PAPER_ID"   8  "$PHASE_1_ID" "$LANE_PAPER_ID" "$LP_GATHER_ID"  1
set_fields '[L1-E1] Paper Outline and Structure'                            "$EPIC_PAPER_ID"   5  "$PHASE_1_ID" "$LANE_PAPER_ID" "$LP_ANALYZE_ID" 1
set_fields '[L1-E1] First Draft'                                            "$EPIC_PAPER_ID"  13  "$PHASE_1_ID" "$LANE_PAPER_ID" "$LP_WRITE_ID"   3
set_fields '[L1-E1] Review, Revision, and Data Verification'               "$EPIC_PAPER_ID"  13  "$PHASE_2_ID" "$LANE_PAPER_ID" "$LP_REVIEW_ID"  5
set_fields '[L1-E1] Paper Publication'                                      "$EPIC_PAPER_ID"   5  "$PHASE_3_ID" "$LANE_PAPER_ID" "$LP_REVIEW_ID"  9
set_fields '[L1-E1] Benchmark-Informed Revision'                            "$EPIC_PAPER_ID"   5  "$PHASE_4_ID" "$LANE_PAPER_ID" "$LP_REVIEW_ID"  15

echo ""
echo "================================================================"
echo "  LANE 2: LlmsTxtKit (Epic 3)"
echo "================================================================"

set_fields '[EPIC] LlmsTxtKit'                                             "$EPIC_LLMSTXTKIT_ID"  63  "$PHASE_1_ID" "$LANE_TOOLKIT_ID" "$LP_SPEC_ID"   3
set_fields '[L2-E3] Complete Specification Documents'                       "$EPIC_LLMSTXTKIT_ID"   8  "$PHASE_1_ID" "$LANE_TOOLKIT_ID" "$LP_SPEC_ID"   3
set_fields '[L2-E3] Implement Parser and Fetcher'                           "$EPIC_LLMSTXTKIT_ID"  13  "$PHASE_2_ID" "$LANE_TOOLKIT_ID" "$LP_BUILD_ID"  5
set_fields '[L2-E3] Implement Validator, Cache, and Context Generator'      "$EPIC_LLMSTXTKIT_ID"  13  "$PHASE_2_ID" "$LANE_TOOLKIT_ID" "$LP_BUILD_ID"  7
set_fields '[L2-E3] Implement MCP Server'                                   "$EPIC_LLMSTXTKIT_ID"   8  "$PHASE_2_ID" "$LANE_TOOLKIT_ID" "$LP_BUILD_ID"  9
set_fields '[L2-E3] Integration Testing'                                    "$EPIC_LLMSTXTKIT_ID"   8  "$PHASE_2_ID" "$LANE_TOOLKIT_ID" "$LP_TEST_ID"   11
set_fields '[L2-E3] Packaging, Documentation, and Release'                  "$EPIC_LLMSTXTKIT_ID"   8  "$PHASE_3_ID" "$LANE_TOOLKIT_ID" "$LP_SHIP_ID"   13
set_fields '[L2-E3] Post-Release Bug Fixes from Benchmark Usage'            "$EPIC_LLMSTXTKIT_ID"   5  "$PHASE_3_ID" "$LANE_TOOLKIT_ID" "$LP_SHIP_ID"   15

echo ""
echo "================================================================"
echo "  LANE 3: DocStratum Validator (Epic 2)"
echo "================================================================"

set_fields '[EPIC] DocStratum Validator'                                    "$EPIC_DOCSTRATUM_ID"  84  "$PHASE_1_ID" "$LANE_VALIDATOR_ID" "$LP_DESIGN_ID"

# Stories 2.1–2.5a: Design backlog (no specific target weeks — assign during sprint planning)
set_fields '[L3-E2] Output Tier Specification'                              "$EPIC_DOCSTRATUM_ID"   8  "$PHASE_1_ID" "$LANE_VALIDATOR_ID" "$LP_DESIGN_ID"
set_fields '[L3-E2] Remediation Framework'                                  "$EPIC_DOCSTRATUM_ID"   8  "$PHASE_1_ID" "$LANE_VALIDATOR_ID" "$LP_DESIGN_ID"
set_fields '[L3-E2] Unified Rule Registry'                                  "$EPIC_DOCSTRATUM_ID"   8  "$PHASE_1_ID" "$LANE_VALIDATOR_ID" "$LP_DESIGN_ID"
set_fields '[L3-E2] Validation Profiles'                                    "$EPIC_DOCSTRATUM_ID"   8  "$PHASE_1_ID" "$LANE_VALIDATOR_ID" "$LP_DESIGN_ID"
set_fields '[L3-E2] Report Generation'                                      "$EPIC_DOCSTRATUM_ID"  13  "$PHASE_1_ID" "$LANE_VALIDATOR_ID" "$LP_DESIGN_ID"
set_fields '[L3-E2] Extension Labeling Audit'                               "$EPIC_DOCSTRATUM_ID"   5  "$PHASE_1_ID" "$LANE_VALIDATOR_ID" "$LP_DESIGN_ID"

# Stories 2.6–2.8: Implementation
set_fields '[L3-E2] Implement L0-L1'                                        "$EPIC_DOCSTRATUM_ID"  13  "$PHASE_2_ID" "$LANE_VALIDATOR_ID" "$LP_BUILD_ID"
set_fields '[L3-E2] Implement L2-L3'                                        "$EPIC_DOCSTRATUM_ID"  13  "$PHASE_2_ID" "$LANE_VALIDATOR_ID" "$LP_BUILD_ID"
set_fields '[L3-E2] Quality Scoring and CLI'                                "$EPIC_DOCSTRATUM_ID"  13  "$PHASE_3_ID" "$LANE_VALIDATOR_ID" "$LP_BUILD_ID"

echo ""
echo "================================================================"
echo "  LANE 4: Benchmark (Epic 4)"
echo "================================================================"

set_fields '[EPIC] Empirical Benchmark'                                     "$EPIC_BENCHMARK_ID"  60  "$PHASE_2_ID" "$LANE_BENCHMARK_ID" "$LP_DESIGN_ID"  3
set_fields '[L4-E4] Corpus Selection and Question Authoring'                "$EPIC_BENCHMARK_ID"  13  "$PHASE_2_ID" "$LANE_BENCHMARK_ID" "$LP_DESIGN_ID"  3
set_fields '[L4-E4] Methodology Specification and Review'                   "$EPIC_BENCHMARK_ID"   8  "$PHASE_2_ID" "$LANE_BENCHMARK_ID" "$LP_DESIGN_ID"  5
set_fields '[L4-E4] Data Collection Infrastructure'                         "$EPIC_BENCHMARK_ID"   8  "$PHASE_2_ID" "$LANE_BENCHMARK_ID" "$LP_COLLECT_ID" 7
set_fields '[L4-E4] Data Collection and Scoring'                            "$EPIC_BENCHMARK_ID"  13  "$PHASE_3_ID" "$LANE_BENCHMARK_ID" "$LP_RUN_ID"     9
set_fields '[L4-E4] Analysis Notebook and Write-Up'                         "$EPIC_BENCHMARK_ID"  13  "$PHASE_3_ID" "$LANE_BENCHMARK_ID" "$LP_ANALYZE_ID" 12
set_fields '[L4-E4] Benchmark Publication'                                  "$EPIC_BENCHMARK_ID"   5  "$PHASE_4_ID" "$LANE_BENCHMARK_ID" "$LP_ANALYZE_ID" 15

echo ""
echo "================================================================"
echo "  LANE 5: Blog & Content (Epics 5, 6)"
echo "================================================================"

# Epic 5: Blog Series
set_fields '[EPIC] Blog Series'                                             "$EPIC_BLOG_ID"  49  "$PHASE_1_ID" "$LANE_BLOG_ID" "$LP_POST_ID"    1
set_fields '[L5-E5] Blog Post 1'                                            "$EPIC_BLOG_ID"   5  "$PHASE_1_ID" "$LANE_BLOG_ID" "$LP_POST_ID"    1
set_fields '[L5-E5] Blog Post 2'                                            "$EPIC_BLOG_ID"   5  "$PHASE_1_ID" "$LANE_BLOG_ID" "$LP_POST_ID"    4
set_fields '[L5-E5] Blog Post 3'                                            "$EPIC_BLOG_ID"   5  "$PHASE_2_ID" "$LANE_BLOG_ID" "$LP_POST_ID"    6
set_fields '[L5-E5] Blog Post 4'                                            "$EPIC_BLOG_ID"   8  "$PHASE_2_ID" "$LANE_BLOG_ID" "$LP_POST_ID"    8
set_fields '[L5-E5] Blog Post 5'                                            "$EPIC_BLOG_ID"   8  "$PHASE_3_ID" "$LANE_BLOG_ID" "$LP_POST_ID"    10
set_fields '[L5-E5] Blog Post 6'                                            "$EPIC_BLOG_ID"   5  "$PHASE_4_ID" "$LANE_BLOG_ID" "$LP_POST_ID"    14
set_fields '[L5-E5] Blog Post 7'                                            "$EPIC_BLOG_ID"   5  "$PHASE_3_ID" "$LANE_BLOG_ID" "$LP_POST_ID"    12
set_fields '[L5-E5] Blog Post 8'                                            "$EPIC_BLOG_ID"   8  "$PHASE_4_ID" "$LANE_BLOG_ID" "$LP_POST_ID"    16

# Epic 6: Blog Dogfooding
set_fields '[EPIC] Blog llms.txt Dogfooding'                                "$EPIC_DOGFOODING_ID"  13  "$PHASE_1_ID" "$LANE_BLOG_ID" "$LP_DESIGN_ID"
set_fields '[L5-E6] Baseline Validation'                                    "$EPIC_DOGFOODING_ID"   3  "$PHASE_1_ID" "$LANE_BLOG_ID" "$LP_DESIGN_ID"
set_fields '[L5-E6] Validation Rule Field Testing'                          "$EPIC_DOGFOODING_ID"   5  "$PHASE_2_ID" "$LANE_BLOG_ID" "$LP_TEST_ID"
set_fields '[L5-E6] LLM Consumption Observation'                            "$EPIC_DOGFOODING_ID"   5  "$PHASE_3_ID" "$LANE_BLOG_ID" "$LP_DESIGN_ID"

echo ""
echo "================================================================"
echo "  LANE 6: Cross-Cutting (Epic 7)"
echo "================================================================"

set_fields '[EPIC] Cross-Cutting Infrastructure'                            "$EPIC_INFRA_ID"  26  "$PHASE_0_ID" "$LANE_CROSSCUT_ID" "$LP_SETUP_ID"
set_fields '[L6-E7] GitHub Project Setup'                                   "$EPIC_INFRA_ID"   5  "$PHASE_0_ID" "$LANE_CROSSCUT_ID" "$LP_SETUP_ID"
set_fields '[L6-E7] Repository Label Standardization'                       "$EPIC_INFRA_ID"   3  "$PHASE_0_ID" "$LANE_CROSSCUT_ID" "$LP_SETUP_ID"
set_fields '[L6-E7] Issue Population from Blueprint'                        "$EPIC_INFRA_ID"   8  "$PHASE_0_ID" "$LANE_CROSSCUT_ID" "$LP_SETUP_ID"
set_fields '[L6-E7] CI/CD Pipeline Setup'                                   "$EPIC_INFRA_ID"   5  "$PHASE_1_ID" "$LANE_CROSSCUT_ID" "$LP_SETUP_ID"
set_fields '[L6-E7] Shared Research Artifacts'                              "$EPIC_INFRA_ID"   5  "$PHASE_1_ID" "$LANE_CROSSCUT_ID" "$LP_ONGOING_ID"

# ---------------------------------------------------------------------------
# Summary
# ---------------------------------------------------------------------------
echo ""
echo "=== Custom field assignment complete (v2.0) ==="
echo ""
echo "All 51 issues should now have Epic, Story Points, Phase, Lane, and"
echo "Lane Phase values set. Target Week was set where the blueprint specifies one."
echo ""
echo "NEXT STEPS:"
echo "  1. Open the project: https://github.com/users/${OWNER}/projects/${PROJECT_NUMBER}"
echo "  2. Verify a few items have their fields set correctly"
echo "  3. Create the project views (see MANUAL-FOLLOWUP-GUIDE.md)"
echo "  4. Set up the Iteration field (requires UI)"
echo "  5. Populate Blocked By cross-references (see MANUAL-FOLLOWUP-GUIDE.md)"
echo ""
