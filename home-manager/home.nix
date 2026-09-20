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
  # Store-copy a repo-relative file (needs `make build` to pick up edits). Used
  # only for files that home-manager's own modules co-manage (see zsh note).
  copy = relpath: name: builtins.path { path = "${repoRoot}/${relpath}"; inherit name; };
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
      # .zshrc/.zshenv are store-copied, NOT out-of-store symlinked: home-manager's
      # programs.zsh co-manages them, and an out-of-store symlink fails the build
      # ("Error installing file outside $HOME"). Editing these two needs
      # `make build`. .zsh_functions is your own file (not touched by the zsh
      # module), so it stays live-editable.
      ".zshrc".source = copy ".zshrc" "zshrc";
      ".zshenv".source = copy ".zshenv" "zshenv";
      ".zsh_functions".source = link ".zsh_functions";
      ".config/nvim".source = link "nvim";
      ".config/wezterm".source = link "wezterm";
      ".config/nix".source = link "nix";
      ".config/home-manager".source = link "home-manager";

      # --- Claude Code (new) ---
      ".claude/skills".source = link "claude/skills";
      ".claude/agents".source = link "claude/agents";
      ".claude/commands".source = link "claude/commands";
      ".claude/hooks".source = link "claude/hooks";
      ".claude/output-styles".source = link "claude/output-styles";
      ".claude/rules".source = link "claude/rules";
      ".claude/CLAUDE.md".source = link "claude/CLAUDE.md";
      ".claude/RTK.md".source = link "claude/RTK.md";
      ".claude/settings.json".source = link "claude/settings.json";
      ".claude/statusline-command.sh".source = link "claude/statusline-command.sh";

      # --- herdr (new) ---
      ".config/herdr/config.toml".source = link "herdr/config.toml";
    } // lib.optionalAttrs isDarwin {
      # macOS-only files
      ".config/aerospace".source = link "aerospace";
      "raycast-scripts".source = link "raycast-scripts";
      "Applications/Raycast.app".source = "${pkgs.raycast}/Applications/Raycast.app";
    };
  };

  programs = {
    autojump.enable = true;
    fzf.enable = true;
    direnv.enable = true;      # hooks zsh automatically; replaces autoenv
    home-manager.enable = true;
    zsh = {
      enable = true;
      initExtra = ''
        # Add any additional configurations here
        export PATH=/run/current-system/sw/bin:$HOME/.nix-profile/bin:$PATH
        if [ -e '/nix/var/nix/profiles/default/etc/profile.d/nix-daemon.sh' ]; then
          . '/nix/var/nix/profiles/default/etc/profile.d/nix-daemon.sh'
        fi
      '';
    };
  };
}
