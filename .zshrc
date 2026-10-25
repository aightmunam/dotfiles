# Panes the herdr-projects board opens for its agents get a bare shell. herdr will not
# start an agent while any command of this file runs in the foreground, and the board
# gives up within a second. PATH, pyenv shims and node already come from .zshenv.
if [[ -n $HERDR_PROJECTS_DATA_DIR || $PWD == $HOME/.herdr-projects/* ]]; then
  export PATH="$HOME/.herdr-projects/data/bin:$HOME/.cargo/bin:$HOME/.local/bin:$PATH"
  export TERM=wezterm
  PROMPT='%~ %# '
  return
fi

#######################################################
# Environment
#######################################################

typeset -U path PATH
export PATH="$HOME/.local/bin:/opt/homebrew/bin:$PATH"
export TERM=wezterm

# Pyenv
export PYENV_ROOT="$HOME/.pyenv"
export PATH="$PYENV_ROOT/bin:$PATH"
eval "$(pyenv init --path --no-rehash)"

# Rust / Cargo
export PATH="$HOME/.cargo/bin:$PATH"

# herdr-projects
export PATH="$HOME/.herdr-projects/data/bin:$PATH"

# Work trunk
if command -v wt >/dev/null 2>&1; then eval "$(command wt config shell init zsh)"; fi

#######################################################
# Shell options, completion & plugins (no framework)
#######################################################

ZSH_PLUGINS="$HOME/.nix-profile/share/zsh"

setopt auto_cd
setopt auto_pushd
setopt extended_glob
setopt glob_dots
setopt interactive_comments
setopt complete_in_word
setopt always_to_end

# Completion: nix-installed completions (atuin, zoxide, rg, gh, uv, ...) must be on
# fpath before compinit runs.
fpath+=("$ZSH_PLUGINS/site-functions")
autoload -Uz compinit && compinit
zstyle ':completion:*' menu select
zstyle ':completion:*' matcher-list 'm:{a-zA-Z}={A-Za-z}'
zstyle ':completion:*' list-colors "${(s.:.)LS_COLORS}"

# Key bindings: emacs mode, Up/Down search by the typed prefix, sane Home/End/Delete.
bindkey -e
autoload -Uz up-line-or-beginning-search down-line-or-beginning-search
zle -N up-line-or-beginning-search
zle -N down-line-or-beginning-search
bindkey '^[[A' up-line-or-beginning-search
bindkey '^[OA' up-line-or-beginning-search
bindkey '^[[B' down-line-or-beginning-search
bindkey '^[OB' down-line-or-beginning-search
bindkey '^[[H' beginning-of-line
bindkey '^[[F' end-of-line
bindkey '^[[3~' delete-char

# Prompt: hairline design system, plain zsh (see ~/.zsh_prompt).
[[ -r ~/.zsh_prompt ]] && source ~/.zsh_prompt

[[ -r $ZSH_PLUGINS/plugins/zsh-autosuggestions/zsh-autosuggestions.zsh ]] && source $ZSH_PLUGINS/plugins/zsh-autosuggestions/zsh-autosuggestions.zsh

# zoxide: `z <dir>` jumps to a frecent directory. `j` kept from autojump days.
eval "$(zoxide init zsh)"
alias j='z'

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

# Atuin owns Ctrl-R (full-screen search over ~/.local/share/atuin/history.db). Up
# stays prefix search above. zsh keeps writing HISTFILE too, as a fallback.
if command -v atuin >/dev/null 2>&1; then eval "$(atuin init zsh --disable-up-arrow)"; fi

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
alias lsa='ls -lah'
alias tree='tree -hpugD'
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
alias cc='claude'
alias pip='python3 -m pip'
alias python='python3'
alias hweb='open http://127.0.0.1:7317'

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

#######################################################
# direnv (per-directory env; replaces autoenv)
#######################################################

if hash direnv &>/dev/null; then
  eval "$(direnv hook zsh)"
fi

# bun completions
[ -s "/Users/munammubashir/.bun/_bun" ] && source "/Users/munammubashir/.bun/_bun"

# Syntax highlighting wraps every ZLE widget defined before it, so it loads last.
[[ -r $ZSH_PLUGINS/plugins/fast-syntax-highlighting/fast-syntax-highlighting.plugin.zsh ]] && source $ZSH_PLUGINS/plugins/fast-syntax-highlighting/fast-syntax-highlighting.plugin.zsh
