---
name: jira
description: >
  Jira skill for creating, querying, and updating issues across any Jira project.
  Triggers: "create an epic", "create a bug", "show me bugs", "epics in progress",
  "issues completed", "bugs due in N days", or any Jira request.
  Also triggers when other skills (e.g. write-us, write-epic-build) reach a Jira
  confirmation step.
---

# Skill: Jira

## Project Resolution

**Before any Jira operation**, identify the target project:

1. If the user specified a project name or key, use it.
2. If not, list the files in `data/jira/` — each file represents one configured project.
   Ask: *"Which Jira project? Available: [list filenames without extension]"*
3. Read `data/jira/<project>.md` to get the project's **Project Key**, **Base URL**, **Cloud ID**,
   custom fields, and defaults.
4. Use those values for all CLI commands in this conversation. Do not ask again.

If `data/jira/` is empty or missing, ask the user to create a config file:
*"No Jira projects configured yet. Copy `data/jira/example.md` to `data/jira/<yourproject>.md`
and fill in the project key, base URL, and cloud ID."*

---

## Tool usage

**Always prefer the `jira` CLI.** Only fall back to MCP (`searchJiraIssuesUsingJql`,
`createJiraIssue`, etc.) if the CLI is not available or a specific operation is not
supported by it.

### Jira CLI quick reference

```bash
# Search / query
jira issue list -p {project_key} --jql "<JQL>"

# Create issue
jira issue create -p {project_key} -t <IssueType> -s "<summary>" [flags]

# View issue
jira issue view <ISSUE-KEY>
```

Where `{project_key}` is the value read from the project's config file in `data/jira/`.

---

## A. Querying issues

Identify the query intent and build the appropriate JQL. Always scope to `project = {project_key}`.

### Common queries

| User request | JQL |
|---|---|
| Epics in progress | `project = {project_key} AND issuetype = Epic AND status = "In Progress" ORDER BY updated DESC` |
| Bugs open / in progress | `project = {project_key} AND issuetype = Bug AND status != Done ORDER BY priority ASC, duedate ASC` |
| Issues completed last N days | `project = {project_key} AND status = Done AND resolutiondate >= -Nd ORDER BY resolutiondate DESC` |
| Issues of type X in status Y | `project = {project_key} AND issuetype = X AND status = "Y" ORDER BY updated DESC` |
| Bugs due in ≤ N days | `project = {project_key} AND issuetype = Bug AND duedate <= Nd AND status != Done ORDER BY duedate ASC` |
| All open issues | `project = {project_key} AND status != Done ORDER BY updated DESC` |

### Output format for queries

Show results as a markdown table with columns:
`Key | Type | Summary | Status | Priority | Due Date | Assignee`

Omit columns that are empty for all results. Include a total count at the end.

---

## B. Creating issues

### Step 1 — Determine issue type

If not stated, ask. Options: **Epic, Story, Bug, Task, Sub-task**.

### Step 2 — Gather required fields by type

#### Epic
| Field | Required | Notes |
|---|---|---|
| Summary | Yes | Concise title |
| Description | Recommended | Context and goals |
| Start Date | Ask | `customfield_10015` (YYYY-MM-DD) |
| Due Date | Ask | `duedate` (YYYY-MM-DD) |
| Parent | No | Epics are top-level by default |

#### Story
| Field | Required | Notes |
|---|---|---|
| Summary | Yes | Concise title, start with verb |
| Description | Yes | Use Story format (see §C) |
| Parent Epic | Ask | Query recent epics if not given; allow null |

#### Bug
| Field | Required | Notes |
|---|---|---|
| Summary | Yes | Describe the defect clearly |
| Description | Yes | Steps to reproduce, expected vs actual |
| Priority | Ask | Default Medium; consider High/Critical if user hints urgency |
| Due Date | Ask | Especially relevant for bugs |
| Parent Epic | Ask | Optional |

#### Task
| Field | Required | Notes |
|---|---|---|
| Summary | Yes | Action-oriented title |
| Description | Recommended | What needs to be done and why |
| Parent | Ask | Can be Epic or Story |

#### Sub-task
| Field | Required | Notes |
|---|---|---|
| Summary | Yes | |
| Description | Recommended | |
| Parent | **Required** | Must have a parent issue key |

### Step 3 — Draft and confirm

Present the issue draft before creating. Ask the user to confirm or edit.

**Do not create in Jira until explicit confirmation.**

### Step 4 — Create via CLI

**Always try the CLI first.** Do not skip to MCP because the description is long or
structured — use `--body` or pass the description via stdin. Only fall back to MCP if
the CLI command fails or explicitly does not support a required field.

```bash
jira issue create \
  -p {project_key} \
  -t "<IssueType>" \
  -s "<summary>" \
  [--priority "Medium"] \
  [--custom "duedate=YYYY-MM-DD"] \
  [--parent "<PARENT-KEY>"]
```

If CLI flags don't support a field, fall back to `createJiraIssue` MCP with:

```json
{
  "cloudId": "{cloud_id}",
  "projectKey": "{project_key}",
  "issueType": "<IssueType>",
  "summary": "<summary>",
  "description": "<ADF description>",
  "priority": "Medium",
  "duedate": "YYYY-MM-DD",
  "parent": { "key": "<PARENT-KEY>" }
}
```

> **ADF note**: When using MCP, description must be in Atlassian Document Format (`type: "doc"`).
> Use level-2 headings for sections and paragraphs for content.

### Step 5 — Output after creation

Share:
- Direct link: `https://{base_url}/browse/{project_key}-XXXX`
- Brief summary: type, title, parent (if any), due date (if set)

---

## General rules

- Always scope queries to `project = {project_key}` — never query without the project filter
- Never invent issue keys, user IDs, or field values
- If a field value is unknown, ask — don't guess
- If the user says "N days", substitute the number directly into the JQL (e.g. `-7d`)
- For date fields use ISO format: `YYYY-MM-DD`
- `{project_key}`, `{cloud_id}`, `{base_url}` refer to values read from the project config file
