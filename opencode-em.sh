#!/usr/bin/env bash
# opencode-em.sh — Isolated OpenCode runner for opencode-em-os
#
# Overrides XDG_CONFIG_HOME so OpenCode uses a local mock global config
# directory instead of ~/.config/opencode. This prevents global settings
# (models, skills, plugins, MCP servers, providers) from bleeding into this project.

set -euo pipefail

ISOLATED_DIR="$PWD/.opencode-global"

# Bootstrap: create a minimal global config on first run
if [ ! -f "$ISOLATED_DIR/opencode/opencode.json" ]; then
  echo "First run: bootstrapping isolated global config..."
  mkdir -p "$ISOLATED_DIR/opencode"
  echo '{}' >"$ISOLATED_DIR/opencode/opencode.json"
fi

echo "Starting OpenCode in isolated mode..."
XDG_CONFIG_HOME="$ISOLATED_DIR" exec opencode "$@"
