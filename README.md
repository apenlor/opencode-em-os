# OpenCode Engineer Manager OS

An Engineering Manager Operating System (EM-OS) built natively for [OpenCode](https://opencode.ai).

## What This Does

Transforms OpenCode into a context-aware Engineering Manager assistant with:

*   **Structured initiative planning**: from rough ideas to scoped plans with epics.
*   **1:1 lifecycle management**: situation analysis, preparation, and historical logging.
*   **Strategy and vision writing**: following Rumelt and Larson frameworks.
*   **Epic and user story drafting**: build epics, discovery epics, INVEST-compliant stories.
*   **IC activity analysis**: automated metrics from Jira and GitHub.
*   **User story mapping**: from PRDs and Figma contexts to structured story maps.
*   **Leadership mentoring**: Engineering Director perspective to sharpen your thinking.

## Quick Start

### Prerequisites

*   [OpenCode](https://opencode.ai) installed.
*   [Jira CLI](https://github.com/ankitpokhrel/jira-cli) installed and configured.
*   [GitHub CLI](https://cli.github.com/) installed and authenticated.

### Setup

1. **Clone this repository**:
   ```bash
   git clone <repo-url> && cd opencode-engineer-manager
   ```

2. **Set up your environment**:
   ```bash
   cp .env.example .env.local
   # Edit .env.local with your GitHub token and Jira credentials
   ```

3. **Configure your Jira instance and projects** in `data/jira.md`:
   ```markdown
   ## Instance
   Base URL: yourcompany.atlassian.net
   Cloud ID: your-cloud-id

   ## Projects
   ### PROJ - My Project
   Project Key: PROJ
   ...
   ```

4. **Add your team data**:
   ```bash
   cp data/team_example.md data/team_myteam.md
   # Edit with your team's details (Jira emails, GitHub handles, etc.)
   ```

5. **Start OpenCode**:
   ```bash
   opencode
   ```

6. On the first run, the EM agent will ask for your management style. Write 2–4 sentences covering your decision-making approach, preferred challenge level, communication tone, and focus areas. The more specific you are, the better the agent adapts. See `AGENTS.md` for examples and prompts.

## Workspace Structure

This workspace enforces strict organization to prevent context bleed between different initiatives.

```text
opencode-engineer-manager/
├── .env.example                # Template: copy to .env.local (never commit .env.local)
├── data/                       # Shared context (persists across all work)
│   ├── jira.md                 # Jira instance config + all project definitions
│   ├── team_{name}.md          # Team rosters, roles, GitHub handles, Jira emails
│   └── one-on-ones/            # Per-person 1:1 history logs
│
├── initiatives/                # Active work (One folder per initiative)
│   └── [initiative-name]/
│       ├── data/               # Context just for this initiative (PRDs, notes)
│       ├── tmp/                # Scratchpad files
│       ├── scripts/            # Ad-hoc scripts for this specific project
│       └── output/             # Generated epics, strategies, and reports
│
└── .opencode/                  # The agent's brain (skills, commands, personas)
```

### Data Access Map

| What | Where | Why |
|---|---|---|
| GitHub token, Jira token, Jira email | `.env.local` | Secrets: never committed. |
| Jira instance URL, Cloud ID | `data/jira.md` | Non-secret, instance-level configuration. |
| Jira project key, defaults, issue types | `data/jira.md` | Project-specific routing and rules. |
| Team member names, GitHub handles | `data/team_*.md` | Team context for skills and commands. |
| 1:1 history per team member | `data/one-on-ones/{id}.md` | Structured memory for prep and logging. |

### Data Access Rules

The `@manager` agent operates on a **strict explicit context** rule. To keep your data private and context clean, it will not crawl your hard drive or the web. It will only use:
1. `data/jira.md` for Jira instance and project configuration.
2. Team context files in the root `data/` folder (`data/team_*.md`).
3. 1:1 history files in `data/one-on-ones/` when running 1:1 skills.
4. Files you explicitly point it to in your prompt (e.g., "Review initiatives/backend-rewrite/data/specs.md").
5. Context provided via loaded skills.

Authentication tokens in `.env.local` are consumed only by scripts. The agent never reads them directly.

## Typical Workflows

Here is how you use this OS to drive execution and manage your team.

### 1. Initiative Planning
Drive a new project from idea to execution.
1. **Brainstorm & Plan**: Engage the `plan-initiative` skill to structure your work. The skill will facilitate your thinking, propose a slug for the initiative, and automatically create the folder structure under `initiatives/[slug]/` when the plan is confirmed:
   > "Help me plan the backend rewrite initiative."
2. **Provide Raw Context** (optional): Drop PRDs or raw notes into `initiatives/[slug]/data/` for the agent to reference.
3. **Draft Execution Items**: Once the plan is solid, generate strategies, visions, epics, or stories. Authoring skills save output to `initiatives/[slug]/output/` automatically.
4. **Push to Jira**: Leverage the built-in CLI integration:
   > "Create these epics in the 'PROJ' Jira project."

### 2. The 1:1 Lifecycle
Maintain a continuous feedback loop with direct reports using structured memory.
1. **Prepare**: Invoke `prepare-one-on-one` for a team member (e.g., Bob). The system reads `data/team_*x*.md` and `data/one-on-ones/bob.md` to surface pending items and signal trends.
2. **Review**: The agent presents a structured prep sheet with opening lines, situational analysis, and key questions.
3. **Log**: After the session, use `log-one-on-one` to commit the highlights, new commitments, and signals back to `data/one-on-ones/bob.md`.

### 3. User Story Mapping
Translate high-level product requirements into functional slices.
1. **Ingest**: Place a PRD or raw feature requirements in your initiative's `data/` folder.
2. **Map**: Use the `us-mapping` skill and point it to the PRD. The system generates a structured map (Backbone -> Activities -> Stories) in your `output/` folder.
3. **Refine**: Ask the agent to break down specific complex activities into smaller, INVEST-compliant user stories using the `write-us` skill.
4. **Export**: Use the `jira` skill to transform the finalized story map into a prioritized Jira backlog.

## Available Tools

The agent automatically loads these skills based on your request.

### Strategy & Planning
| Skill | Trigger Examples |
|-------|-----------------|
| `plan-initiative` | "plan an initiative", "help me structure this" |
| `write-strategy` | "write a strategy" |
| `write-vision` | "write a vision" |

### Product & Delivery Authoring
| Skill | Trigger Examples |
|-------|-----------------|
| `us-mapping` | "user story map", "story mapping" |
| `write-epic-build` | "write an epic", "implementation plan" |
| `write-epic-technical-discovery` | "technical discovery", "discovery epic" |
| `write-us` | "write a user story", "write a US" |

> These skills produce local artifacts in `initiatives/[name]/output/`. They offer to push content to Jira as a follow-up step.

### Integrations
| Skill / Command | Trigger Examples |
|-------|-----------------|
| `jira` | "create an epic in Jira", "show me bugs", "issues completed" |
| `/ic-activity` (Command) | "/ic-activity John last month" |

> These tools interact with external systems (Jira, GitHub). They create or query data outside this workspace.

### People & Leadership
| Skill / Command | Trigger Examples |
|-------|-----------------|
| `prepare-one-on-one` | "prepare my 1:1 with", "1:1 prep" |
| `log-one-on-one` | "log my 1:1 with", "record 1:1", "save 1:1 notes" |
| `mentor-me` | "mentor me with", "help me think", "I need advice" |

## Isolation & Security

This workspace is designed to run independently of any global OpenCode configuration:
- `instructions: []` in `opencode.json` prevents global rules from bleeding in.
- `mcp: {}` disables globally-configured MCP servers.
- Permissions are explicitly defined at the workspace level, favoring CLI tools over MCP for transparency and speed.

## License

See [LICENSE](./LICENSE).
