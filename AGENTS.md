# opencode-em-os — Workspace Rules

This workspace is an Engineering Manager operating system. These rules define how the agent behaves, how data is accessed, and how work is organized. They apply to all agents and sessions.

## Engineering Manager Style

The EM's style is: **EMPTY**.

- If `EMPTY` appears literally as the EM's style, ask: *"What is your style as Engineering Manager?"*
- When asking, help the user define a useful style by exploring:
  - **Decision-making**: directive (you decide and communicate) vs. collaborative (you facilitate group decisions) vs. delegative (you set context, team decides)
  - **Challenge level**: do you prefer being pushed hard on your thinking, or a more supportive facilitation style?
  - **Communication tone**: direct and concise vs. narrative and contextual
  - **Focus**: delivery-oriented (ship it) vs. growth-oriented (develop people) vs. balanced
- Guide the user to write 2–4 sentences. A good style is specific enough to change how the agent behaves. Examples:
  - *"I'm a direct, delivery-focused EM. I prefer being challenged hard on vague thinking. I value concise communication and data-backed decisions. I lean collaborative on strategy but directive on execution."*
  - *"I lead with empathy and context. I prefer coaching-style facilitation over directive advice. I want the agent to surface people risks and growth opportunities, not just delivery metrics."*
- Once provided, edit this file replacing `EMPTY` with the value. Use the style to calibrate tone, challenge intensity, and focus across all subsequent conversations.

## Workspace Structure

```
opencode-em-os/
├── data/                           # Shared institutional memory (persists across initiatives)
│   ├── jira.md                     # Jira instance config + all project definitions
│   ├── teams/                      # One folder per team
│   │   └── {team-slug}/
│   │       ├── team.md             # Roster, roles, GitHub handles, Jira emails
│   │       └── one-on-ones/        # Per-person 1:1 history logs
│   │           └── {nickname}.md
│   ├── products/                   # One file per logical product or platform
│   │   └── {product-slug}.md       # Repos, stack, architecture, glossary, learnings
│   ├── strategies/                 # Persisted strategy documents
│   │   └── {slug}.md
│   └── visions/                    # Persisted vision documents
│       └── {slug}.md
└── initiatives/                    # One folder per initiative (ephemeral project workspaces)
    └── [initiative-name]/
        ├── data/                   # Input context (PRDs, specs, notes) + promoted reference material
        ├── tmp/                    # Scratchpad — can be deleted without loss
        ├── scripts/                # Disposable automation for this initiative
        └── output/                 # Generated artifacts (epics, stories, reports, MANIFEST.md)
```

## Data Access Rules

- **Team Context**: Team data lives in `data/teams/{team-slug}/team.md`. ALWAYS read the relevant team file when a team member is mentioned or their context is needed.
- **Product Context**: Product data lives in `data/products/{product-slug}.md`. Read when working on an initiative related to a known product — architecture, domain terms, and learnings provide valuable context.
- **Data Gathering**: For ad-hoc questions and general conversation, only use data files the user explicitly references or the known team/product context files. Skills with defined file access patterns (e.g., reading `output/` folders, locating epic files) follow their own access rules. NEVER search for or access external data sources on your own. If data is missing, ask the user to provide it.

## Active Initiative

If the user has specified or is clearly working within an initiative during the current conversation, remember it as the active context. Do not ask "which initiative?" again unless the request is ambiguous or could span multiple initiatives.

## Initiative Boundaries

- All initiative work lives under `initiatives/[initiative-name]/`.
- Keep initiative-specific generated files contained within their respective directory.
- Save reports and analyses to `initiatives/[initiative-name]/output/`.

## Sync Invariant

When any artifact is created in Jira, its source `.md` file **MUST** be updated with YAML frontmatter (`jira_key`, `jira_url`, `jira_synced_at`). This is handled by the `jira` skill's Step 6 — callers must always pass the source file path when invoking it. Never leave a Jira issue without a local reference.

## Knowledge Preservation

Local files are the system's institutional memory. Content synced to Jira is **NOT** considered "backed up" — Jira is a delivery tool, not a knowledge base. Before deleting any file with substantive content, evaluate whether architecture decisions, domain knowledge, or learnings should be extracted to `data/products/`. Default to preserving over deleting.

## Tooling Conventions

Always prefer CLI and local scripts over MCP tools. This saves tokens and keeps interactions fast and reproducible. If a required CLI is not installed, suggest installation and configuration steps before proceeding.

**Priority order:**
1. **Skills** — load the appropriate skill when one exists for the operation (e.g., `jira` skill for Jira work)
2. **CLI tools** (`jira`, `gh`) — use directly when no skill covers the operation
3. **Bash scripts** — scripts under `.opencode/scripts/` or ad-hoc bash using CLI tools / REST APIs
4. **MCP tools** — only when CLI/bash is not feasible, or the user explicitly asks for it

**Jira specifics:**
- For any Jira action, load the `jira` skill.
- Instance configuration (Base URL, Cloud ID) and project-specific settings (project key, defaults, issue types) are read from `data/jira.md`.
- Authentication tokens and credentials are NEVER stored in `data/`. They live in `.env.local` (see `.env.example`).
- When a Jira operation is needed and no project is specified, list the projects in `data/jira.md` and ask.

## Output Constraints

- All generated output must be in **English**.
- Maintain the Engineering Manager's style as defined above.
- **File naming**: use `kebab-case`. Prefix output files by type: `epic-build-`, `epic-discovery-`, `us-`, `decomposition-`, `strategy-`, `vision-`.
- **output/ vs data/ vs tmp/**: `output/` holds generated artifacts (epics, stories, decompositions, reports, manifests). `data/` holds input context (PRDs, specs, meeting notes) and promoted reference material. `tmp/` holds scratchpad content that can be deleted without loss.
