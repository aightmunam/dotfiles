{ inputs, username, ... }@flakeContext:
let
    dotfilesDir = builtins.path { path = ../.; };
    homeModule = { config, lib, pkgs, ... }: {
        config = {
            home = {
                sessionPath = [
                    "$HOME/.nix-profile/bin"
                    "/nix/var/nix/profiles/default/bin"
                ];
                sessionVariables = {
                };
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
                    ".zshenv" = {
                        source = "${dotfilesDir}/.zshenv";
                    };
                    ".zsh_functions" = {
                        source = "${dotfilesDir}/.zsh_functions";
                    };
                    ".config/nvim" = {
                        source = "${dotfilesDir}/nvim";
                        recursive = true;
                    };
                    ".config/wezterm" = {
                        source = "${dotfilesDir}/wezterm";
                    };
                    ".config/nix" = {
                        source = "${dotfilesDir}/nix";
                    };
                    ".config/home-manager" = {
                        source = "${dotfilesDir}/home-manager";
                    };
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
                    btop
                    mosh
                    netcat
                    nmap
                    wget

                    # Development tools
                    gh          # GitHub CLI
                    delta       # Better git diff
                    direnv      # Per-directory env
                    tldr        # Better man pages
                    duf         # Better df
                    difftastic
                    git
                    go
                    jq
                    lazygit
                    lua
                    pyenv
                    tmux
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
                homeDirectory = "/home/${username}";
            };
            programs = {
                autojump.enable = true;
                fzf.enable = true;
                home-manager.enable = true;
            };
        };
    };
    nixosModule = { ... }: {
        home-manager.users.${username} = homeModule;
    };
in
    (
    (
        inputs.home-manager.lib.homeManagerConfiguration {
            modules = [
                homeModule
            ];
            pkgs = inputs.nixpkgs.legacyPackages.x86_64-linux;
        }
    ) // { inherit nixosModule;
    }
)
