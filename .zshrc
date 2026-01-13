# Enable Powerlevel10k instant prompt (must be at the very top)
if [[ -r "${XDG_CACHE_HOME:-$HOME/.cache}/p10k-instant-prompt-${(%):-%n}.zsh" ]]; then
  source "${XDG_CACHE_HOME:-$HOME/.cache}/p10k-instant-prompt-${(%):-%n}.zsh"
fi

#######################################################
# Environment
#######################################################

typeset -U path PATH
export PATH="/opt/homebrew/bin:$PATH"
export TERM=wezterm
export EDITOR=nvim
export VISUAL=nvim

# Pyenv
export PYENV_ROOT="$HOME/.pyenv"
export PATH="$PYENV_ROOT/bin:$PATH"
eval "$(pyenv init --path)"

#######################################################
# Oh-my-zsh & Plugins
#######################################################

export ZSH="$HOME/.oh-my-zsh"
ZSH_THEME="powerlevel10k/powerlevel10k"

setopt auto_cd
setopt auto_pushd
setopt extended_glob
setopt glob_dots

plugins=(
    zsh-autosuggestions
    macos
    copypath
    copyfile
    dirhistory
    history
    fast-syntax-highlighting
    k
    autojump
    docker
    poetry
    pyenv
)

source $ZSH/oh-my-zsh.sh

# To customize prompt, run `p10k configure` or edit ~/.p10k.zsh.
[[ ! -f ~/.p10k.zsh ]] || source ~/.p10k.zsh

# Enable fzf for fuzzy searching of files and commands
[ -f ~/.fzf.zsh ] && source ~/.fzf.zsh

# Initialize zoxide
eval "$(zoxide init zsh)"

#######################################################
# History
#######################################################

bindkey '^n' history-search-forward
bindkey '^p' history-search-backward

HISTSIZE=50000
HISTFILE=~/.zsh_history
SAVEHIST=$HISTSIZE
HISTDUP=erase
setopt appendhistory
setopt sharehistory
setopt hist_ignore_space
setopt hist_ignore_dups
setopt hist_ignore_all_dups
setopt hist_save_no_dups
setopt hist_find_no_dups

#######################################################
# general aliases
#######################################################

# CLI aliases
alias cp='cp -v -R'
alias find='noglob find'
alias ftp='noglob ftp'
alias history='fc -il 1'
alias ls='eza --icons'
alias la='eza -la --icons'
alias map="xargs -n1"
alias mkdir='mkdir -p'
alias path='echo -e ${PATH//:/\\n}'
alias rm='rm -rf'
alias rsync='noglob rsync'
alias ..='cd ..'
alias ...='cd ../..'
alias ....='cd ../../..'
alias .....='cd ../../../..'
alias ......='cd ../../../../..'
alias c='clear'

# Language/tool specific aliases
alias pre-commit='python -m pre_commit'
alias g='git'
alias pip='python3 -m pip'
alias python='python3'

# Editor aliases
alias v='nvim'
alias vi='nvim'
alias vim='nvim'

# Tmux aliases
alias t='tmux'
alias ts='tmux new -s $(pwd | sed "s/.*\///g")'
alias ta='tmux attach-session -t'
alias tk='tmux kill-session -t'
alias tl='tmux list-sessions'
alias td='tmux detach'

for method in GET HEAD POST PUT DELETE TRACE OPTIONS; do
  alias "$method"="curl -iX '$method'"
done

#######################################################
# Nix 
#######################################################

export NIX_CONF_DIR=$HOME/.config/nix

if [ -e '/nix/var/nix/profiles/default/etc/profile.d/nix-daemon.sh' ]; then
   . '/nix/var/nix/profiles/default/etc/profile.d/nix-daemon.sh'
fi

#######################################################
# source .zsh_functions
#######################################################

if [ -f "$HOME/.zsh_functions" ]; then source "$HOME/.zsh_functions"; fi

#######################################################
# source .zshrc.local
#######################################################

if [ -f "$HOME/.zshrc.local" ]; then source "$HOME/.zshrc.local"; fi

#######################################################
# dircolors
#######################################################

if [ -f "$HOME/.dircolors" ]; then
  if hash dircolors &>/dev/null; then
    eval $(dircolors -b $HOME/.dircolors)
  fi
  if hash gdircolors &>/dev/null; then
    eval $(gdircolors -b $HOME/.dircolors)
  fi
fi
