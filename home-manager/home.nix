{ inputs, username, ... }@flakeContext:
let
    dotfilesDir = builtins.path { path = ../.; };
    homeModule = { config, lib, pkgs, ... }: {
        config = {
            home = {
                sessionPath = [
                    "/run/current-system/sw/bin"
                    "$HOME/.nix-profile/bin"
                ];
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
                    ".config/nvim" = {
                        source = "${dotfilesDir}/nvim";
                        recursive = true;
                    };
                    ".config/wezterm" = {
                        source = "${dotfilesDir}/wezterm";
                        recursive = true;
                    };
                    ".config/nix" = {
                        source = "${dotfilesDir}/nix";
                    };
                    ".config/home-manager" = {
                        source = "${dotfilesDir}/home-manager";
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
                    aerospace

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
                    nerd-fonts.monaspace
                    nerd-fonts.mononoki

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
                zsh = {
                    enable = true;
                    initContent = ''
                      # Add any additional configurations here
                      export PATH=/run/current-system/sw/bin:$HOME/.nix-profile/bin:$PATH
                      if [ -e '/nix/var/nix/profiles/default/etc/profile.d/nix-daemon.sh' ]; then
                        . '/nix/var/nix/profiles/default/etc/profile.d/nix-daemon.sh'
                      fi
                    '';
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
