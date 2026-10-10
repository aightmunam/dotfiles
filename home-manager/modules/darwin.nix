# macOS-only packages and files. Everything here is guarded by isDarwin so the
# same module list evaluates cleanly on Linux.
# (Not to be confused with ../darwin.nix, a vestigial nix-darwin experiment.)
{ config, lib, pkgs, ... }:
let
  repoRoot = "${config.home.homeDirectory}/dotfiles";
  link = path: config.lib.file.mkOutOfStoreSymlink "${repoRoot}/${path}";
in
{
  config = lib.mkIf pkgs.stdenv.isDarwin {
    home.packages = with pkgs; [
      # macOS-only packages (would fail to evaluate on Linux)
      aerospace
      jankyborders
      reattach-to-user-namespace
    ];

    home.file = {
      ".config/aerospace".source = link "aerospace";
      "raycast-scripts".source = link "raycast-scripts";
      "Applications/Raycast.app".source = "${pkgs.raycast}/Applications/Raycast.app";
    };
  };
}
