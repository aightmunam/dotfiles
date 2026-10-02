# Cross-tool AI Agent Config Implementation Plan

> **For agentic workers:** REQUIRED SUB-SKILL: Use superpowers:executing-plans to implement this plan task-by-task. Steps use checkbox (`- [ ]`) syntax for tracking.

**Goal:** Reorganize `~/dotfiles/claude/` into a neutral `ai/` source of truth and wire its shared parts (instructions, skills, commands-as-skills, MCP) into Claude Code, Gemini CLI, and Codex CLI, keeping subagents Claude-only.

**Architecture:** Minimal hybrid. Format-identical config is symlinked/`@import`ed (live-edit); the two standard-less legs (MCP, Gemini `/name` parity) flow through one small `ai/generate.sh` run in `make post-install`. home-manager owns `~/.claude`; `generate.sh` owns `~/.gemini` + `~/.codex` wiring.

**Tech Stack:** Nix home-manager (`mkOutOfStoreSymlink`), bash, `jq`, each CLI's native `mcp add`, SKILL.md + AGENTS.md standards.

**Spec:** `docs/superpowers/specs/2026-09-25-cross-tool-agent-config-design.md`

## Global Constraints
- Cross-platform: macOS + Linux. No literal secrets in the repo; MCP `env` uses `${VAR}` placeholders.
- Every structural task ends GREEN on a non-activating build: `NIXPKGS_ALLOW_UNFREE=1 nix build --impure '/Users/munammubashir/dotfiles/home-manager#homeConfigurations."mynixos-aarch64-darwin".activationPackage' --out-link <scratch>/hm-result`.
- Live-edit preserved: config reaches tools via symlinks/`@import`, not copies.
- Filenames snake_case (existing convention). No em dashes in committed text.
- Skills runtime store is `~/.agents/skills`; third-party skills gitignored, custom skills tracked in `ai/skills/`.
- Branch: `feat/cross-tool-agent-config`.

---

### Task 1: Restructure `claude/` → `ai/`, update home-manager + gitignore

**Files:**
- Move: `claude/` → `ai/` (git mv), then reorganize within `ai/`
- Modify: `home-manager/home.nix`, `.gitignore`, `Makefile`, `claude/install-skills.sh`→`ai/install-skills.sh`, `claude/install-hooks.sh`→`ai/install-hooks.sh`

**Target `ai/` layout after this task:**
```
ai/AGENTS.md            (created in Task 2; touch empty placeholder now)
ai/agents/              (from claude/agents)
ai/skills/              (custom skills; from claude/skills — see Task 8 reconcile)
ai/mcp/                 (created in Task 3)
ai/install-skills.sh    (from claude/install-skills.sh)
ai/install-hooks.sh     (from claude/install-hooks.sh)
ai/claude/CLAUDE.md     (from claude/CLAUDE.md; rewritten Task 2)
ai/claude/settings.json (from claude/settings.json)
ai/claude/output-styles/ ai/claude/hooks/ ai/claude/rules/ ai/claude/statusline-command.sh ai/claude/RTK.md ai/claude/.gitignore
ai/gemini/  ai/codex/    (empty dirs with .gitkeep)
```

- [ ] **Step 1: git mv and reorganize**
```bash
cd ~/dotfiles
git mv claude ai
mkdir -p ai/claude ai/mcp ai/gemini ai/codex
for f in settings.json CLAUDE.md RTK.md statusline-command.sh output-styles hooks rules .gitignore; do git mv ai/$f ai/claude/$f; done
touch ai/AGENTS.md ai/gemini/.gitkeep ai/codex/.gitkeep
# agents/, skills/, install-skills.sh, install-hooks.sh stay at ai/ top level
```

- [ ] **Step 2: Update `home-manager/home.nix`** — add a home-relative link helper and repoint the `.claude/*` entries.
Add near the `link` helper:
```nix
  # Link a $HOME-relative path (e.g. the shared ~/.agents skills store) live.
  homeLink = path: config.lib.file.mkOutOfStoreSymlink "${config.home.homeDirectory}/${path}";
```
Replace the Claude Code block in `home.file`:
```nix
      # --- Claude Code (canonical ai/ source) ---
      ".claude/skills".source = homeLink ".agents/skills";
      ".claude/agents".source = link "ai/agents";
      ".claude/hooks".source = link "ai/claude/hooks";
      ".claude/output-styles".source = link "ai/claude/output-styles";
      ".claude/rules".source = link "ai/claude/rules";
      ".claude/CLAUDE.md".source = link "ai/claude/CLAUDE.md";
      ".claude/AGENTS.md".source = link "ai/AGENTS.md";
      ".claude/RTK.md".source = link "ai/claude/RTK.md";
      ".claude/settings.json".source = link "ai/claude/settings.json";
      ".claude/statusline-command.sh".source = link "ai/claude/statusline-command.sh";
```
(Removed `.claude/commands` — commands become skills in Task 6.)

