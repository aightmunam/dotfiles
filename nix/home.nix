{ inputs, ... }@flakeContext:
let
    dotfilesDir = builtins.path { path = ../.; };
    homeModule = { config, lib, pkgs, ... }: {
        config = {
            home = {
                file = {
                    ".dircolors" = {
                        source = "${dotfilesDir}/.dircolors";
                    };
                    ".gitconfig" = {
                        source = "${dotfilesDir}/git/.gitconfig";
                    };
                    ".gitignore_global" = {
                        source = "${dotfilesDir}/git/.gitignore_global";
                    };
                    ".tmux.conf" = {
                        source = "${dotfilesDir}/tmux/.tmux.conf";
                    };
                    ".vimrc" = {
                        source = "${dotfilesDir}/.vimrc";
                    };
                    ".zshrc" = {
                        source = "${dotfilesDir}/.zshrc";
                    };
                    nvim = {
                        source = "${dotfilesDir}/nvim";
                    };
                    wezterm = {
                        source = "${dotfilesDir}/wezterm";
                    };
                };
                packages = [
                    pkgs.neovim
                    pkgs.tree-sitter
                    pkgs.tmux
                    pkgs.reattach-to-user-namespace
                    pkgs.wezterm
                    pkgs.lua
                    pkgs.freetype
                    pkgs.go
                    pkgs.git
                    pkgs.fzf
                    pkgs.htop
                    pkgs.ripgrep
                    pkgs.fd
                    pkgs.curl
                    pkgs.wget
                    pkgs.bat
                    pkgs.autojump
                    pkgs.pyenv
                    pkgs.lazygit
                    pkgs.nerd-fonts.hack
                    pkgs.nerd-fonts._0xproto
                    pkgs.meslo-lgs-nf
                    pkgs.nerd-fonts.meslo-lg
                ];
                stateVersion = "25.11";
                username = "aightmunam";
                homeDirectory = "/Users/aightmunam/";
            };
            programs = {
                autojump = {
                    enable = true;
                };
                fzf = {
                    enable = true;
                };
                home-manager = {
                    enable = true;
                };
            };
        };
    };
    nixosModule = { ... }: {
        home-manager.users.mynixos = homeModule;
    };
in
    (
    (
        inputs.home-manager.lib.homeManagerConfiguration {
            modules = [
                homeModule
            ];
            pkgs = inputs.nixpkgs.legacyPackages.aarch64-darwin;
        }
    ) // { inherit nixosModule;
    }
)
