{ inputs, username, ... }@flakeContext:
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
                    # Core CLI tools
                    autojump
                    bat
                    coreutils
                    du-dust
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
                    htop
                    mosh
                    netcat
                    nmap
                    wget

                    # Development tools
                    difftastic
                    git
                    go
                    jq
                    lazygit
                    lua
                    pyenv
                    tmux
                    reattach-to-user-namespace
                    tree-sitter
                    yq

                    # Terminal and shell
                    zsh
                    wezterm
                    neovim

                    # Fonts
                    nerd-fonts._0xproto
                    nerd-fonts.hack
                    nerd-fonts.meslo-lg

                    # GUI applications
                    firefox
                    raycast
                ];
                stateVersion = "25.11";
                username = username;
                homeDirectory = "/Users/${username}/";
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
