# OpenCode EM-OS Guide

Detailed documentation for the Engineering Manager Operating System.
For quick setup, see [README.md](./README.md).

## The OS Metaphor

The `opencode-em-os` is designed as a long-lived memory system for your management practice:

- **`data/` (Institutional Memory)**: Persists across initiatives. This is where your team rosters, 1:1 history, product context, and finalized strategies/visions live.
- **`initiatives/` (Ephemeral Workspaces)**: Every project or major effort gets its own folder. Work happens here, and when finished, useful artifacts are promoted to `data/` while the rest is tidied.
- **Skills**: Specialized workflows that encode management frameworks (Rumelt, Larson, INVEST, etc.).
- **The Agent**: A context-aware EM assistant that relies on your local data instead of generic internet training.

---

## Key Concepts

### Strategies
Based on Richard Rumelt's "Good Strategy Bad Strategy". A strategy is not a "goal" or a "mission"; it is a coordinated response to a specific challenge. A strategy has a kernel:
- **Diagnosis**: An explanation of the nature of the challenge.
- **Guiding policy**: The overall approach chosen to cope with or overcome the obstacles identified in the diagnosis.
- **Coherent actions**: Coordinated steps, resource deployments, and policies designed to carry out the guiding policy.

Strategies live in `data/strategies/` when they are org/team-level, or in `initiatives/[name]/output/` when initiative-scoped.

### Visions
Based on Larson's vision framework. A vision is a concrete description of a desired future state. It provides direction and inspiration:
- **Where we are**: Current state and why it needs to change.
- **Where we're going**: A vivid description of the destination.
- **Why it matters**: The value proposition for the team and the business.
- **How we'll get there**: The high-level roadmap and milestones.

Visions live in `data/visions/` when they are org/team-level.

### Product Context
Product files (`data/products/{slug}.md`) capture persistent knowledge about a specific logical product, service, or platform. They include:
- Relevant repositories and tech stack.
- High-level architecture and domain glossary.
- Key learnings and past mistakes to avoid.

Authoring skills (like `write-epic-build`) optionally read these files to ensure the generated epics and stories are technically and contextually grounded.

### Initiative Lifecycle
1. **Plan**: Use `plan-initiative` to structure your thinking and create the initiative folder.
2. **Execute**: Use authoring skills (`write-epic-build`, `us-mapping`, etc.) to produce scoped work.
3. **Tidy**: Use `tidy-initiative` to consolidate the output, promote knowledge to `data/`, and clean up drafts.

---

## Detailed Setup

### Environment & Credentials
1. Copy `.env.example` to `.env.local`.
2. Provide your Jira email and an [Atlassian API Token](https://id.atlassian.net/manage-profile/security/api-tokens).
3. `gh auth login` handles GitHub authentication via your system keychain.

### Jira Configuration
Define your instance and project routing in `data/jira.md`. The `jira` skill uses this file to know where to push issues and how to map issue types (Epic, Story, Task).

### Team Data Setup
1. Create a directory for your team: `mkdir -p data/teams/my-team/one-on-ones`.
2. Copy `data/teams/example/team.md` to `data/teams/my-team/team.md`.
3. Update the roster with real GitHub handles and Jira emails. This enables the `/ic-activity` command and 1:1 skills.

---

## Isolation Mode

The `opencode-em.sh` wrapper script is the recommended way to run this OS. It isolates your workspace from global OpenCode configurations.

**How it works:**
- It sets `XDG_CONFIG_HOME` to a local `.opencode-global/` directory.
- This prevents your global skills, plugins, or MCP servers from interfering with the EM-OS.
- **Provider Setup**: On your first run in isolated mode, you must run `/connect` to set up your AI provider (Anthropic, OpenAI, etc.).

**Jira CLI Caveat:**
The Jira CLI also respects `XDG_CONFIG_HOME`. When running in isolated mode, it will look for config at `.opencode-global/.jira/` instead of your default `~/.config/.jira/`.
If you have already initialized the Jira CLI globally, you will need to re-run `jira init` once inside the isolated environment:
```bash
./opencode-em.sh
# Inside the session:
set -a; source .env.local; set +a
jira init
```

---

## Workflow Walkthroughs

### 1. Initiative Planning
**Trigger**: "Help me plan the 'Cloud Migration' initiative."
**Outcome**: A structured plan saved to `initiatives/cloud-migration/output/initiative-plan.md` and an auto-created folder structure.
**Tip**: Be as vague or as specific as you want. The agent will ask clarifying questions to help you scope the work.

### 2. The 1:1 Lifecycle
**Preparation**: "Prepare my 1:1 with Alice."
**Outcome**: The agent reads Alice's history and team context to propose a "prep sheet".
**Logging**: "Log my 1:1 with Alice."
**Outcome**: After the session, the agent summarizes your notes and appends them to Alice's historical log in `data/teams/{team}/one-on-ones/alice.md`.

### 3. User Story Mapping
**Trigger**: "Create a story map for the new checkout flow."
**Outcome**: The agent analyzes requirements (which you can drop in `initiatives/checkout/data/`) and builds a backbone-to-story mapping in `output/`.
**Tip**: Use the `jira` skill afterwards to push the resulting map directly into a Jira backlog.

### 4. Initiative Cleanup
**Trigger**: "Tidy the cloud-migration initiative."
**Outcome**: An interactive session where the agent inventories your files and recommends actions (Keep, Promote to Shared, Delete).
**Safety**: The agent will never delete files without your confirmation and will never overwrite shared data (it only appends).

---

## Data Model Reference

### Workspace Structure
```text
opencode-em-os/
├── data/                           # Shared (Long-term)
│   ├── teams/                      # Roster + 1:1 History
│   │   └── {team}/
│   │       ├── team.md
│   │       └── one-on-ones/
│   ├── products/                   # Tech context + Architecture
│   ├── strategies/                 # Persisted Strategy kernels
│   └── visions/                    # Persisted Vision docs
├── initiatives/                    # Workspaces (Short-term)
│   └── [slug]/
│       ├── data/                   # Input (PRDs, specs)
│       ├── output/                 # Generated artifacts (Epics, Stories)
│       ├── scripts/                # Ad-hoc scripts
│       └── tmp/                    # Scratchpad
└── .opencode/                      # The OS logic (Skills, Commands)
```

### Data Access Rules
1. **Team Context**: Read from `data/teams/*/team.md` for roster details.
2. **1:1 History**: Read/Write to `data/teams/*/one-on-ones/*.md`.
3. **Product Context**: Optional read from `data/products/*.md`.
4. **Initiative Boundaries**: All working files stay inside `initiatives/[slug]/`.

---

## Extending the OS

- **Custom Skills**: Add your own `.md` skill files to `.opencode/skills/`.
- **Custom Commands**: Add bash-based commands to `.opencode/commands/`.
- **Persona Tweaks**: Edit `.opencode/agents/manager.md` to refine how the EM agent speaks and thinks.