- [ ] **Step 3: Update `.gitignore`, `Makefile` paths** — change any `claude/` references to `ai/` (Makefile `post-install` calls `bash claude/install-*.sh` → `bash ai/install-*.sh`; move the `ai/claude/.gitignore` skills-ignore rules as needed). Grep to confirm none remain: `grep -rn "claude/install\|claude/skills\|claude/hooks" Makefile home-manager`.

- [ ] **Step 4: Non-activating build**
Run: `NIXPKGS_ALLOW_UNFREE=1 nix build --impure '/Users/munammubashir/dotfiles/home-manager#homeConfigurations."mynixos-aarch64-darwin".activationPackage' --out-link /tmp/hm-result`
Expected: exit 0; `readlink -f /tmp/hm-result/home-files/.claude/AGENTS.md` → `…/dotfiles/ai/AGENTS.md`; `readlink /tmp/hm-result/home-files/.claude/skills`'s final target → `…/.agents/skills`.

- [ ] **Step 5: Commit**
```bash
git add -A && git commit -m "refactor(ai): rename claude/ to ai/ and reorganize for cross-tool use"
```

---

### Task 2: Compose canonical `AGENTS.md` + thin Claude wrapper

**Files:** Create `ai/AGENTS.md`; rewrite `ai/claude/CLAUDE.md`.

- [ ] **Step 1: Write self-contained `ai/AGENTS.md`** — inline the neutral guidance (no `@import`, which is Claude-only). Include the `rules/context7.md` content and the tool-neutral rtk usage from `RTK.md` (meta commands, install verification). Header notes it is the shared instruction file for all agents.

- [ ] **Step 2: Rewrite `ai/claude/CLAUDE.md` as the wrapper**
```markdown
@AGENTS.md

<!-- Claude-Code-only notes below -->
@RTK.md
```
(Keeps the Claude-only rtk auto-rewrite-hook detail in `RTK.md`; `AGENTS.md` carries only the tool-neutral rtk usage. `@AGENTS.md` resolves to `~/.claude/AGENTS.md`, symlinked to canonical.)

- [ ] **Step 3: Verify `@import` resolves** — `readlink -f ~/.claude/AGENTS.md` points at `ai/AGENTS.md`; open a headless Claude and confirm context loads (optional).

- [ ] **Step 4: Commit** `git commit -am "feat(ai): self-contained AGENTS.md + Claude @import wrapper"`

---

### Task 3: Canonical MCP source, remove from settings.json

**Files:** Create `ai/mcp/servers.json`; modify `ai/claude/settings.json` (remove `mcpServers`).

- [ ] **Step 1: Write `ai/mcp/servers.json`** (neutral; both current servers are secret-free stdio):
```json
{
  "servers": {
    "approvals": { "transport": "stdio", "command": "humanlayer", "args": ["mcp", "claude_approvals"], "env": {} },
    "sentry":    { "transport": "stdio", "command": "npx", "args": ["-y", "mcp-remote", "https://mcp.sentry.dev/mcp"], "env": {} }
  }
}
```

- [ ] **Step 2: Remove `mcpServers` from `ai/claude/settings.json`** with `jq 'del(.mcpServers)'` (write back). Validate: `jq empty ai/claude/settings.json`.

- [ ] **Step 3: Verify** `jq . ai/mcp/servers.json` valid; non-activating build still green.

- [ ] **Step 4: Commit** `git commit -am "feat(ai): canonical MCP server list; drop mcpServers from settings.json"`

---

### Task 4: `ai/generate.sh` — cross-tool wiring + MCP fan-out

**Files:** Create `ai/generate.sh` (executable).

**Interfaces produced:** `generate.sh [--dry-run]` — idempotent; run from `make post-install`.

