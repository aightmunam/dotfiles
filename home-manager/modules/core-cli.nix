# Core shell + CLI: zsh and its rc files, modern CLI replacements, and
# system/networking utilities. Wanted on every machine, headless or not.
{ config, pkgs, ... }:
let
  repoRoot = "${config.home.homeDirectory}/dotfiles";
  link = path: config.lib.file.mkOutOfStoreSymlink "${repoRoot}/${path}";
in
{
  home.packages = with pkgs; [
    # Core CLI tools
    atuin
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

    # Shell. Plugins are sourced by .zshrc from ~/.nix-profile/share/zsh; no framework.
    zsh
    zsh-autosuggestions
    zsh-fast-syntax-highlighting
  ];

  home.file = {
    ".dircolors".source = link ".dircolors";
    # zsh files are live symlinks like everything else: the .zshrc self-manages
    # all shell integration (prompt, plugins, atuin, zoxide, direnv, nix PATH), so
    # home-manager's programs.zsh is not used and there is no ownership conflict.
    ".zshrc".source = link ".zshrc";
    ".zshenv".source = link ".zshenv";
    ".zsh_functions".source = link ".zsh_functions";
    ".zsh_prompt".source = link ".zsh_prompt";
    # Only the file: atuin keeps its key and session files next to it.
    ".config/atuin/config.toml".source = link "atuin/config.toml";
  };
}
