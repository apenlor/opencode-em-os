# opencode-engineer-manager — Workspace Rules

This workspace is an Engineering Manager operating system. These rules define how data is accessed, how work is organized, and the EM's personal style.

## Engineering Manager Style

The EM's style is: **EMPTY**.

- If `EMPTY` appears literally as the EM's style, ask: *"What is your style as Engineering Manager?"*
- Once provided, replace `EMPTY` above with the value and use it for all subsequent conversations.

## Workspace Structure

```
opencode-engineer-manager/
├── data/                       # Shared data across initiatives
│   ├── team_{name}.md          # Team context files
│   ├── [source]/               # One folder per data source (jira, github, etc.)
│   └── tmp/                    # Temporary files not tied to any initiative
└── [initiative-name]/          # One folder per initiative
    ├── data/                   # Initiative-specific data
    ├── tmp/                    # Initiative-specific temporary files
    ├── scripts/                # Analysis and processing scripts
    └── output/                 # Reports and analysis results
```

## Data Access Rules

- **Team Context**: Team data lives in `data/team_{name}.md`. ALWAYS read the relevant team file when a team member is mentioned or their context is needed.
- **Data Gathering**: ONLY use data files the user explicitly references or the known team context files. NEVER look for external data on your own. If data is missing, explicitly ask the user to provide it.

## Initiative Boundaries

- Work is organized into top-level `[initiative-name]/` directories.
- Keep initiative-specific generated files contained within their respective directory.
- Save reports and analyses to `[initiative-name]/output/`.

## Tooling Conventions

- **CLI over MCP**: ALWAYS prefer CLI tools (`jira`, `gh`) and local bash scripts over MCP servers.
- **Jira Operations**: For Jira actions, load the `jira` skill. Project-specific configuration (project key, base URL, cloud ID) is read from `data/jira/<project>.md`. Never call MCP Jira tools directly.
- **Jira Projects**: Project configurations live in `data/jira/<project>.md`. When a Jira operation is needed and no project is specified, list available configs and ask. Read the config file to obtain project key, base URL, and cloud ID.
- **Missing CLIs**: If a required CLI is not installed, suggest installation and configuration steps before attempting to proceed.

## Output Constraints

- All generated output must be in **English**.
- Maintain the Engineering Manager's style as defined above.
