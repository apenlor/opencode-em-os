---
description: Analyze an engineer's activity metrics from Jira and GitHub
agent: manager
---

Analyze the IC activity for: $ARGUMENTS

## Instructions

1. Parse the arguments to extract the team member name and optional date range.
2. Look up the member's `github_username`, `jira_email`, and `github_org` from `data/teams/*/team.md` files.
   - `github_org` is optional — only set if the team file defines it. Leave empty for public repos.
3. Resolve dates using these rules:
   - No date specified → last 14 days (FROM = today - 14, TO = today)
   - "last 14 days" → FROM = today - 14, TO = today
   - "last month" → FROM = first day of previous month, TO = last day of previous month
   - "February 2026" → FROM = 2026-02-01, TO = 2026-02-28
   - "this week" → FROM = Monday of current week, TO = today
4. Run the script:

```
bash .opencode/scripts/run_ic_activity.sh <github_username> <jira_email> <from_date> <to_date> [github_org]
```

   Omit `github_org` if the team file does not define it (public repos).

5. Analyze the returned JSON metrics using this scoring logic:

### Scoring

**Delivery** (single metric):
- `del_issues_per_week`: High >= 6 | Medium 3-5 | Low < 3

**Focus** (single metric):
- `foc_wip_count`: High <= 2 | Medium 3-4 | Low > 4
- Special: `foc_wip_count = 0` is a red flag (work not tracked in Jira)

**Quality** (average of three metrics, round down):
- `qua_avg_pr_size`: High < 500 | Medium 500-1000 | Low > 1000
- `qua_comments_per_pr`: High < 6 | Medium 6-12 | Low > 12
- `qua_prs_cancelled` as % of total merged (`qua_prs_cancelled / del_prs_merged`): High = 0% | Medium 1-10% | Low > 10%
  - If `del_prs_merged = 0`, skip this sub-metric

**Collaboration** (average of two metrics, round down):
- `col_reviews_per_week`: High >= 8 | Medium 4-8 | Low < 4
- `col_avg_time_to_first_review_as_reviewer_hours`: High < 24h | Medium 24-48h | Low > 48h

### Anomaly Detection

Before writing the Summary, check for these contradictions and flag any that apply:

- `del_issues_completed > 0` AND `del_prs_merged == 0` → "Work completed in Jira but no PRs merged — is code review being bypassed?"
- `del_prs_merged > 0` AND `del_issues_completed == 0` → "PRs merged but no Jira issues completed — is work being tracked?"
- `col_reviews == 0` → "No reviews given in the period — not participating in code review"
- `del_pr_cycle_time_days` > 2x `del_issue_cycle_time_days` (when both non-null) → "PR cycle time significantly exceeds issue cycle time — possible review bottleneck"
- `del_issue_cycle_time_days` > 2x `del_pr_cycle_time_days` (when both non-null) → "Issue cycle time significantly exceeds PR cycle time — possible process overhead or handoff delay"
- `foc_wip_count == 0` → "No work in progress — either everything is done or Jira tracking is incomplete"

Only show the Flags section if at least one anomaly is detected.

6. Output the report in this exact format:

```
IC Activity Report (FROM to TO)

Delivery
- X issues completed (~X.X issues/week)
  - X Stories, X Tasks, X Bugs, X Sub-tasks, ...
- Issue cycle time: Xd
- Y PRs merged (~Y.Y PRs/week) — +X / -X LOC
- PR cycle time: Xd
- Score: High | Medium | Low

Current Focus
- Issues in progress (WIP): X
- Open PRs: X
- Score: High | Medium | Low

Quality
- Avg PR size: X LOC
- Comments per PR: X
- Cancelled PRs: X
- Score: High | Medium | Low

Collaboration
- Reviews given: X (~X.X/week)
- Avg time to first review as reviewer: Xh
- Score: High | Medium | Low

Flags (only if anomalies detected)
- List any triggered anomaly flags here

Summary
- 2-3 concise insights about behavior and patterns

Recommendations
- 2-4 actionable, practical suggestions
```

## Style

- Be concise and direct (engineering manager tone)
- Prefer interpretation over raw data repetition
- Highlight trade-offs, not just metrics
- Do not hallucinate missing data

## Example Summary (style reference)

- Consistent delivery with solid throughput
- Slightly high parallel work impacting focus
- Good collaboration habits, responsive to feedback

## Example Recommendations (style reference)

- Reduce WIP to improve cycle time
- Aim for smaller PRs to lower rework
- Maintain strong review participation
