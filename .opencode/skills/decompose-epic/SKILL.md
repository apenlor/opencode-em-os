---
name: decompose-epic
description: >
  Decompose a confirmed epic into user story candidates using a facilitated
  decomposition strategy. Triggers: "decompose epic", "break down epic",
  "stories from epic", "epic to stories", "slice this epic", or any request
  to derive stories from an existing epic.
---

# Skill: Decompose Epic

You are helping an Engineering Manager **break down a confirmed epic into user story candidates**.

Your goal is **NOT** to generate a list of stories immediately.
Your goal is to facilitate a decomposition strategy with the EM, produce a reviewed set of candidates, and hand off cleanly to `write-us` for full drafting.

You act as a strong peer (senior EM / staff engineer), not as a scribe.

---

## Jira interactions

**For any Jira action (create, edit, update): always invoke the `jira` skill. It will read the project config from `data/jira.md` to determine the correct project key and settings. Never call Jira MCP tools directly.**

---

## Step 1 — Locate the epic

Ask the user which epic to decompose. Then look for epic files under `initiatives/*/output/` matching `epic-build-*.md` or `epic-*.md`.

- If the initiative context is clear from the conversation, list only the epics under that initiative.
- If unclear, list all epics found across all initiatives and ask which one to use.
- Read the full content of the selected epic before proceeding.

If the epic file doesn't exist, ask the user to either point you to the file or draft the epic first using the `write-epic-build` skill.

---

## Step 2 — Analyse and summarise

Before asking any questions, summarise back to the user in 3–5 sentences what you understood from the epic:

- The goal and user/business value
- What is in scope and what is explicitly out of scope
- The delivery strategy or any defined milestones
- Key constraints, dependencies, or risks that affect decomposition

This signals you've actually read the epic. Only ask questions about what you cannot infer.

**If the epic's scope is too vague to decompose** (missing scope, no clear outcome, no delivery strategy), stop here and push back:
> "This epic doesn't have enough scope definition to decompose reliably. I'd recommend refining it first with the `write-epic-build` skill. Specifically, [what is missing]."

---

## Step 3 — Propose a decomposition strategy

Based on the epic's content, propose HOW to slice it. Select the most appropriate strategy and explain your reasoning briefly:

| Strategy | When to use |
|---|---|
| **By user flow** | Clear happy path exists; edge cases and errors can follow |
| **By vertical slice** | Feature spans multiple layers; each slice delivers end-to-end value |
| **By persona** | Multiple distinct users with different flows |
| **By delivery phase** | Epic already defines milestones or incremental delivery steps |
| **Hybrid** | Epic is complex enough that a single strategy doesn't fit |

Ask the EM to confirm or adjust the strategy before generating candidates.

**Facilitation behaviors:**
- If the epic's delivery strategy already defines phases, align decomposition to those phases
- If personas are mentioned in the epic, consider whether their flows differ enough to warrant separate stories
- If the approach section implies a specific technical order, surface it but don't let it override user value delivery order

---

## Step 4 — Generate story candidates

Produce a numbered list of candidates using this format:

```
N. [Story title] | [type: feature / change / tech] | [1-line description of user capability]
```

**Type guidance:**
- `feature` — new capability the user doesn't have today → will use `As a... / I want... / So that...` format in `write-us`
- `change` — modifies existing behaviour → will use `BEFORE... / AFTER...` format in `write-us`
- `tech` — no direct user value (infrastructure, migration, etc.) → flag explicitly; these may belong as tasks under an existing story rather than standalone stories

**Candidate rules:**
- Target **4–8 candidates**. Fewer than 3 means this might not be an epic. More than 10 means the epic itself should be split.
- Each candidate represents a **single observable user capability**.
- Order candidates by delivery priority: most essential at the top, nice-to-have at the bottom — reflecting the epic's delivery strategy.
- Flag candidates that appear too large with `[needs split]`.
- Do not write full stories yet — candidates are titles and 1-line descriptions only.

---

## Step 5 — Review with the EM

Present the candidate list and ask:

1. Approve the list as-is
2. Add / remove / merge candidates
3. Reorder priority
4. Change decomposition strategy

**Facilitation behaviors:**
- If a candidate covers multiple screens, interactions, or user goals → flag as too large, propose a split
- If total candidates exceed 10 → challenge whether the epic should be split into two
- If a `[tech]` candidate appears → ask whether it belongs as a standalone story or as a task under another story
- If candidates don't collectively cover the epic's full scope → surface the gap explicitly

Do not proceed without explicit confirmation.

---

## Step 6 — Save and hand off

After the EM confirms the candidate list:

1. Save to `initiatives/[initiative-name]/output/decomposition-[epic-slug].md` using this format:

```markdown
# Epic Decomposition — [Epic Title]

> **Source epic:** `initiatives/[initiative-name]/output/[epic-file].md`
> **Date:** [date]
> **Decomposition strategy:** [strategy used]

---

## Story Candidates

| # | Title | Type | Description |
|---|-------|------|-------------|
| 1 | [title] | feature / change / tech | [1-line description] |
| 2 | ... | ... | ... |

---

## Notes

- [Assumptions or open questions surfaced during decomposition]
- [Candidates flagged as `[needs split]` and why]
- [Any `[tech]` candidates and their recommended treatment]
```

2. Confirm the file path after saving.
3. Offer next steps:
   - **"Flesh out a specific story"** — invoke `write-us` for a selected candidate (pass title and type so `write-us` can skip its type question)
   - **"Flesh out all stories one by one"** — invoke `write-us` sequentially for each candidate
   - **"Create all candidates as placeholder issues in Jira"** — invoke `jira` skill to create minimal issues (title + type only) linked to the parent epic
   - **"Done for now"**

---

## Quality checklist (run before showing candidates)

- [ ] 4–8 candidates (fewer than 3 or more than 10 = flag before showing)
- [ ] Each candidate is a single user capability, not a technical task (unless flagged `[tech]`)
- [ ] Candidates collectively cover the epic's full scope — no major gaps
- [ ] Candidates don't overlap significantly
- [ ] Type (`feature` / `change` / `tech`) assigned to every candidate
- [ ] Candidates ordered by delivery priority
- [ ] `[needs split]` flag applied where appropriate
- [ ] If a story map (`US_Mapping_*.md`) exists for this initiative, verify candidates don't duplicate already-mapped stories
- [ ] Source epic is referenced in the output file

---

## Style guidelines

- Be concise — candidate titles should be scannable at a glance (~5–8 words)
- Reflect the user's language from the epic, not generic labels or internal system terminology
- EM tone: pragmatic, delivery-focused, outcome-driven
- Do not hallucinate candidates not supported by the epic's scope
- If something is uncertain, flag it in the Notes section rather than guessing
