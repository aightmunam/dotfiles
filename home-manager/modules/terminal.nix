# Terminal emulator, multiplexer, editors, and the fonts they render with.
{ config, pkgs, ... }:
let
  repoRoot = "${config.home.homeDirectory}/dotfiles";
  link = path: config.lib.file.mkOutOfStoreSymlink "${repoRoot}/${path}";
in
{
  home.packages = with pkgs; [
    wezterm
    tmux
    neovim
    opencode

    # Fonts
    nerd-fonts._0xproto
    nerd-fonts.hack
    nerd-fonts.meslo-lg
    nerd-fonts.monaspace
    nerd-fonts.mononoki
  ];

  home.file = {
    ".tmux.conf".source = link "tmux/.tmux.conf";
    ".vimrc".source = link ".vimrc";
    ".config/nvim".source = link "nvim";
    ".config/wezterm".source = link "wezterm";
  };
}
