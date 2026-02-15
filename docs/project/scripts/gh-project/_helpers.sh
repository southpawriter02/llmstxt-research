#!/usr/bin/env bash
# ==============================================================================
# _helpers.sh
# Shared functions for issue creation scripts. Sourced by 02-* and 03-*.
#
# Provides:
#   create_issue <repo> <title> <body> <labels_csv> [milestone]
#     Creates a GitHub issue, adds it to the project, prints the issue URL.
#
#   add_to_project <issue_url>
#     Adds an existing issue to the GitHub Project.
#
# v2.0 NAMING CONVENTION:
#   Epics:   [EPIC] {Epic Name}
#   Stories: [L{lane}-E{epic}] {Story Name}
#   Tasks:   [L{lane}-S{story}] {Task Name}   (when created as separate issues)
#
# LANE MAPPING:
#   Lane 1 (Paper)      → lane:paper     → Epic 1
#   Lane 2 (Toolkit)    → lane:toolkit   → Epic 3
#   Lane 3 (Validator)  → lane:validator  → Epic 2
#   Lane 4 (Benchmark)  → lane:benchmark → Epic 4
#   Lane 5 (Blog)       → lane:blog      → Epics 5, 6
#   Lane 6 (Cross-Cut)  → lane:crosscut  → Epic 7
# ==============================================================================

OWNER="southpawriter02"

# Read project number from the file created by 01-create-project.sh
if [ -f .project-number ]; then
  PROJECT_NUMBER=$(cat .project-number)
else
  echo "ERROR: .project-number not found. Run 01-create-project.sh first."
  exit 1
fi

# Associative array to store issue URLs by story ID (for dependency linking)
declare -A ISSUE_URLS

# ---------------------------------------------------------------------------
# create_issue <repo> <title> <body> <labels_csv> [milestone]
#
# Creates an issue in the specified repo with the given title, body, and labels.
# Adds it to the project. Stores the URL keyed by the title prefix (e.g., [L1-E1]).
# ---------------------------------------------------------------------------
create_issue() {
  local repo="${OWNER}/$1"
  local title="$2"
  local body="$3"
  local labels="$4"
  local milestone="${5:-}"

  local cmd=(gh issue create
    --repo "$repo"
    --title "$title"
    --body "$body"
    --label "$labels"
  )

  if [ -n "$milestone" ]; then
    cmd+=(--milestone "$milestone")
  fi

  local issue_url
  issue_url=$("${cmd[@]}" 2>&1)

  if [ $? -ne 0 ]; then
    echo "  [!] FAILED to create: ${title}"
    echo "      Error: ${issue_url}"
    return 1
  fi

  echo "  [+] ${title}"
  echo "      ${issue_url}"

  # Add to project
  gh project item-add "$PROJECT_NUMBER" \
    --owner "@me" \
    --url "$issue_url" \
    2>/dev/null || echo "      (could not add to project)"

  # Store URL for dependency linking
  # Extract the key from the title, e.g., "[EPIC]" or "[L1-E1]"
  local key
  key=$(echo "$title" | grep -oE '^\[[^]]+\]' || echo "$title")
  ISSUE_URLS["$key"]="$issue_url"

  # Small delay to avoid rate limiting
  sleep 1
}

# ---------------------------------------------------------------------------
# Heredoc helper: trims leading whitespace from heredoc bodies so the
# script remains readable while producing clean issue bodies.
# ---------------------------------------------------------------------------
trim_body() {
  sed 's/^    //'
}
