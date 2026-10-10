# Git and its ecosystem tooling + config links.
{ config, pkgs, ... }:
let
  repoRoot = "${config.home.homeDirectory}/dotfiles";
  link = path: config.lib.file.mkOutOfStoreSymlink "${repoRoot}/${path}";
in
{
  home.packages = with pkgs; [
    git
    gh          # GitHub CLI
    delta       # Better git diff
    difftastic
    lazygit
  ];

  home.file = {
    ".gitconfig".source = link "git/.gitconfig";
    ".gitignore_global".source = link "git/.gitignore_global";
  };
}
