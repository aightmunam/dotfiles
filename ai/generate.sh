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
log() { printf '   %s\n' "$*"; }

# ln -sfn, but never clobber a real (non-symlink) directory that has content.
safe_link() { # $1=target $2=linkpath
  local target="$1" link="$2"
  if [ -e "$link" ] && [ ! -L "$link" ] && [ -d "$link" ]; then
    log "⚠️  $link is a real directory; leaving it (move contents into $target)"
    return 0
  fi
  ln -sfn "$target" "$link"
}

# Point a tool's skills dir at the shared store. Whole-dir symlink when the dir
# is absent or already a symlink; when it is a real dir with content (e.g. Codex
# pre-creates ~/.codex/skills/.system), per-skill symlink each store skill in so
# the tool's own entries are preserved.
link_skills_dir() { # $1=tool skills dir
  local dir="$1"
  if [ -L "$dir" ] || [ ! -e "$dir" ]; then
    ln -sfn "$STORE" "$dir"
    log "skills: $dir -> $STORE (whole-dir symlink)"
  elif [ -d "$dir" ]; then
    local s base n=0
    for s in "$STORE"/*/; do
      [ -d "$s" ] || continue
      base="$(basename "${s%/}")"
      [ "$base" = "synced" ] && continue   # npx-skills bookkeeping dir, not a skill
      ln -sfn "${s%/}" "$dir/$base"; n=$((n + 1))
    done
    log "skills: $dir is a real dir; per-skill linked $n store skills into it"
  fi
}

echo "==> cross-tool wiring: instructions, skills, MCP for Gemini + Codex"
mkdir -p "$STORE" "$HOME/.gemini" "$HOME/.codex"

# --- Instructions: AGENTS.md into Gemini + Codex (Claude via home-manager) ---
echo "-> instructions (shared AGENTS.md)"
safe_link "$AI/AGENTS.md" "$HOME/.gemini/GEMINI.md"
safe_link "$AI/AGENTS.md" "$HOME/.codex/AGENTS.md"
log "AGENTS.md -> ~/.gemini/GEMINI.md, ~/.codex/AGENTS.md"

# --- Custom tracked skills: link ai/skills/* into the shared store FIRST, so the
#     store is complete before tools link from it (matters for per-skill linking) ---
echo "-> custom skills (ai/skills -> shared store)"
if [ -d "$AI/skills" ]; then
  n=0
  for s in "$AI/skills"/*/; do
    [ -d "$s" ] || continue
    safe_link "${s%/}" "$STORE/$(basename "${s%/}")"; n=$((n + 1))
  done
  log "linked $n custom skills into ~/.agents/skills"
fi

# --- Skills store: link into Gemini + Codex (whole-dir, or per-skill if real) ---
echo "-> skills store (shared store -> Gemini + Codex)"
link_skills_dir "$HOME/.gemini/skills"
link_skills_dir "$HOME/.codex/skills"
log "store now holds $(find "$STORE" -mindepth 1 -maxdepth 1 -not -name synced 2>/dev/null | wc -l | tr -d ' ') skills"

# --- Gemini /name parity: render each custom skill as a TOML slash-command ---
echo "-> Gemini /name wrappers (TOML)"
if [ -d "$AI/skills" ]; then
  mkdir -p "$HOME/.gemini/commands"
  for skill in "$AI/skills"/*/SKILL.md; do
    [ -f "$skill" ] || continue
    name="$(basename "$(dirname "$skill")")"
    desc="$(awk -F': *' '/^description:/{sub(/^description: */,""); print; exit}' "$skill")"
    body="$(awk 'f{print} /^---[[:space:]]*$/{c++; if(c==2) f=1}' "$skill")"
    {
      printf 'description = "%s"\n' "${desc:-$name}"
      # TOML literal (''') multiline: no escape processing, so backslashes in
      # prompt bodies (e.g. regex \d) stay literal instead of breaking the parse.
      printf "prompt = '''\n%s\n'''\n" "$body"
    } > "$HOME/.gemini/commands/$name.toml"
  done
  log "rendered $(ls -1 "$HOME/.gemini/commands"/*.toml 2>/dev/null | wc -l | tr -d ' ') /name wrappers into ~/.gemini/commands"
fi

# --- MCP fan-out via each tool's native `mcp add` (idempotent) ---
echo "-> MCP servers (fan-out to claude, gemini, codex)"
servers="$AI/mcp/servers.json"
if [ -f "$servers" ] && command -v jq >/dev/null 2>&1; then
  log "source: $(jq -r '.servers | keys | join(", ")' "$servers")"
  while IFS= read -r n; do
    [ -n "$n" ] || continue
    cmd="$(jq -r ".servers[\"$n\"].command // empty" "$servers")"
    url="$(jq -r ".servers[\"$n\"].url // empty" "$servers")"
    mapfile -t args < <(jq -r ".servers[\"$n\"].args // [] | .[]" "$servers")
    mapfile -t envs < <(jq -r ".servers[\"$n\"].env // {} | to_entries[] | \"\(.key)=\(.value)\"" "$servers")
    for tool in claude gemini codex; do
      command -v "$tool" >/dev/null 2>&1 || { log "• $n -> $tool (not installed, skipped)"; continue; }
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
      esac && log "✓ $n -> $tool" || log "⚠️  $n -> $tool (add failed)"
    done
  done < <(jq -r '.servers | keys[]' "$servers")
else
  log "⚠️  no $servers or jq missing; skipped MCP fan-out"
fi

echo "==> cross-tool wiring done."
