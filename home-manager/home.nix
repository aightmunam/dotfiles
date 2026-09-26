# Portable home-manager module (macOS + Linux).
#
# This is a pure module: the per-system `pkgs` and the `homeManagerConfiguration`
# wiring live in flake.nix (see `mkHome`). `inputs` and `username` are passed via
# extraSpecialArgs.
#
# Config files are linked with `mkOutOfStoreSymlink`, i.e. they point at the LIVE
# repo checkout (~/dotfiles), not a read-only copy in the Nix store. Editing any
# linked file (nvim, wezterm, tmux, zsh, Claude skills/hooks, herdr, ...) takes
# effect immediately with NO rebuild. `home-manager switch` is only needed to
# change which paths are linked or which packages/programs are installed.
{ inputs, username, config, lib, pkgs, ... }:
let
  isDarwin = pkgs.stdenv.isDarwin;
  # Absolute path to the live checkout. Assumes the repo is cloned to ~/dotfiles.
  repoRoot = "${config.home.homeDirectory}/dotfiles";
  # Link a repo-relative path into $HOME as a writable, out-of-store symlink.
  link = path: config.lib.file.mkOutOfStoreSymlink "${repoRoot}/${path}";
  # Link a $HOME-relative path (e.g. the shared ~/.agents skills store) live.
  homeLink = path: config.lib.file.mkOutOfStoreSymlink "${config.home.homeDirectory}/${path}";
in
{
  home = {
    username = username;
    homeDirectory = if isDarwin then "/Users/${username}" else "/home/${username}";
    stateVersion = "25.11";

    sessionPath = [
      "/run/current-system/sw/bin"
      "$HOME/.nix-profile/bin"
    ];
    sessionVariables = { };

    packages = with pkgs; [
      # Core CLI tools
      autojump
      bat
      coreutils
      dust
      eza
      fd
      findutils
      fzf
      gawk
      gnugrep
      gzip
      ripgrep
      tree
      zoxide

      # System utilities and networking
      curl
      btop
      mosh
      netcat
      nmap
      wget

      # Development tools
      gh          # GitHub CLI
      delta       # Better git diff
      tldr        # Better man pages
      duf         # Better df
      difftastic
      direnv      # per-directory env (hooked directly in .zshrc)
      git
      go
      jq
      lazygit
      lua
      pyenv
      tmux
      tree-sitter
      yq

      # Terminal and shell
      zsh
      wezterm
      neovim
      opencode

      # AI coding toolchain
      herdr       # terminal agent multiplexer (from inputs.herdr overlay)
      nodejs      # npx-based MCP servers + npx skills (install-skills.sh)
      uv          # uvx-based MCP servers (ast-editor)
      pipx        # installs `headroom` (headroom MCP) in the post-install step
      python3
      gnupg

      # Fonts
      nerd-fonts._0xproto
      nerd-fonts.hack
      nerd-fonts.meslo-lg
      nerd-fonts.monaspace
      nerd-fonts.mononoki
    ] ++ lib.optionals isDarwin [
      # macOS-only packages (would fail to evaluate on Linux)
      aerospace
      jankyborders
      reattach-to-user-namespace
    ];

    file = {
      # --- Existing dotfiles (now live/out-of-store symlinks) ---
      ".dircolors".source = link ".dircolors";
      ".gitconfig".source = link "git/.gitconfig";
      ".gitignore_global".source = link "git/.gitignore_global";
      ".tmux.conf".source = link "tmux/.tmux.conf";
      ".vimrc".source = link ".vimrc";
      # zsh files are live symlinks like everything else: the .zshrc self-manages
      # all shell integration (p10k, oh-my-zsh, fzf, zoxide, direnv, nix PATH), so
      # home-manager's programs.zsh is not used and there is no ownership conflict.
      ".zshrc".source = link ".zshrc";
      ".zshenv".source = link ".zshenv";
      ".zsh_functions".source = link ".zsh_functions";
      ".config/nvim".source = link "nvim";
      ".config/wezterm".source = link "wezterm";
      ".config/nix".source = link "nix";
      ".config/home-manager".source = link "home-manager";

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

      # --- herdr (new) ---
      ".config/herdr/config.toml".source = link "herdr/config.toml";
    } // lib.optionalAttrs isDarwin {
      # macOS-only files
      ".config/aerospace".source = link "aerospace";
      "raycast-scripts".source = link "raycast-scripts";
      "Applications/Raycast.app".source = "${pkgs.raycast}/Applications/Raycast.app";
    };
  };

  # home-manager manages itself. All shell integration (zsh, fzf, direnv, autojump,
  # zoxide, nix PATH) is handled directly in the live .zshrc, so no program modules
  # are used for it — they only generated init that .zshrc already overrides. Their
  # binaries come from home.packages above.
  programs.home-manager.enable = true;
}
