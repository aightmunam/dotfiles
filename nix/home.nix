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
                    "Applications/Raycast.app".source = "${pkgs.raycast}/Applications/Raycast.app";
                };
                packages = with pkgs; [
                    neovim
                    tree-sitter
                    tmux
                    reattach-to-user-namespace
                    wezterm
                    lua
                    freetype
                    go
                    git
                    fzf
                    htop
                    ripgrep
                    fd
                    curl
                    wget
                    bat
                    autojump
                    pyenv
                    lazygit
                    nerd-fonts.hack
                    nerd-fonts._0xproto
                    meslo-lgs-nf
                    nerd-fonts.meslo-lg
                    raycast
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
            home.activation.refreshLaunchServices = lib.hm.dag.entryAfter [ "writeBoundary" ] ''
                /System/Library/Frameworks/CoreServices.framework/Frameworks/LaunchServices.framework/Support/lsregister \
                    -f ${pkgs.raycast}/Applications/Raycast.app
            '';
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
