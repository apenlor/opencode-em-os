#!/usr/bin/env bash

set -euo pipefail

# --- Parameter check ---
if [[ $# -lt 4 ]] || [[ $# -gt 5 ]]; then
	echo "Usage: $0 <github_username> <jira_email> <from_date:YYYY-MM-DD> <to_date:YYYY-MM-DD> [github_org]" >&2
	echo "" >&2
	echo "  github_org  Optional. Required for private org repos." >&2
	echo "              Public repos work without it." >&2
	echo "" >&2
	echo "Example: $0 octocat user@company.com 2026-03-01 2026-03-31" >&2
	echo "Example: $0 icores-sngular isaac.cores@sngular.com 2026-03-01 2026-03-31 driver8soft" >&2
	exit 1
fi

GITHUB_USER=$1
JIRA_EMAIL_USER=$2
FROM=$3
TO=$4
GITHUB_ORG=${5:-}

# --- Date validation and timestamp computation ---
date_regex='^[0-9]{4}-[0-9]{2}-[0-9]{2}$'
if [[ ! "$FROM" =~ $date_regex ]] || [[ ! "$TO" =~ $date_regex ]]; then
	echo "Error: Dates must be in YYYY-MM-DD format." >&2
	exit 1
fi

if date -v-1d +"%Y-%m-%d" &>/dev/null 2>&1; then
	# macOS
	FROM_TS=$(date -j -f "%Y-%m-%d" "$FROM" +%s 2>/dev/null) || {
		echo "Error: Invalid FROM date '$FROM'" >&2
		exit 1
	}
	TO_TS=$(date -j -f "%Y-%m-%d" "$TO" +%s 2>/dev/null) || {
		echo "Error: Invalid TO date '$TO'" >&2
		exit 1
	}
else
	# Linux
	FROM_TS=$(date -d "$FROM" +%s 2>/dev/null) || {
		echo "Error: Invalid FROM date '$FROM'" >&2
		exit 1
	}
	TO_TS=$(date -d "$TO" +%s 2>/dev/null) || {
		echo "Error: Invalid TO date '$TO'" >&2
		exit 1
	}
fi

if [[ "$FROM_TS" -gt "$TO_TS" ]]; then
	echo "Error: FROM date ($FROM) is after TO date ($TO)." >&2
	exit 1
fi

DAYS=$(((TO_TS - FROM_TS) / 86400 + 1))

# --- Load Jira credentials ---
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
ENV_FILE="$SCRIPT_DIR/../../.env.local"
if [[ -f "$ENV_FILE" ]]; then
	# shellcheck disable=SC1090
	source "$ENV_FILE"
fi
export JIRA_API_TOKEN="${JIRA_API_TOKEN:-}"

# --- Validate GitHub CLI authentication ---
if ! gh auth status &>/dev/null; then
	echo "Error: GitHub CLI is not authenticated. Run 'gh auth login' first." >&2
	exit 1
fi

# --- Validate required Jira env vars ---
for var in JIRA_API_TOKEN JIRA_EMAIL JIRA_URL; do
	if [[ -z "${!var:-}" ]]; then
		echo "Error: $var is not set. Check your .env.local file." >&2
		exit 1
	fi
done

TS=$(date +%s)
OUT_DIR="/tmp/ic_activity_${GITHUB_USER}_${TS}"
mkdir -p "$OUT_DIR"
trap 'rm -rf "$OUT_DIR"' EXIT

# --- Helper: paginated Jira search via REST API ---
# Usage: jira_search <jql> <fields> <expand> <out_file>
# Pass empty string for expand if not needed.
jira_search() {
	local jql="$1"
	local fields="$2"
	local expand="${3:-}"
	local out_file="$4"
	local all_issues="[]"
	local next_token=""
	local is_last="false"

	while [[ "$is_last" != "true" ]]; do
		local url_params=(
			--data-urlencode "jql=${jql}"
			--data-urlencode "maxResults=100"
			--data-urlencode "fields=${fields}"
		)
		[[ -n "$expand" ]] && url_params+=(--data-urlencode "expand=${expand}")
		[[ -n "$next_token" ]] && url_params+=(--data-urlencode "nextPageToken=${next_token}")

		local http_code
		local tmp_response="$OUT_DIR/.jira_response_$$"
		http_code=$(curl -s -G -o "$tmp_response" -w '%{http_code}' \
			-u "${JIRA_EMAIL}:${JIRA_API_TOKEN}" \
			"${JIRA_URL}/rest/api/3/search/jql" \
			"${url_params[@]}" 2>/dev/null) || {
			echo "Warning: Jira API request failed (curl error)" >&2
			echo "[]" >"$out_file"
			rm -f "$tmp_response"
			return
		}

		if [[ "$http_code" -lt 200 ]] || [[ "$http_code" -ge 300 ]]; then
			echo "Warning: Jira API returned HTTP $http_code" >&2
			cat "$tmp_response" >&2 2>/dev/null
			echo "[]" >"$out_file"
			rm -f "$tmp_response"
			return
		fi

		local response
		response=$(cat "$tmp_response")
		rm -f "$tmp_response"

		if ! echo "$response" | jq -e '.issues' >/dev/null 2>&1; then
			echo "[]" >"$out_file"
			return
		fi

		local page_issues
		page_issues=$(echo "$response" | jq '.issues')
		all_issues=$(jq -n --argjson existing "$all_issues" --argjson new "$page_issues" '$existing + $new')
		is_last=$(echo "$response" | jq -r '.isLast // "true"')
		next_token=$(echo "$response" | jq -r '.nextPageToken // empty')
	done

	echo "$all_issues" >"$out_file"
}

# --- Helper: fetch single merged PR detail ---
fetch_pr_detail() {
	local repo="$1" number="$2" out_dir="$3"
	local safe_repo="${repo//\//_}"
	local out_file="$out_dir/pr_details/${safe_repo}_${number}.json"
	local res
	if res=$(gh api "repos/$repo/pulls/$number" 2>/dev/null); then
		echo "$res" | jq '{additions, deletions, comments, review_comments, created_at, merged_at, pr_author: .user.login}' >"$out_file" 2>/dev/null || true
	fi
}
export -f fetch_pr_detail

# --- Helper: fetch reviewed PR detail and reviews ---
fetch_reviewed_pr() {
	local repo="$1" number="$2" out_dir="$3" github_user="$4"
	local safe_repo="${repo//\//_}"
	local out_detail="$out_dir/reviewed_pr_details/${safe_repo}_${number}.json"
	local out_reviews="$out_dir/reviewed_pr_reviews/${safe_repo}_${number}.json"
	local res
	if res=$(gh api "repos/$repo/pulls/$number" 2>/dev/null); then
		echo "$res" | jq '{created_at, pr_author: .user.login}' >"$out_detail" 2>/dev/null || true
		gh api "repos/$repo/pulls/$number/reviews" \
			--jq "[.[] | select(.user.login == \"$github_user\" and .state != \"PENDING\")]" \
			>"$out_reviews" 2>/dev/null || true
	fi
}
export -f fetch_reviewed_pr

# Build optional --owner flag for gh search (required for private org repos)
GH_OWNER_FLAG=()
if [[ -n "$GITHUB_ORG" ]]; then
	GH_OWNER_FLAG=(--owner "$GITHUB_ORG")
fi

# --- GitHub PRs merged ---
gh search prs \
	--author "$GITHUB_USER" \
	--merged \
	--merged-at "$FROM..$TO" \
	--limit 200 \
	--json number,createdAt,closedAt,title,repository \
	"${GH_OWNER_FLAG[@]}" \
	>"$OUT_DIR/prs.json"

# --- GitHub PRs closed (not merged) ---
gh search prs \
	--author "$GITHUB_USER" \
	--state closed \
	--closed "$FROM..$TO" \
	--limit 200 \
	--json number,repository,state \
	"${GH_OWNER_FLAG[@]}" \
	>"$OUT_DIR/prs_closed.json"

# --- GitHub PRs open ---
gh search prs \
	--author "$GITHUB_USER" \
	--state open \
	--limit 200 \
	--json number \
	"${GH_OWNER_FLAG[@]}" \
	>"$OUT_DIR/prs_open.json"

# --- GitHub Reviews given ---
gh search prs \
	--reviewed-by "$GITHUB_USER" \
	--updated "$FROM..$TO" \
	--limit 200 \
	--json number,repository \
	"${GH_OWNER_FLAG[@]}" \
	>"$OUT_DIR/reviews.json"

# --- GitHub Commits ---
gh search commits \
	--author "$GITHUB_USER" \
	--committer-date "$FROM..$TO" \
	--limit 200 \
	--json commit \
	"${GH_OWNER_FLAG[@]}" \
	>"$OUT_DIR/commits.json"

# --- Jira issues completed (with changelog for cycle time) ---
jira_search \
	"assignee = \"${JIRA_EMAIL_USER}\" AND status = Done AND resolved >= \"${FROM}\" AND resolved <= \"${TO}\" AND issuetype != Epic" \
	"status,issuetype,resolutiondate,summary" \
	"changelog" \
	"$OUT_DIR/issues.json"

# --- Jira issues in progress (WIP) ---
jira_search \
	"assignee = \"${JIRA_EMAIL_USER}\" AND status = 'In Progress' AND issuetype != Epic" \
	"status,issuetype,summary" \
	"" \
	"$OUT_DIR/issues_wip.json"

# --- Metrics ---
PRS=$(jq length "$OUT_DIR/prs.json")
COMMITS=$(jq length "$OUT_DIR/commits.json")
ISSUES=$(jq 'if type == "array" then length else 0 end' "$OUT_DIR/issues.json")

# issues by type
ISSUES_BY_TYPE=$(jq '
  if type == "array" then
    group_by(.fields.issuetype.name)
    | map({ (.[0].fields.issuetype.name): length })
    | add // {}
  else {} end
' "$OUT_DIR/issues.json")

# wip_count: issues currently in progress
WIP=$(jq 'if type == "array" then length else 0 end' "$OUT_DIR/issues_wip.json")

# open_prs: PRs currently open
OPEN_PRS=$(jq length "$OUT_DIR/prs_open.json")

# prs_cancelled: closed PRs minus merged PRs
PRS_CLOSED_TOTAL=$(jq 'length' "$OUT_DIR/prs_closed.json")
PRS_CANCELLED=$((PRS_CLOSED_TOTAL - PRS))

# --- Issue cycle time: In Progress → Done from inline changelog ---
ISSUE_CYCLE_TIME_DAYS=$(
	jq '
    def parse_jira_date: gsub("\\.[0-9]+"; "") | gsub("([+-][0-9]{2}):?([0-9]{2})$"; "Z") | fromdateiso8601;
    [ .[] | select(.changelog != null) |
      .changelog.histories as $hist |
      {
        in_progress: ([$hist[] | select(.items[] | .field == "status" and .toString == "In Progress")] | first | .created // null),
        done:        ([$hist[] | select(.items[] | .field == "status" and .toString == "Done")]        | last  | .created // null)
      } |
      select(.in_progress != null and .done != null) |
      ((.done | parse_jira_date) - (.in_progress | parse_jira_date)) / 86400
    ] |
    if length > 0 then add / length | . * 10 | round / 10 else null end
  ' "$OUT_DIR/issues.json"
)

# --- Per-PR details via API (size, comments, cycle time) — parallelized ---
mkdir -p "$OUT_DIR/pr_details"
jq -r '.[] | .repository.nameWithOwner + " " + (.number | tostring)' "$OUT_DIR/prs.json" |
	xargs -P 8 -L 1 bash -c 'fetch_pr_detail "$1" "$2" "'"$OUT_DIR"'"' _

# aggregate PR details
PR_DETAILS_AGG=$(
	find "$OUT_DIR/pr_details" -name '*.json' -exec cat {} \; 2>/dev/null |
		jq -s '
    if length == 0 then
      { avg_pr_size: null, total_loc_additions: null, total_loc_deletions: null, comments_per_pr: null, pr_cycle_time_days: null }
    else
      {
        avg_pr_size: (map(.additions + .deletions) | add / length | . * 10 | round / 10),
        total_loc_additions: (map(.additions) | add),
        total_loc_deletions: (map(.deletions) | add),
        comments_per_pr: (map(.comments + .review_comments) | add / length | . * 10 | round / 10),
        pr_cycle_time_days: (
          map(
            select(.merged_at != null) |
            ((.merged_at | fromdateiso8601) - (.created_at | fromdateiso8601)) / 86400
          ) | if length > 0 then add / length | . * 10 | round / 10 else null end
        )
      }
    end
  '
)

AVG_PR_SIZE=$(echo "$PR_DETAILS_AGG" | jq '.avg_pr_size')
TOTAL_LOC_ADDITIONS=$(echo "$PR_DETAILS_AGG" | jq '.total_loc_additions')
TOTAL_LOC_DELETIONS=$(echo "$PR_DETAILS_AGG" | jq '.total_loc_deletions')
COMMENTS_PER_PR=$(echo "$PR_DETAILS_AGG" | jq '.comments_per_pr')
PR_CYCLE_TIME_DAYS=$(echo "$PR_DETAILS_AGG" | jq '.pr_cycle_time_days')

# --- Reviewed PR details and reviews (parallelized) ---
mkdir -p "$OUT_DIR/reviewed_pr_details" "$OUT_DIR/reviewed_pr_reviews"
jq -r '.[] | .repository.nameWithOwner + " " + (.number | tostring)' "$OUT_DIR/reviews.json" |
	xargs -P 8 -L 1 bash -c 'fetch_reviewed_pr "$1" "$2" "'"$OUT_DIR"'" "'"$GITHUB_USER"'"' _

# Review count and avg review time — both exclude self-reviews
REVIEWS=0
for f in "$OUT_DIR/reviewed_pr_details"/*.json; do
	[ -f "$f" ] || continue
	author=$(jq -r '.pr_author // ""' "$f")
	[[ "$author" != "$GITHUB_USER" ]] && REVIEWS=$((REVIEWS + 1))
done

AVG_TIME_TO_FIRST_REVIEW=$(
	for f in "$OUT_DIR/reviewed_pr_details"/*.json; do
		[ -f "$f" ] || continue
		filename=$(basename "$f" .json)
		reviews_file="$OUT_DIR/reviewed_pr_reviews/${filename}.json"
		[ -f "$reviews_file" ] || continue
		author=$(jq -r '.pr_author // ""' "$f")
		[[ "$author" == "$GITHUB_USER" ]] && continue
		jq -n \
			--slurpfile detail "$f" \
			--slurpfile reviews "$reviews_file" \
			'{
        created_at: $detail[0].created_at,
        first_review: (if ($reviews[0] | type) == "array" then $reviews[0] | sort_by(.submitted_at) | first else null end)
      }'
	done | jq -s '
    [ .[] | select(.first_review != null) |
      ((.first_review.submitted_at | fromdateiso8601) - (.created_at | fromdateiso8601)) / 3600
    ] |
    if length > 0 then add / length * 10 | round / 10 else null end
  '
)

# commits_per_pr
COMMITS_PER_PR=$(awk "BEGIN {if ($PRS > 0) printf \"%.1f\", $COMMITS/$PRS; else print \"null\"}")

# per-week metrics
ISSUES_PER_WEEK=$(awk "BEGIN {printf \"%.2f\", $ISSUES / $DAYS * 7}")
PRS_PER_WEEK=$(awk "BEGIN {printf \"%.2f\", $PRS / $DAYS * 7}")
REVIEWS_PER_WEEK=$(awk "BEGIN {printf \"%.2f\", $REVIEWS / $DAYS * 7}")

jq -n \
	--argjson col_avg_time "$AVG_TIME_TO_FIRST_REVIEW" \
	--argjson col_reviews "$REVIEWS" \
	--argjson col_reviews_per_week "$REVIEWS_PER_WEEK" \
	--argjson del_pr_cycle_time "$PR_CYCLE_TIME_DAYS" \
	--argjson del_commits "$COMMITS" \
	--argjson del_commits_per_pr "$COMMITS_PER_PR" \
	--argjson del_issues_by_type "$ISSUES_BY_TYPE" \
	--argjson del_issue_cycle_time "$ISSUE_CYCLE_TIME_DAYS" \
	--argjson del_issues_completed "$ISSUES" \
	--argjson del_issues_per_week "$ISSUES_PER_WEEK" \
	--argjson del_prs_merged "$PRS" \
	--argjson del_prs_per_week "$PRS_PER_WEEK" \
	--argjson del_total_loc_additions "$TOTAL_LOC_ADDITIONS" \
	--argjson del_total_loc_deletions "$TOTAL_LOC_DELETIONS" \
	--argjson foc_open_prs "$OPEN_PRS" \
	--argjson foc_wip_count "$WIP" \
	--argjson period_days "$DAYS" \
	--argjson qua_avg_pr_size "$AVG_PR_SIZE" \
	--argjson qua_comments_per_pr "$COMMENTS_PER_PR" \
	--argjson qua_prs_cancelled "$PRS_CANCELLED" \
	'{
    col_avg_time_to_first_review_as_reviewer_hours: $col_avg_time,
    col_reviews: $col_reviews,
    col_reviews_per_week: $col_reviews_per_week,
    del_pr_cycle_time_days: $del_pr_cycle_time,
    del_commits: $del_commits,
    del_commits_per_pr: $del_commits_per_pr,
    del_issues_by_type: $del_issues_by_type,
    del_issue_cycle_time_days: $del_issue_cycle_time,
    del_issues_completed: $del_issues_completed,
    del_issues_per_week: $del_issues_per_week,
    del_prs_merged: $del_prs_merged,
    del_prs_per_week: $del_prs_per_week,
    del_total_loc_additions: $del_total_loc_additions,
    del_total_loc_deletions: $del_total_loc_deletions,
    foc_open_prs: $foc_open_prs,
    foc_wip_count: $foc_wip_count,
    period_days: $period_days,
    qua_avg_pr_size: $qua_avg_pr_size,
    qua_comments_per_pr: $qua_comments_per_pr,
    qua_prs_cancelled: $qua_prs_cancelled
  }'
