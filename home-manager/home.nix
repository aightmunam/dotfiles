# Portable home-manager entrypoint (macOS + Linux).
#
# This is a pure module: the per-system `pkgs` and the `homeManagerConfiguration`
# wiring live in flake.nix (see `mkHome`). `inputs` and `username` are passed via
# extraSpecialArgs.
#
# Everything tool-specific lives in modules/ — one file per concern, each
# contributing its own `home.packages` and `home.file` entries (the module
# system merges them). A future machine profile can import a subset.
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
  link = path: config.lib.file.mkOutOfStoreSymlink "${repoRoot}/${path}";
in
{
  imports = [
    ./modules/core-cli.nix
    ./modules/git.nix
    ./modules/dev.nix
    ./modules/terminal.nix
    ./modules/ai.nix
    ./modules/darwin.nix
  ];

  home = {
    username = username;
    homeDirectory = if isDarwin then "/Users/${username}" else "/home/${username}";
    stateVersion = "25.11";

    sessionPath = [
      "/run/current-system/sw/bin"
      "$HOME/.nix-profile/bin"
    ];
    sessionVariables = { };

    # Nix / home-manager's own config; everything else lives in modules/.
    file = {
      ".config/nix".source = link "nix";
      ".config/home-manager".source = link "home-manager";
    };
  };

  # home-manager manages itself. All shell integration (zsh, fzf, direnv, autojump,
  # zoxide, nix PATH) is handled directly in the live .zshrc, so no program modules
  # are used for it — they only generated init that .zshrc already overrides. Their
  # binaries come from home.packages in the modules.
  programs.home-manager.enable = true;
}
