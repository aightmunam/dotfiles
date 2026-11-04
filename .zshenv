export EDITOR=nvim
export VISUAL=nvim
export PAGER=bat
export LANG=en_US.UTF-8
export LC_ALL=en_US.UTF-8

export RAINFROG_CONFIG=$HOME/.config/rainfrog

# Single-user Nix (the Linux install) only hooks ~/.bash_profile, so zsh loads it here,
# before .zshrc needs pyenv, zoxide and the plugins. macOS uses nix-daemon.sh from .zshrc.
if [[ "$OSTYPE" == linux* ]] && [ -e "$HOME/.nix-profile/etc/profile.d/nix.sh" ]; then
  . "$HOME/.nix-profile/etc/profile.d/nix.sh"
  # Make nix desktop apps visible to launchers
  export XDG_DATA_DIRS="$HOME/.nix-profile/share:${XDG_DATA_DIRS:-/usr/local/share:/usr/share}"
fi

# home-manager session variables (DOTFILES_DIR and others), on every OS and in
# every zsh, also the non-interactive shell of an agent.
[ -e "$HOME/.nix-profile/etc/profile.d/hm-session-vars.sh" ] && . "$HOME/.nix-profile/etc/profile.d/hm-session-vars.sh"

if [ -f ~/.zshenv.local ]; then
  source ~/.zshenv.local
fi
