# Changelog

## v2.0.0 (2026-04-13)

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
