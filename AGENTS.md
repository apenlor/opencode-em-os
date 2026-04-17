# opencode-em-os — Workspace Rules

This workspace is an Engineering Manager operating system. These rules define how data is accessed, how work is organized, and the EM's personal style.

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
├── data/                       # Shared data across initiatives
│   ├── jira.md                 # Jira instance config + all project definitions
│   ├── team_{name}.md          # Team context files
│   └── one-on-ones/            # Per-person 1:1 history logs
└── initiatives/                # One folder per initiative
    └── [initiative-name]/
        ├── data/               # Initiative-specific data
        ├── tmp/                # Initiative-specific temporary files
        ├── scripts/            # Analysis and processing scripts
        └── output/             # Reports and analysis results
```

## Data Access Rules

- **Team Context**: Team data lives in `data/team_{name}.md`. ALWAYS read the relevant team file when a team member is mentioned or their context is needed.
- **Data Gathering**: ONLY use data files the user explicitly references or the known team context files. NEVER look for external data on your own. If data is missing, ask the user to provide it.

## Initiative Boundaries

- All initiative work lives under `initiatives/[initiative-name]/`.
- Keep initiative-specific generated files contained within their respective directory.
- Save reports and analyses to `initiatives/[initiative-name]/output/`.

## Tooling Conventions

Always prefer CLI and local scripts over MCP tools. This saves tokens and keeps interactions fast and reproducible. If a required CLI is not installed, suggest installation and configuration steps before proceeding.

**Priority order:**
1. **Skills** — load the appropriate skill when one exists for the operation (e.g., `jira` skill for Jira work)
2. **CLI tools** (`gh`) — use directly when no skill covers the operation
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
