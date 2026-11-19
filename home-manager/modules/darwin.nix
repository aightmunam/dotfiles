# macOS-only packages and files. Everything here is guarded by isDarwin so the
# same module list evaluates cleanly on Linux.
# (Not to be confused with ../darwin.nix, a vestigial nix-darwin experiment.)
{ config, inputs, repoRoot, lib, pkgs, ... }:
let
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

    launchd.agents.rig-thoughts-sync = {
      enable = true;
      config = {
        ProgramArguments = [
          "${inputs.rig.packages.${pkgs.stdenv.hostPlatform.system}.default}/bin/rig"
          "thoughts"
          "sync"
        ];
        StartInterval = 3600;
        RunAtLoad = true;
        StandardOutPath = "${config.home.homeDirectory}/Library/Logs/rig-thoughts-sync.launchd.log";
        StandardErrorPath = "${config.home.homeDirectory}/Library/Logs/rig-thoughts-sync.launchd.log";
      };
    };
  };
}
