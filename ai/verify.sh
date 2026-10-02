#!/usr/bin/env bash
# Drift check: confirm the cross-tool config actually reaches each agent.
# Run via `make verify-ai`.
set -uo pipefail

echo "== instruction + skills symlinks =="
for l in \
  "$HOME/.claude/AGENTS.md" "$HOME/.gemini/GEMINI.md" "$HOME/.codex/AGENTS.md" \
  "$HOME/.claude/skills"    "$HOME/.gemini/skills"     "$HOME/.codex/skills"; do
  if [ -e "$l" ]; then
    printf '  OK   %-24s -> %s\n' "${l#$HOME/}" "$(readlink -f "$l")"
  else
    printf '  DEAD %s\n' "${l#$HOME/}"
  fi
done

echo "== MCP servers per tool (should match ai/mcp/servers.json) =="
want="$(jq -r '.servers | keys | join(", ")' "$(dirname "${BASH_SOURCE[0]}")/mcp/servers.json" 2>/dev/null)"
echo "  expected: ${want:-?}"
for t in claude gemini codex; do
  if command -v "$t" >/dev/null 2>&1; then
    echo "  $t:"
    "$t" mcp list 2>/dev/null | sed 's/^/    /'
  else
    echo "  $t: not installed"
  fi
done