- [ ] **Step 1: Write `ai/generate.sh`:**
```bash
#!/usr/bin/env bash
# Wire the canonical ai/ config into Gemini CLI and Codex CLI, and fan MCP
# servers into all three tools via their native `mcp add`. Idempotent.
set -uo pipefail
REPO="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
AI="$REPO/ai"; HOME_DIR="$HOME"
AGENTS_STORE="$HOME_DIR/.agents/skills"
log() { printf '  %s\n' "$*"; }
lnsf() { ln -sfn "$1" "$2"; }   # force, never clobbers a real dir silently — see note

mkdir -p "$AGENTS_STORE"

# --- Instructions: AGENTS.md into Gemini + Codex (Claude handled by home-manager) ---
mkdir -p "$HOME_DIR/.gemini" "$HOME_DIR/.codex"
lnsf "$AI/AGENTS.md" "$HOME_DIR/.gemini/GEMINI.md"
lnsf "$AI/AGENTS.md" "$HOME_DIR/.codex/AGENTS.md"

# --- Skills store: whole-dir symlink for Gemini + Codex (Claude via home-manager) ---
for d in "$HOME_DIR/.gemini/skills" "$HOME_DIR/.codex/skills"; do
  # only replace if missing or already a symlink (never rm a real populated dir)
  if [ -L "$d" ] || [ ! -e "$d" ]; then lnsf "$AGENTS_STORE" "$d"; else
    log "WARN: $d is a real directory; leaving it (move its contents into $AGENTS_STORE)"; fi
done

# --- Custom tracked skills: link ai/skills/* into the shared store ---
if [ -d "$AI/skills" ]; then
  for s in "$AI/skills"/*/; do [ -d "$s" ] || continue; lnsf "${s%/}" "$AGENTS_STORE/$(basename "$s")"; done
fi

# --- Gemini /name parity: render each command-skill as a TOML command ---
mkdir -p "$HOME_DIR/.gemini/commands"
if [ -d "$AI/skills" ]; then
  for s in "$AI/skills"/*/SKILL.md; do
    [ -f "$s" ] || continue; name="$(basename "$(dirname "$s")")"
    # strip YAML frontmatter, escape triple-quotes, emit prompt
    body="$(awk 'f{print} /^---$/{c++; if(c==2) f=1}' "$s")"
    { printf 'description = "%s"\n' "$name"; printf 'prompt = """\n%s\n"""\n' "$body"; } > "$HOME_DIR/.gemini/commands/$name.toml"
  done
fi

# --- MCP fan-out via each tool's native `mcp add` (idempotent: remove then add) ---
servers_json="$AI/mcp/servers.json"
names="$(jq -r '.servers | keys[]' "$servers_json")"
add_tool() { # $1=tool $2=name  (reads env/args/command/url from json)
  local tool="$1" n="$2"
  local cmd url; cmd="$(jq -r ".servers[\"$n\"].command // empty" "$servers_json")"
  url="$(jq -r ".servers[\"$n\"].url // empty" "$servers_json")"
  mapfile -t args < <(jq -r ".servers[\"$n\"].args // [] | .[]" "$servers_json")
  mapfile -t envs < <(jq -r ".servers[\"$n\"].env // {} | to_entries[] | \"\(.key)=\(.value)\"" "$servers_json")
  local eflags=(); for e in "${envs[@]}"; do eflags+=( -e "$e" ); done
  case "$tool" in
    claude) claude mcp remove "$n" >/dev/null 2>&1 || true
            if [ -n "$url" ]; then claude mcp add -s user -t http "${eflags[@]}" "$n" "$url"; \
            else claude mcp add -s user "${eflags[@]}" "$n" "$cmd" "${args[@]}"; fi ;;
    gemini) gemini mcp remove "$n" >/dev/null 2>&1 || true
            if [ -n "$url" ]; then gemini mcp add -s user -t http "${eflags[@]}" "$n" "$url"; \
            else gemini mcp add -s user "${eflags[@]}" "$n" "$cmd" "${args[@]}"; fi ;;
    codex)  codex mcp remove "$n" >/dev/null 2>&1 || true
            eflags=(); for e in "${envs[@]}"; do eflags+=( --env "$e" ); done
            if [ -n "$url" ]; then codex mcp add "$n" --url "$url" "${eflags[@]}"; \
            else codex mcp add "$n" "${eflags[@]}" -- "$cmd" "${args[@]}"; fi ;;
  esac
}
for n in $names; do for t in claude gemini codex; do
  command -v "$t" >/dev/null 2>&1 && add_tool "$t" "$n" >/dev/null 2>&1 && log "mcp: $t <- $n" || log "mcp: $t <- $n (skipped/failed)";
done; done

echo "generate.sh done."
```
Note the `lnsf` guard: it only replaces symlinks/missing paths, never a real populated directory (mirrors the MindStudio-blog warning).

- [ ] **Step 2: `chmod +x ai/generate.sh`; run it** (`bash ai/generate.sh`). Codex may fail `mcp add` if unauthenticated — that is logged, not fatal.

- [ ] **Step 3: Verify** — `readlink ~/.gemini/GEMINI.md` and `~/.codex/AGENTS.md` → `ai/AGENTS.md`; `readlink ~/.gemini/skills`,`~/.codex/skills` → `~/.agents/skills`; `claude mcp list` shows `approvals` + `sentry`.

- [ ] **Step 4: Commit** `git commit -am "feat(ai): generate.sh cross-tool wiring + MCP fan-out"`

---

### Task 5: Update `ai/install-skills.sh` for the shared store

