# Changelog

## v1.0.0 (2026-04-14)

### Added
- Isolated OpenCode runner (`opencode-em.sh`) to prevent global config bleeding
- Project-level isolation via explicit `instructions` and `mcp` overrides in `opencode.json`
- Local `.opencode-global/` mock directory for per-project config isolation
- SSH clone URL and project badges in README

### Changed
- README: Updated Setup instructions to treat the repository as a template (use GitHub template feature)
- README: Updated Setup flow to recommend isolated runner
- README: Standardized repository name to `opencode-em-os`
- .gitignore: Simplified data isolation options with clearer workspace/initiative distinction
- opencode.json: Reorganized and cleaned up configuration structure

## v0.1.0 (2026-04-13)

### Added
- Management style definition guidance with examples and dimension prompts in `AGENTS.md`
- Auto-creation of initiative folder structure (`data/`, `tmp/`, `scripts/`, `output/`) in `plan-initiative` skill
- Initiative identity step in `plan-initiative`: slug proposal and folder existence check before drafting
- Output path conventions for all authoring skills — save to `initiatives/[name]/output/` automatically
- Save-then-Jira workflow for epic and user story skills (save locally first, then offer Jira push)
- Dual save path for `write-strategy` and `write-vision`: initiative-level or team-level (`data/`)

### Changed
- README: reorganized skill categories into Strategy & Planning, Product & Delivery Authoring, Integrations, and People & Leadership
- README: expanded Quick Start step 6 with management style guidance, pointing to `AGENTS.md` for examples
- README: updated Initiative Planning workflow — `plan-initiative` now creates the folder; manual `mkdir` no longer required

## v0.0.0 (2026-04-13)

### Breaking Changes
- Migrated from Claude Code ([claude-em](https://github.com/jcesarperez/claude-em)) to OpenCode Native (opencode-engineer-manager)
- Workspace now uses `opencode.json`, `.opencode/agents/`, `.opencode/skills/`, and `.opencode/commands/`

### Added
- Primary `manager` agent with EM persona and CLI-first permissions
- `/ic-activity` command for engineer activity analysis (replaces the ic-activity skill)
- 10 native OpenCode skills migrated from `.claude/skills/`
- Workspace isolation via `opencode.json` permissions and empty `instructions` array
- Disabled built-in `build`/`plan` agents to focus on EM persona
- Granular bash permissions for `jira` and `gh` CLI tools

### Changed
- EM persona moved from `CLAUDE.md` to `.opencode/agents/manager.md`
- `AGENTS.md` pivoted to structural rulebook (data access, workspace conventions)
- IC activity workflow changed from skill to `/ic-activity` command
- Bash script moved to `.opencode/scripts/`

### Removed
- Dependency on Claude Code conventions (`.claude/` directory)
- MCP tool reliance (workspace-level MCP disabled)
