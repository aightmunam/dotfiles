#!/usr/bin/env bash
#
# Install the third-party Claude Code skills that are NOT versioned in this repo.
#
# Only custom (user-authored) skills live in claude/skills/ and are tracked in
# git. Everything below is publicly installable via the `npx skills` CLI
# (https://skills.sh), so it is restored here instead of vendored. Skills install
# into ~/.claude/skills (which this repo symlinks), alongside the custom ones.
#
# Idempotent: re-running installs/updates. Run standalone or via `make install`.
# Requires Node (npx) — provided by home-manager (`make build`).
set -uo pipefail

if ! command -v npx >/dev/null 2>&1; then
  echo "npx not found — run 'make build' (installs Node via home-manager) first." >&2
  exit 1
fi

# "owner/repo:skill" — sources verified on https://skills.sh
SKILLS=(
  "ast-grep/agent-skill:ast-grep"          # official ast-grep org
  "cocoindex-io/cocoindex-code:ccc"        # official CocoIndex
  "upstash/context7:context7-mcp"          # official Upstash / Context7
  "vercel-labs/skills:find-skills"         # Vercel Labs (ships with the CLI)
  "kambleakash0/agent-skills:code-review"
  "kambleakash0/agent-skills:deep-codebase-audit"
  "kambleakash0/agent-skills:domain-glossary"
  "kambleakash0/agent-skills:english-humanizer"
  "kambleakash0/agent-skills:git-workflow"
  "kambleakash0/agent-skills:grill-master"
  "kambleakash0/agent-skills:incremental-tdd"
  "kambleakash0/agent-skills:script-writer"
  "kambleakash0/agent-skills:slice-the-spec"
  "kambleakash0/agent-skills:spec-to-plan"
  "kambleakash0/agent-skills:spec-writer"
)

fail=0
for entry in "${SKILLS[@]}"; do
  repo="${entry%%:*}"
  skill="${entry##*:}"
  echo "-> skills add $repo --skill $skill"
  npx -y skills add "$repo" --skill "$skill" -g -y || { echo "  failed: $entry"; fail=1; }
done

echo ""
echo "Custom skills (versioned in git, not installed here): subagent-orchestrator"
if [ "$fail" -ne 0 ]; then
  echo "Some skills failed to install. Re-run: ./claude/install-skills.sh" >&2
  exit 1
fi