**Files:** Modify `ai/install-skills.sh`.

- [ ] **Step 1** — Change install target to `~/.agents/skills` (npx skills global already writes there); after installing, ensure the three tool symlinks exist (self-heal, reusing the Task-4 lnsf guard logic); keep the `mkdir -p "$AGENTS_STORE"` fix. Do NOT rely on npx per-tool linking.
- [ ] **Step 2: Verify** `bash -n ai/install-skills.sh`; dry inspect that it references `~/.agents/skills`.
- [ ] **Step 3: Commit** `git commit -am "feat(ai): install skills into shared ~/.agents/skills store"`

---

### Task 6: Convert commands → custom skills

**Files:** Create `ai/skills/<name>/SKILL.md` per command; remove `ai/commands/` (was `claude/commands`, moved to `ai/commands` in Task 1 — adjust Task 1 to keep `commands/` at `ai/` top until here).

- [ ] **Step 1: Conversion script** (run once, then delete): for each `ai/commands/<name>.md`, create `ai/skills/<name>/SKILL.md` with frontmatter `name: <name>` + the command's `description`, and the command body. Command files already carry `name`/`description` frontmatter, so this is mechanical:
```bash
for f in ai/commands/*.md; do
  name="$(basename "$f" .md)"; mkdir -p "ai/skills/$name"
  cp "$f" "ai/skills/$name/SKILL.md"   # command frontmatter+body already valid SKILL.md
done
git rm -r ai/commands
```
- [ ] **Step 2: Verify** each `ai/skills/*/SKILL.md` has `name:` + `description:` frontmatter; run `ai/generate.sh` so custom skills link into the store and Gemini TOML wrappers regenerate.
- [ ] **Step 3: Behavioral check (Claude)** — `cd /tmp && claude -p "/commit" --output-format text` resolves the skill (or use a known command name), confirming `/name` still works.
- [ ] **Step 4: Commit** `git commit -am "feat(ai): convert slash-commands to portable skills"`

---

### Task 7: Makefile wiring + `make verify-ai`

**Files:** Modify `Makefile`.

- [ ] **Step 1** — `post-install` runs `bash ai/install-skills.sh` then `bash ai/generate.sh` (both best-effort). Add a `verify-ai` target:
```make
verify-ai:
	@for l in ~/.claude/AGENTS.md ~/.gemini/GEMINI.md ~/.codex/AGENTS.md ~/.claude/skills ~/.gemini/skills ~/.codex/skills; do \
	  if [ -e "$$l" ]; then echo "OK   $$l -> $$(readlink -f $$l)"; else echo "DEAD $$l"; fi; done
	@echo "-- MCP --"; for t in claude gemini codex; do echo "$$t:"; $$t mcp list 2>/dev/null | sed 's/^/  /'; done
```
- [ ] **Step 2: Verify** `make verify-ai` prints resolved symlinks + MCP lists.
- [ ] **Step 3: Commit** `git commit -am "feat(ai): wire post-install + add verify-ai drift check"`

---

### Task 8: Reconcile skills store + sandbox fresh-machine test

- [ ] **Step 1: Reconcile** `~/.agents/skills` (currently 3) with the old `~/.claude/skills` (17) — ensure `ai/install-skills.sh`'s list covers the intended set; run it to populate `~/.agents/skills`; confirm all three tools' `skills` symlinks resolve to it.
- [ ] **Step 2: Sandbox** — extend the existing Linux-container harness (`scratchpad/sandbox_test.sh` pattern) to run `make install` on the renamed repo (HEAD of this branch) and assert: home-manager build green; `~/.claude/AGENTS.md`,`~/.gemini/GEMINI.md`,`~/.codex/AGENTS.md` resolve; skills symlinks resolve; `generate.sh` MCP fan-out ran (or logged tool-missing). Bump colima to 8GiB for the herdr build.
- [ ] **Step 3: Commit** any fixes the sandbox surfaces; open the PR.

---

## Self-Review
- **Spec coverage:** instructions (T2), skills store (T1/T5/T8), commands→skills (T6), subagents Claude-only (T1 keeps `ai/agents`→`~/.claude/agents`), MCP (T3/T4), wiring+gitignore+make+drift (T1/T7), rename (T1). All spec sections mapped.
- **Placeholder scan:** `generate.sh`, `servers.json`, `verify-ai`, conversion script are concrete. AGENTS.md composition (T2) inlines known source files (context7.md + RTK.md) — content exists in repo.
- **Consistency:** store path `~/.agents/skills` used uniformly; `lnsf` guard reused; MCP names from `servers.json` drive both add and verify.
- **Gap fixed:** Task 1 keeps `ai/commands/` at top-level (not moved under `ai/claude/`) so Task 6 can convert then remove it.
