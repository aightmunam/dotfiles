# Nix (must be first)
if [ -e '/nix/var/nix/profiles/default/etc/profile.d/nix-daemon.sh' ]; then
  . '/nix/var/nix/profiles/default/etc/profile.d/nix-daemon.sh'
elif [ -e "$HOME/.nix-profile/etc/profile.d/nix.sh" ]; then
  . "$HOME/.nix-profile/etc/profile.d/nix.sh"
elif [ -e '/etc/profile.d/nix.sh' ]; then
  . '/etc/profile.d/nix.sh'
fi

# Ensure nix profile bin is in PATH
export PATH="$HOME/.nix-profile/bin:$PATH"

# Make nix desktop apps visible to launchers
export XDG_DATA_DIRS="$HOME/.nix-profile/share:${XDG_DATA_DIRS:-/usr/local/share:/usr/share}"

export EDITOR=nvim
export VISUAL=nvim
export PAGER=bat
export LANG=en_US.UTF-8
export LC_ALL=en_US.UTF-8

if [ -f ~/.zshenv.local ]; then
  source ~/.zshenv.local
fi
