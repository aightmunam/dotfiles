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
  [ -e "$HOME/.nix-profile/etc/profile.d/hm-session-vars.sh" ] && . "$HOME/.nix-profile/etc/profile.d/hm-session-vars.sh"
fi

if [ -f ~/.zshenv.local ]; then
  source ~/.zshenv.local
fi
