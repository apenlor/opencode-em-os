---
name: log-one-on-one
description: >
  Log the outcomes of a completed 1:1 meeting. Records topics, commitments, and
  signals in a structured per-person history file. Triggers: "log my 1:1 with",
  "record 1:1", "save 1:1 notes", "log 1:1", or any request to capture 1:1 outcomes.
---

# Skill: Log 1:1

You help an Engineering Manager capture the outcomes of a completed 1:1 in a consistent, structured format. Your job is to ask the right questions, then write a clean entry to the person's history file.

---

## Phase 1 — Identify the team member

1. Extract the name from the user's input.
2. Look up `data/teams/*/team.md` to find the matching member, their nickname, and their team folder.
3. Set the log file path: `data/teams/{team}/one-on-ones/{nickname}.md`.

If the member is not found in any team file, ask the user to confirm the team folder and nickname to use.

---

## Phase 2 — Review pending commitments

1. If `data/teams/{team}/one-on-ones/{nickname}.md` exists, read it.
2. Find all unchecked commitments (`- [ ]`) from the **most recent entry**.
3. If there are pending commitments, present them one by one and ask:
   - "Done", "In progress", or "Dropped"?
   - If done, ask the date (default: today).
   - If dropped, ask for a brief reason (optional).

Mark resolved commitments as `[x]` with the date. Mark dropped ones as `[-]` with an optional note.

If no pending commitments exist, skip this phase silently.

---

## Phase 3 — Gather this session's content

Ask these questions sequentially. Keep them short and conversational.

**Q1 — Topics**
> "What did you discuss in this 1:1?"

Accept freeform input. Convert into a short bulleted list (one line per topic, no headers).

**Q2 — New commitments**
> "Any commitments made — by you or by them?"

For each commitment, ask who owns it: "you (me)" or "them". Tag accordingly: `(me)` or `(them)`.

If none, skip.

**Q3 — Signals**

Ask about each signal with a choice:

> "How would you rate their **engagement**?"
> → Options: `low` | `moderate` | `high` | `improving` | `declining`

> "How was their **energy** in this conversation?"
> → Options: `low` | `moderate` | `high`

> "What's the current **risk** level for this person?"
> → Options: `none` | `low` | `moderate` | `high`

**Q4 — Notes**
> "Anything else worth capturing? (optional)"

Accept freeform. Keep as 1–3 sentences. If the user says nothing, omit the Notes section.

---

## Phase 4 — Write the entry

Compose the entry using today's date and append it to `data/teams/{team}/one-on-ones/{nickname}.md`.

**Entry format:**

```markdown
## YYYY-MM-DD

### Topics
- [topic]
- [topic]

### Commitments
- [ ] [commitment] (them|me)

### Signals
- Engagement: [value]
- Energy: [value]
- Risk: [value]

### Notes
[freeform, 1–3 sentences — omit section if empty]
```

**Placement rules:**
- If the file exists: insert the new entry **at the top**, after the file header comment block.
- If the file does not exist: create it with the header and the entry. Ensure the directory `data/teams/{team}/one-on-ones/` exists.

**File header (new files only):**
```markdown
# 1:1 Log: {nickname}

<!--
  One file per team member. Entries are appended by the log-one-on-one skill.
  Most recent entry first. Do not edit manually unless correcting a mistake.
-->
```

Also update any resolved/dropped commitments in the **previous entry** in place (mark `[ ]` → `[x]` or `[-]`).

---

## Phase 5 — Confirm

Show the composed entry and ask the user to confirm before writing.

> "Here's the entry I'll save. Confirm or edit anything."

Do not write to disk until confirmed.

---

## Phase 6 — Output after saving

Confirm what was saved with a one-line summary:

> "1:1 log entry for {nickname} saved — {date}. {N} open commitments remain."

---

## Rules

- Always use today's date unless the user specifies otherwise
- Never invent or assume topics, commitments, or signals — only record what the user tells you
- Keep topics terse — one line each, no paragraphs
- Do not editorialize in the Notes section — capture what happened, not your interpretation
- If the user skips a section, omit it cleanly (no empty headers)
