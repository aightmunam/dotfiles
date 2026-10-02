# Cross-tool AI agent config — design

**Status:** approved design, pre-implementation
**Date:** 2026-09-25
**Repo:** `~/dotfiles`
**Goal:** maintain one source of truth for AI-coding-agent configuration and reuse it across **Claude Code**, **Gemini CLI**, and **Codex CLI**.

## Problem

Today all agent config lives under `~/dotfiles/claude/` and targets Claude Code only (skills, subagents, commands, hooks, output-styles, instructions, MCP). The same user also runs Gemini CLI and Codex CLI and wants to stop maintaining the shared parts three times. Copy-paste drift is a documented failure mode (instructions silently diverging between tools), so the shared content needs a single source.

## Approach: minimal hybrid (build, don't buy)

Lean on the two open standards the ecosystem has converged on — **`AGENTS.md`** (instructions) and **`SKILL.md`** (skills), both read natively by all three tools — and add a **thin generator** only for the legs that have no cross-tool standard (MCP) or no cross-tool support yet (subagents). Format-identical things are symlinked or `@import`ed (live-editable); only divergent things are generated.

Surveyed sync tools (ruler, rulesync, agentsmesh, skillshare, vercel `npx skills`, mcp-sync) were rejected as the primary mechanism: ruler's own maintainer recommends against sync tools now that the standards exist; the generate-only tools lose live editing and add an external dependency with active bug churn; `npx skills`' per-skill symlinking is the single most-reported bug class. We reuse the *ideas* (canonical dir + generator for MCP) but own ~50 lines of glue instead of adopting a 40-tool framework.

## Verified tool capabilities (empirical, on this machine — docs were unreliable)

Confirmed by CLI introspection + live behavioral tests, not documentation:

| Capability | Claude Code 2.1.281 | Gemini CLI 0.60.0 | Codex CLI 0.155.1 |
|---|---|---|---|
| Instructions file | `CLAUDE.md` (+ `@import`; AGENTS.md fallback when no CLAUDE.md, ≥2.1.277) | `GEMINI.md`; `AGENTS.md` via `context.fileName` | `AGENTS.md` (native) |
| Skills (`SKILL.md`) | ✅ `~/.claude/skills`, invoked via **`/skill-name`** (verified) *and* implicitly | ✅ `~/.gemini/skills`, `gemini skills` subcommand; **model-activated only, no `/name`** | ✅ `~/.codex/skills`, host discovery on (`skill_search` stable); **no `skills` subcommand**, invoked by name/implicitly (verified) |
| Custom commands | markdown `~/.claude/commands` (== skills surface) | **TOML** `~/.gemini/commands/*.toml` | markdown prompts (**deprecated** in favor of skills) |
| Subagents | ✅ `~/.claude/agents/*.md` (md+frontmatter) | ❌ none in 0.60.0 | ❌ none in 0.155.1 (`codex agents` = session browsing; `multi_agent` is internal orchestration) |
| MCP | `mcp add` (JSON `settings.json`/`~/.claude.json`) | `mcp add` (JSON `settings.json`) | `mcp add` (TOML `config.toml`) |

**Key corrections vs. the public docs:**
1. **Codex has no `skills` subcommand** in 0.155.1, but *does* discover and invoke skills from `~/.codex/skills` at runtime (behavioral test fired the marker).
2. **Gemini has no `/skill-name` explicit trigger** — skills are enabled then model-activated. It *does* have native `gemini skills install|link` (live-reflect).
3. **Neither Gemini 0.60.0 nor Codex 0.155.1 supports user-defined subagents** — the "generate Codex TOML subagents" idea from the docs does not apply to the installed versions.
4. **All three expose `mcp add`** with a near-identical `<name> <cmd|url> [args] -e K=V` shape — so MCP needs no JSON/TOML translation.

## Scope

**In:** instructions, skills, commands (→ skills), MCP servers, and canonical (Claude-only for now) subagents.
**Out:** hooks (event vocabularies/formats diverge per tool — kept tool-specific), output-styles (Claude-only concept).

## Directory layout

Rename `~/dotfiles/claude/` → `~/dotfiles/ai/` (neutral):

```
~/dotfiles/ai/
├─ AGENTS.md          canonical instructions — self-contained plain markdown
├─ rules/             rule snippets edited here, inlined into AGENTS.md
├─ agents/            canonical subagents (md + YAML frontmatter) — Claude-only today
├─ skills/            CUSTOM tracked skills (converted commands + hand-authored)
├─ mcp/servers.json   canonical MCP server list (neutral JSON, ${VAR} placeholders)
├─ generate.sh        the only generator: MCP fan-out + Gemini command wrappers + cross-tool symlinks
├─ install-skills.sh  installs third-party skills into ~/.agents/skills
├─ install-hooks.sh   Claude-only hooks (unchanged)
├─ claude/            Claude-ONLY: CLAUDE.md wrapper, settings.json, output-styles/, hooks/, statusline, rules/
├─ gemini/            Gemini-ONLY: settings.json (context.fileName)
└─ codex/             Codex-ONLY: config.toml base
```

## Per-leg design

### Instructions
- `ai/AGENTS.md` is **self-contained plain markdown** (rules inlined). `@import` is Claude-only, so the canonical file must not rely on it.
- **Claude:** `~/.claude/CLAUDE.md` = thin wrapper containing `@AGENTS.md` + Claude-only notes (e.g. rtk-hook detail); `~/.claude/AGENTS.md` → symlink to canonical. `@import` injects once (avoids the symlink double-read token waste).
- **Gemini:** `~/.gemini/GEMINI.md` → symlink to canonical.
- **Codex:** `~/.codex/AGENTS.md` → symlink to canonical.

