# opencode-engineer-manager

An Engineering Manager Operating System built natively for [OpenCode](https://opencode.ai).

## What This Does

Transforms OpenCode into a context-aware Engineering Manager assistant with:

- **Structured initiative planning** — from rough ideas to scoped plans with epics
- **1:1 preparation** — situation analysis, key questions, opening lines
- **Strategy & vision writing** — following Rumelt and Larson frameworks
- **Epic & user story drafting** — build epics, discovery epics, INVEST-compliant stories
- **IC activity analysis** — automated metrics from Jira and GitHub
- **User story mapping** — from PRDs and Figma to structured story maps
- **Leadership mentoring** — Engineering Director perspective to sharpen your thinking

## Quick Start

### Prerequisites

- [OpenCode](https://opencode.ai) installed
- [Jira CLI](https://github.com/ankitpokhrel/jira-cli) installed and configured
- [GitHub CLI](https://cli.github.com/) installed and authenticated

### Setup

1. Clone this repository:
   ```bash
   git clone <repo-url> && cd opencode-engineer-manager
   ```

2. Start OpenCode:
   ```bash
   opencode
   ```

3. On first run, the EM agent will ask for your management style. Answer once — it saves automatically to `AGENTS.md`.

4. Add your team data:
   ```bash
   cp data/team_example.md data/team_myteam.md
   # Edit with your team's details (Jira IDs, GitHub handles, etc.)
   ```

### Project-Specific Jira

For each Jira project you work with, create a config file:

```bash
cp data/jira/example.md data/jira/myproject.md
# Edit data/jira/myproject.md:
#   - Set Project Key, Cloud ID, Base URL
#   - Customize defaults and custom fields as needed
```

The `jira` skill automatically discovers available projects from `data/jira/`.

## Workspace Structure & Data Management

This workspace enforces strict organization to prevent "context bleed" between different initiatives. 

```text
opencode-engineer-manager/
├── data/                       # Shared context (persists across all work)
│   ├── team_{name}.md          # Team rosters, roles, and context
│   └── jira/                   # Project-specific Jira configurations
│
├── [initiative-name]/          # Isolated workspace for an active initiative
│   ├── data/                   # Context just for this initiative (PRDs, notes)
│   ├── tmp/                    # Scratchpad files
│   ├── scripts/                # Ad-hoc scripts for this specific project
│   └── output/                 # Generated epics, strategies, and reports
│
└── .opencode/                  # The agent's brain (skills, commands, personas)
```

### Data Access Rules

The `@manager` agent operates on a **strict explicit context** rule. To keep your data private and context clean, it will not crawl your hard drive or the web. It will only use:
1. Team and Jira configuration files in the root `data/` folder.
2. Files you explicitly point it to in your prompt (e.g., `"Review backend-rewrite/data/specs.md"`).
3. Context provided via loaded skills.

## Typical Workflow

Here is how you use this OS to drive a new project from idea to execution. The agent acts as your thinking partner and execution engine.

1. **Establish the Boundary:** Create a new folder for your project. You can do this manually or ask the agent to do it.
   ```bash
   mkdir -p backend-rewrite/data backend-rewrite/output
   ```
2. **Provide Raw Context:** Drop your raw thoughts, meeting transcripts, or rough PRDs into `backend-rewrite/data/raw-notes.md`.
3. **Brainstorm & Plan:** Engage the `plan-initiative` skill to help structure your thoughts:
   > *"Read backend-rewrite/data/raw-notes.md and help me use the `plan-initiative` skill to structure this work."*
4. **Draft Execution Items:** Once the plan is solid, ask the agent to generate the epics or stories and save them to the output folder:
   > *"Write the epics for the backend rewrite based on our plan and save them to backend-rewrite/output/epics.md"*
5. **Push to Jira:** Finally, leverage the built-in CLI integration:
   > *"Create these epics in the 'PROJ' Jira project."*

## Available Tools

### Skills (loaded automatically when relevant)

| Skill | Trigger Examples |
|-------|-----------------|
| `jira` | "create an epic", "show me bugs", "issues completed" |
| `mentor-me` | "mentor me with", "help me think", "I need advice" |
| `one-on-one` | "prepare my 1:1 with", "1:1 prep" |
| `plan-initiative` | "plan an initiative", "help me structure this" |
| `us-mapping` | "user story map", "story mapping" |
| `write-epic-build` | "write an epic", "implementation plan" |
| `write-epic-technical-discovery` | "technical discovery", "discovery epic" |
| `write-strategy` | "write a strategy" |
| `write-us` | "write a user story", "write a US" |
| `write-vision` | "write a vision" |

### Commands

| Command | Usage |
|---------|-------|
| `/ic-activity` | `/ic-activity John last month` |

## Isolation & Security

This workspace is designed to run independently of any global OpenCode configuration:
- `instructions: []` in `opencode.json` prevents global rules from bleeding in.
- `mcp: {}` disables globally-configured MCP servers.
- Permissions are explicitly defined at the workspace level, favoring CLI tools over MCP for transparency and speed.

## License

See [LICENSE](./LICENSE).
