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

3. On first run, the EM agent will ask for your management style. Answer once — it saves automatically.

4. Add your team data:
   ```bash
   cp data/team_example.md data/team_myteam.md
   # Edit with your team's details
   ```

### Project-Specific Jira

For each Jira project you work with, copy and configure the Jira skill:

```bash
cp -r .opencode/skills/jira .opencode/skills/jira-xxx
# Edit .opencode/skills/jira-xxx/SKILL.md:
#   - Update name: jira-xxx
#   - Replace {{PROJECT_KEY}}, {{CLOUD_ID}}, {{BASE_URL}}
```

## Usage

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

## Architecture

```
.opencode/
├── agents/manager.md     # Primary EM agent (persona + permissions)
├── skills/               # 10 conversational workflow skills
├── commands/             # /ic-activity command
└── scripts/              # Bash scripts for data gathering
```

- **opencode.json** — Workspace config with isolation and CLI-first permissions
- **AGENTS.md** — Structural rulebook (data access, workspace conventions, EM style)
- **data/** — Team context files

## Isolation

This workspace is designed to run independently of any global OpenCode configuration:
- `instructions: []` prevents global rules from bleeding in
- `mcp: {}` disables globally-configured MCP servers
- Permissions are explicitly defined at workspace level
- The `manager` agent has its own permission overrides

## License

See [LICENSE](./LICENSE).