### Skills
- Runtime store: **`~/.agents/skills`** (cross-tool convention).
  - Third-party skills → installed there by `install-skills.sh` (gitignored, not in repo).
  - Custom skills → tracked in `ai/skills/`, symlinked per-skill into `~/.agents/skills`.
- Each tool's skills dir = **whole-directory symlink** → `~/.agents/skills` (`~/.claude/skills` via home-manager; `~/.gemini/skills`, `~/.codex/skills` via `generate.sh`). Whole-dir, not per-skill, to avoid the `npx skills` symlink bugs.
- Self-healing: `install-skills.sh` / `generate.sh` recreate any missing/wrong tool symlink (extends the ENOTDIR fix already landed).
- Caveat: some sandboxed/cloud runners reject symlinked skill dirs; copy-mode is the fallback (not needed locally).

### Commands → skills
- Convert the (curated, in-use) commands to skills.
- **Claude:** `/name` invocation preserved (skills are slash-invocable — verified). **Codex:** invoked by name/implicitly. **Gemini:** model-activated; for explicit `/name` parity, `generate.sh` emits a thin `~/.gemini/commands/<name>.toml` per command-skill.
- Normalize argument placeholders (`$ARGUMENTS`/`$1`) during conversion.

### Subagents
- Only Claude supports user-defined subagents on the installed versions, so subagents stay **canonical but Claude-only**: `ai/agents/*.md` → symlink `~/.claude/agents`.
- Forward-compatible: if Gemini/Codex ship subagent support, the canonical md+frontmatter is ready to symlink/generate.
- Not eagerly duplicating the 7 into lossy skill form; convert individual ones to skills later only if genuinely wanted cross-tool.

### MCP
- Canonical `ai/mcp/servers.json`: `{ name, transport, command|url, args, env }` with `${VAR}` placeholders (no secrets in repo).
- `generate.sh` loops it and, for each of claude/gemini/codex, runs `<tool> mcp remove <name>` then `<tool> mcp add …` (idempotent). Each tool owns its own config format — no JSON/TOML translation.
- Claude's current `approvals` + `sentry` move out of the tracked `settings.json` into `servers.json` (single source), pushed to all three.
- `${VAR}` placeholders passed literally so each tool expands secrets at runtime.

## Wiring

**home-manager** (owns `~/.claude` + canonical repo files; declarative + live):
- Repoint all `~/.claude/*` symlinks from `claude/` to `ai/…`.
- `~/.claude/skills` → `~/.agents/skills` (retargeted).
- `~/.claude/settings.json` → `ai/claude/settings.json` with the `mcpServers` block removed.

**`generate.sh`** (owns `~/.gemini` + `~/.codex` wiring; run in `make post-install`):
- Instruction + skills symlinks into Gemini/Codex.
- MCP fan-out via `mcp add`.
- Gemini `/name` command wrappers.
- Self-heal all cross-tool symlinks.

**`.gitignore` / tracking:** track `AGENTS.md`, `rules/`, `agents/`, `skills/` (custom), `mcp/servers.json`, `generate.sh`, install scripts, `claude/`, `gemini/`, `codex/` bases. Ignore third-party installed skills (they live outside the repo in `~/.agents`) and tool-managed hooks (as today).

**`make` wiring:** `post-install` runs `install-skills.sh` (populate `~/.agents/skills` + link custom skills) then `generate.sh` (cross-tool symlinks + MCP + Gemini wrappers).

**Drift guard:** `make verify-ai` checks every canonical symlink resolves and each tool's `mcp list` matches `servers.json`.

## Migration (high level)
1. `git mv claude ai`; move Claude-only files under `ai/claude/`; split `CLAUDE.md`/`RTK.md`/`rules` content into a self-contained `ai/AGENTS.md` + a thin `ai/claude/CLAUDE.md` wrapper.
2. Update `home-manager/home.nix` symlink paths (`claude/` → `ai/…`, skills → `~/.agents/skills`) and `.gitignore`.
3. Add `ai/mcp/servers.json` (from current Claude `mcpServers`); remove the block from `settings.json`.
4. Write `generate.sh`; wire it into `Makefile` `post-install`; add `make verify-ai`.
5. Convert curated commands to skills under `ai/skills/`.
6. Reconcile `~/.agents/skills` (currently 3) with `~/.claude/skills` (17) onto the shared store.
7. Test fresh-machine flow in the Linux sandbox (as done for the herdr work).

## Risks & mitigations
- **Gemini trusted-folder gate / spend-cap:** headless Gemini refuses untrusted dirs and its API project is currently over its monthly spend cap — affects automated Gemini runs, not the config design. Note in docs.
- **`mcp add` writing secrets literally:** always pass `${VAR}` placeholders; verify each tool expands them at runtime (Codex TOML expansion to confirm during implementation).
- **Symlinked skill dirs rejected by some sandboxes:** copy-mode fallback documented.
- **Drift:** `make verify-ai` in CI/manually.

## Open questions (resolve during implementation)
- Codex `${VAR}` env expansion in `config.toml` — confirm behavior; fall back to `mcp add` per-machine if it stores literals.
- Which commands convert to skills vs. drop (some were already found unused).
- Whether to also manage `~/.gemini`/`~/.codex` instruction+skill symlinks via home-manager instead of `generate.sh` (kept in `generate.sh` here to avoid home-manager touching those tools' runtime state).
