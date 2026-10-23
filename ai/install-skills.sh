#!/usr/bin/env bash
#
# Install the third-party agent skills that are NOT versioned in this repo. They
# are publicly available via the `npx skills` CLI (https://skills.sh) and install
# into the shared ~/.agents/skills store, which Claude Code, Gemini CLI, and Codex
# CLI all symlink to (see ai/generate.sh + home-manager). Nothing installed here
# is git-tracked; this script is the source of truth for third-party skills.
#
# Idempotent: re-running installs/updates. Run standalone or via `make install`.
# Requires Node (npx) — provided by home-manager (`make build`).
set -uo pipefail

if ! command -v npx >/dev/null 2>&1; then
  echo "npx not found — run 'make build' (installs Node via home-manager) first." >&2
  exit 1
fi

# The shared cross-tool store must exist so each tool's skills dir (a whole-dir
# symlink to it) resolves: `npx skills add -g` installs the canonical copy here,
# and a dangling target fails with ENOTDIR. `mkdir -p` is a no-op when it already
# exists, so this never clobbers already-installed skills.
mkdir -p "$HOME/.agents/skills"

# "owner/repo:skill" — sources verified against ~/.agents/.skill-lock.json (the
# npx-skills provenance ledger) and each upstream repo. Every third-party skill in
# the shared store is listed here so a fresh machine reinstalls the full set.
SKILLS=(
  "upstash/context7:context7-mcp"          # official Upstash / Context7
  "ast-grep/agent-skill:ast-grep"          # official ast-grep structural search
  "vercel-labs/skills:find-skills"         # skills.sh discovery/installer
  "cocoindex-io/cocoindex-code:ccc"        # semantic codebase search (ccc CLI)
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

echo "Installing ${#SKILLS[@]} agent skills into ~/.agents/skills"
echo "(per-skill output is shown only on failure; an npx 'PromptScript does not support global' skip is expected and harmless)"

installed=0; failed=0; fails=()
for entry in "${SKILLS[@]}"; do
  repo="${entry%%:*}"
  skill="${entry##*:}"
  if out="$(npx -y skills add "$repo" --skill "$skill" -g -y 2>&1)"; then
    printf '   \342\234\223 %-22s (%s)\n' "$skill" "$repo"          # ✓
    installed=$((installed + 1))
  else
    printf '   \342\234\227 %-22s (%s)\n' "$skill" "$repo"          # ✗
    printf '%s\n' "$out" | tail -6 | sed 's/^/       /'
    fails+=("$entry"); failed=$((failed + 1))
  fi
done

echo "Skills: $installed installed, $failed failed (of ${#SKILLS[@]}) in ~/.agents/skills"
if [ "$failed" -ne 0 ]; then
  printf 'Re-run for failures: %s\n' "${fails[*]}" >&2
  exit 1
fi
