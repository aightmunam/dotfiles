#!/usr/bin/env bash
# Wire the canonical ai/ config into Gemini CLI and Codex CLI, and fan the MCP
# server list into all three tools via their native `mcp add`. Idempotent and
# safe to re-run; intended to run from `make post-install`.
#
# Claude Code's config is managed declaratively by home-manager; this script
# only touches ~/.gemini and ~/.codex (symlinks) and each tool's MCP config.
set -uo pipefail

REPO="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
AI="$REPO/ai"
STORE="$HOME/.agents/skills"
log() { printf '  %s\n' "$*"; }

# ln -sfn, but never clobber a real (non-symlink) directory that has content.
safe_link() { # $1=target $2=linkpath
  local target="$1" link="$2"
  if [ -e "$link" ] && [ ! -L "$link" ] && [ -d "$link" ]; then
    log "WARN: $link is a real directory; leaving it (move contents into $target)"
    return 0
  fi
  ln -sfn "$target" "$link"
}

mkdir -p "$STORE" "$HOME/.gemini" "$HOME/.codex"

# --- Instructions: AGENTS.md into Gemini + Codex (Claude via home-manager) ---
safe_link "$AI/AGENTS.md" "$HOME/.gemini/GEMINI.md"
safe_link "$AI/AGENTS.md" "$HOME/.codex/AGENTS.md"

# --- Skills store: whole-dir symlink for Gemini + Codex ---
safe_link "$STORE" "$HOME/.gemini/skills"
safe_link "$STORE" "$HOME/.codex/skills"

# --- Custom tracked skills: link ai/skills/* into the shared store ---
if [ -d "$AI/skills" ]; then
  for s in "$AI/skills"/*/; do
    [ -d "$s" ] || continue
    safe_link "${s%/}" "$STORE/$(basename "${s%/}")"
  done
fi

# --- Gemini /name parity: render each custom skill as a TOML slash-command ---
if [ -d "$AI/skills" ]; then
  mkdir -p "$HOME/.gemini/commands"
  for skill in "$AI/skills"/*/SKILL.md; do
    [ -f "$skill" ] || continue
    name="$(basename "$(dirname "$skill")")"
    desc="$(awk -F': *' '/^description:/{sub(/^description: */,""); print; exit}' "$skill")"
    body="$(awk 'f{print} /^---[[:space:]]*$/{c++; if(c==2) f=1}' "$skill")"
    {
      printf 'description = "%s"\n' "${desc:-$name}"
      printf 'prompt = """\n%s\n"""\n' "$body"
    } > "$HOME/.gemini/commands/$name.toml"
  done
fi

# --- MCP fan-out via each tool's native `mcp add` (idempotent) ---
servers="$AI/mcp/servers.json"
if [ -f "$servers" ] && command -v jq >/dev/null 2>&1; then
  while IFS= read -r n; do
    [ -n "$n" ] || continue
    cmd="$(jq -r ".servers[\"$n\"].command // empty" "$servers")"
    url="$(jq -r ".servers[\"$n\"].url // empty" "$servers")"
    mapfile -t args < <(jq -r ".servers[\"$n\"].args // [] | .[]" "$servers")
    mapfile -t envs < <(jq -r ".servers[\"$n\"].env // {} | to_entries[] | \"\(.key)=\(.value)\"" "$servers")
    for tool in claude gemini codex; do
      command -v "$tool" >/dev/null 2>&1 || continue
      "$tool" mcp remove "$n" >/dev/null 2>&1 || true
      case "$tool" in
        claude)
          eflags=(); for e in "${envs[@]}"; do eflags+=( -e "$e" ); done
          if [ -n "$url" ]; then claude mcp add -s user -t http "${eflags[@]}" "$n" "$url" >/dev/null 2>&1
          else claude mcp add -s user "${eflags[@]}" "$n" -- "$cmd" "${args[@]}" >/dev/null 2>&1; fi ;;
        gemini)
          # Gemini rejects the `--` separator; it takes <name> <command> [args...] directly.
          eflags=(); for e in "${envs[@]}"; do eflags+=( -e "$e" ); done
          if [ -n "$url" ]; then gemini mcp add -s user -t http "${eflags[@]}" "$n" "$url" >/dev/null 2>&1
          else gemini mcp add -s user "${eflags[@]}" "$n" "$cmd" "${args[@]}" >/dev/null 2>&1; fi ;;
        codex)
          eflags=(); for e in "${envs[@]}"; do eflags+=( --env "$e" ); done
          if [ -n "$url" ]; then codex mcp add "$n" --url "$url" "${eflags[@]}" >/dev/null 2>&1
          else codex mcp add "$n" "${eflags[@]}" -- "$cmd" "${args[@]}" >/dev/null 2>&1; fi ;;
      esac && log "mcp: $tool <- $n" || log "mcp: $tool <- $n (skipped/failed)"
    done
  done < <(jq -r '.servers | keys[]' "$servers")
fi

echo "generate.sh done."
