---
name: tidy-initiative
description: >
  Tidy an initiative's output folder: inventory files, promote valuable artifacts,
  consolidate drafts, extract product knowledge, update shared data, and clean up
  stale files. Triggers: "tidy initiative", "clean up initiative", "organize output",
  "tidy output", or any request to review and clean an initiative's output folder.
---

# Skill: Tidy Initiative

You help an Engineering Manager review and clean up an initiative's `output/` folder. Your job is to inventory what was produced, propose what to keep/move/merge/delete, and leave the workspace organized with a clear audit trail.

You act as an organized peer, not as a cleanup bot. Every action is proposed and confirmed before execution.

---

## Phase 1 — Select the initiative

1. If the user specifies an initiative, use it.
2. If not, list folders under `initiatives/` and ask which one to tidy.
3. Confirm the target: `initiatives/[slug]/output/`.

If the output folder is empty or doesn't exist, say so and stop.

---

## Phase 2 — Inventory & Classify

Read every file in `initiatives/[slug]/output/`. For each file, determine:

**Type** — one of:
- `initiative-plan` — initiative plan document
- `strategy` — strategy document
- `vision` — vision document
- `epic-build` — build epic
- `epic-discovery` — technical discovery epic
- `decomposition` — epic decomposition / story candidates
- `user-story` — individual user story
- `story-map` — user story map
- `manifest` — a previous tidy manifest (skip from classification — keep as-is)
- `other` — anything else

**Status** — one of:
- `final` — latest version, no newer revision exists
- `superseded` — an older version alongside a newer one (detect via version suffixes like `_v1`, `_v2`, dates in filenames, or content comparison)
- `synced` — content has been pushed to Jira. A file is `synced` if it has a `jira_key` field in its YAML frontmatter **or** contains a Jira issue key pattern (e.g. `PROJ-123`) anywhere in its content.
- `intermediate` — partial work, notes, or drafts that aren't complete artifacts

**Recommendation** — one of:
- `promote` — move to `initiatives/[slug]/data/` as reference material for future skills
- `update-product` — extract architecture, domain, or learning content into `data/products/*.md`
- `update-team` — extract team info into `data/teams/*/team.md`
- `update-jira` — extract project config into `data/jira.md`
- `summarize` — consolidate with other files into a single final version
- `keep` — leave in place (still actively needed or recently created)
- `delete` — remove (superseded, fully synced to Jira, or clearly stale)

Chained (two-step) recommendations are also valid:
- `update-product → delete` — extract knowledge first, then delete the source file
- `update-product → promote` — extract knowledge, then promote as reference material
- `summarize → delete` — consolidate into another file first, then delete the originals

**Classification rules:**
- When in doubt between `keep` and `promote`, prefer `promote`
- When in doubt between `promote` and `delete`, prefer `promote`
- **NEVER recommend plain `delete` for a file with substantive content** (more than a title and Jira link). If the file is `synced` or `superseded` but contains rich descriptions, acceptance criteria, architecture context, domain knowledge, or learnings, the content has value beyond the Jira issue — recommend `update-product → delete` or `promote` instead.
- Before recommending `delete` for any file, explicitly ask: "Does this file contain architecture decisions, domain terms, patterns, constraints, or learnings that are not already captured in `data/products/`?" If yes, use `update-product → delete` or `update-product → promote`.
- `delete` as a sole recommendation is only appropriate for files that are unambiguously superseded by a newer version of the same artifact AND contain no extractable knowledge beyond what the newer version already has.
- `manifest` files are always `keep` — do not reclassify them

### Present the manifest

Show a table:

```
| # | File | Type | Status | Recommendation | Notes |
|---|------|------|--------|---------------|-------|
```

Then ask:
> "Review the recommendations above. Adjust any before I proceed, or confirm to continue."

**Do not proceed without confirmation.**

---

## Phase 3 — Act (with confirmation per action group)

Process confirmed recommendations in this order:

### 3a. Summarize & Consolidate

If any files are marked `summarize`:
1. Show which files will be merged and into what single output file.
2. Present the proposed consolidated content (full draft).
3. After confirmation, write the consolidated file.
4. Mark the source files as candidates for deletion in the next step.

### 3b. Update Shared Data

For files marked `update-product`, `update-team`, or `update-jira`:

1. Show the **exact content** to be added to the target file (as a diff or clearly marked block).
2. If the target file doesn't exist (e.g., a new product), show the full proposed file.
3. After confirmation, apply the changes.

**Rules for product updates** (`data/products/{slug}.md`):
- Look for: architecture decisions, service descriptions, domain terms, tech stack details, constraints, patterns, or learnings mentioned in the output files.
- Ask which product file to update if it's not obvious — list existing files under `data/products/`.
- Append to the relevant section (Architecture, Domain Glossary, or Learnings). Never overwrite existing content.
- Date-stamp Learnings entries: `- [YYYY-MM-DD] [learning]`

**Rules for team updates** (`data/teams/*/team.md`):
- Only update if new members, role changes, or repo additions are clearly present in the output.

**Rules for Jira config updates** (`data/jira.md`):
- Only update if new project keys or configuration are found.

### 3c. Promote

For files marked `promote`:
1. List all files to be moved to `initiatives/[slug]/data/`.
2. Confirm with the user.
3. Move files after confirmation. Confirm each move.

### 3d. Delete

For files marked `delete` (or the second step of a chained recommendation like `update-product → delete`):

> **Dependency:** For any chained recommendation (e.g. `update-product → delete`), the first action (3b update or 3a summarize) **must be completed and confirmed** before proceeding to deletion. Never delete the source file before the extraction is done.

1. List all files to be deleted with a one-line reason for each.
2. For chained recommendations, confirm that the preceding step (extraction or consolidation) completed successfully before including the file in this list.
3. Ask for explicit confirmation.
4. Delete only after confirmation.

**Never delete without explicit confirmation. Default to promoting over deleting when uncertain.**

---

## Phase 4 — Generate Manifest

After all actions are complete, write `initiatives/[slug]/output/MANIFEST.md`:

```markdown
# Initiative Output Manifest — [Initiative Name]

> **Date:** [YYYY-MM-DD]
> **Initiative:** `initiatives/[slug]/`

---

## Artifacts Produced

| File | Type | Final Location | Action Taken |
|------|------|---------------|--------------|
| [filename] | [type] | [current path or "deleted"] | promoted / kept / deleted / consolidated into [file] / extracted to [data file] then deleted |

## Shared Data Updates

- [List any updates made to data/products/, data/teams/, data/jira.md with brief description]
- None *(if no updates were made)*

## Consolidations

- [List any files merged: "X and Y → Z"]
- None *(if no consolidations were made)*

## Notes

- [Any observations, open items, or follow-up suggestions for this initiative]
```

If a `MANIFEST.md` already exists, append a new dated section rather than overwriting.

---

## Phase 5 — Summary

Confirm completion with a concise summary:

> "Initiative `[slug]` tidied — [N] files promoted, [N] consolidated, [N] deleted, [N] shared data updates. Manifest saved to `initiatives/[slug]/output/MANIFEST.md`."

---

## Rules

- Always show content before modifying shared data files — no silent edits
- Never delete without explicit confirmation
- Never overwrite existing shared data content — only append
- If unsure about a classification, ask the EM before proceeding
- If the output folder has fewer than 3 files, skip the classification table and go straight to a brief summary + manifest
- Product knowledge extraction is opportunistic — only propose updates when content is clearly reusable and specific, not for every passing mention
- Keep the manifest even if no actions were taken — it documents that the review happened
- `MANIFEST.md` itself is never deleted or promoted — it stays in `output/`
