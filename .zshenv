# Nix (must be first)
if [ -e '/nix/var/nix/profiles/default/etc/profile.d/nix-daemon.sh' ]; then
  . '/nix/var/nix/profiles/default/etc/profile.d/nix-daemon.sh'
fi

export EDITOR=nvim
export VISUAL=nvim
export PAGER=bat
export LANG=en_US.UTF-8
export LC_ALL=en_US.UTF-8

if [ -f ~/.zshenv.local ]; then
  source ~/.zshenv.local
fi
