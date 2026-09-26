# AI coding toolchain: Claude Code wiring (canonical ai/ source; shared skills
# store in ~/.agents), herdr, and the runtimes MCP servers/skills depend on.
# The non-Nix half (npx skills, hooks, Gemini/Codex fan-out) lives in
# `make post-install` -> ai/*.sh.
{ config, pkgs, ... }:
let
  repoRoot = "${config.home.homeDirectory}/dotfiles";
  # Link a repo-relative path into $HOME as a writable, out-of-store symlink.
  link = path: config.lib.file.mkOutOfStoreSymlink "${repoRoot}/${path}";
  # Link a $HOME-relative path (e.g. the shared ~/.agents skills store) live.
  homeLink = path: config.lib.file.mkOutOfStoreSymlink "${config.home.homeDirectory}/${path}";
in
{
  home.packages = with pkgs; [
    herdr       # terminal agent multiplexer (from inputs.herdr overlay)
    nodejs      # npx-based MCP servers + npx skills (install-skills.sh)
    uv          # uvx-based MCP servers (ast-editor)
    pipx        # installs `headroom` (headroom MCP) in the post-install step
    python3
    gnupg
  ];

  home.file = {
    # --- Claude Code (canonical ai/ source; shared skills store in ~/.agents) ---
    ".claude/skills".source = homeLink ".agents/skills";
    ".claude/agents".source = link "ai/agents";
    ".claude/hooks".source = link "ai/claude/hooks";
    ".claude/output-styles".source = link "ai/claude/output-styles";
    ".claude/CLAUDE.md".source = link "ai/claude/CLAUDE.md";
    ".claude/AGENTS.md".source = link "ai/AGENTS.md";
    # NOTE: settings.json is intentionally NOT symlinked. It holds machine-local
    # and confidential content (org context, env) and Claude Code writes to it at
    # runtime; a symlink would drop those on activation and leak runtime writes
    # into this public repo. `make post-install` copies the sanitized template
    # (ai/claude/settings.json) only when ~/.claude/settings.json is missing.
    ".claude/statusline-command.sh".source = link "ai/claude/statusline-command.sh";

    # --- herdr ---
    ".config/herdr/config.toml".source = link "herdr/config.toml";
  };
}
