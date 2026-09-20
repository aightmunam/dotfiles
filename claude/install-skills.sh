#!/usr/bin/env bash
#
# Install the third-party Claude Code skills that are NOT versioned in this repo.
# They are publicly available via the `npx skills` CLI (https://skills.sh) and
# install into ~/.claude/skills (which this repo symlinks). Nothing under
# claude/skills/ is git-tracked; this script is the source of truth for skills.
#
# Idempotent: re-running installs/updates. Run standalone or via `make install`.
# Requires Node (npx) — provided by home-manager (`make build`).
set -uo pipefail

if ! command -v npx >/dev/null 2>&1; then
  echo "npx not found — run 'make build' (installs Node via home-manager) first." >&2
  exit 1
fi

# "owner/repo:skill" — sources verified on https://skills.sh. Curated to the
# skills actually in use (unused ones pruned; re-add a line to bring one back).
SKILLS=(
  "upstash/context7:context7-mcp"          # official Upstash / Context7
  "kambleakash0/agent-skills:domain-glossary"
  "kambleakash0/agent-skills:english-humanizer"
  "kambleakash0/agent-skills:git-workflow"
  "kambleakash0/agent-skills:grill-master"
  "kambleakash0/agent-skills:incremental-tdd"
  "kambleakash0/agent-skills:script-writer"
  "kambleakash0/agent-skills:slice-the-spec"
  "kambleakash0/agent-skills:spec-writer"
)

fail=0
for entry in "${SKILLS[@]}"; do
  repo="${entry%%:*}"
  skill="${entry##*:}"
  echo "-> skills add $repo --skill $skill"
  npx -y skills add "$repo" --skill "$skill" -g -y || { echo "  failed: $entry"; fail=1; }
done

if [ "$fail" -ne 0 ]; then
  echo "Some skills failed to install. Re-run: ./claude/install-skills.sh" >&2
  exit 1
fi
