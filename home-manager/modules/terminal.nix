# Terminal emulator, multiplexer, editors, and the fonts they render with.
{ config, lib, pkgs, ... }:
let
  repoRoot = "${config.home.homeDirectory}/dotfiles";
  link = path: config.lib.file.mkOutOfStoreSymlink "${repoRoot}/${path}";
in
{
  home.packages = with pkgs; [
    tmux
    neovim
    opencode

    # Fonts
    nerd-fonts._0xproto
    nerd-fonts.hack
    nerd-fonts.meslo-lg
    nerd-fonts.monaspace
    nerd-fonts.mononoki
  ]
  # Clipboard provider for nvim's unnamedplus and the pbcopy shim (macOS has pbcopy built in)
  ++ lib.optionals pkgs.stdenv.isLinux [ wl-clipboard ]
  # On non-NixOS Linux the Nix wezterm can't find the GPU drivers (EGL panic at
  # startup), so it comes from the distro there: pacman -S wezterm
  ++ lib.optionals pkgs.stdenv.isDarwin [ wezterm ];

  home.file = {
    ".tmux.conf".source = link "tmux/.tmux.conf";
    ".vimrc".source = link ".vimrc";
    ".config/nvim".source = link "nvim";
    ".config/wezterm".source = link "wezterm";
  };
}
