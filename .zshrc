eval "$(direnv hook zsh)"

#######################################################
# Theme
#######################################################

export ZSH="/Users/munammubashir/.oh-my-zsh"
ZSH_THEME="cloud"
source $ZSH/oh-my-zsh.sh


#######################################################
# general aliases
#######################################################

setopt CORRECT
alias cd='nocorrect cd'
alias cp='nocorrect cp -v -R'
alias find='noglob find'
alias ftp='noglob ftp'
alias gcc='nocorrect gcc'
alias grep='nocorrect grep'
alias history='fc -il 1'
alias ln='nocorrect ln'
alias man='nocorrect man'
alias map="xargs -n1"
alias mkdir='nocorrect mkdir -p'
alias mv='nocorrect mv'
alias path='echo -e ${PATH//:/\\n}'
alias rm='nocorrect rm -rf'
alias rsync='noglob rsync'
alias ..='cd ..'
alias ...='cd ../..'
alias ....='cd ../../..'
alias .....='cd ../../../..'
alias ......='cd ../../../../..'
alias python='/usr/bin/python3'
alias g='nocorrect git'


for method in GET HEAD POST PUT DELETE TRACE OPTIONS; do
  alias "$method"="curl -iX '$method'"
done


#######################################################
# completion - based on zprezto
#######################################################

setopt ALWAYS_TO_END       # Move cursor to the end of a completed word.
setopt MENU_COMPLETE       # Auio-select first match
unsetopt FLOW_CONTROL      # Disable start/stop characters in shell editor.

zstyle ':completion::complete:*' use-cache on
zstyle ':completion::complete:*' cache-path "${ZDOTDIR:-$HOME}/.zcompcache"

zstyle ':completion:*' completer _complete _ignored _approximate
zstyle ':completion:*' rehash true # Automatically update PATH entries
zstyle ':completion:*' menu select=0
zstyle ':completion:*' verbose true
zstyle ':completion:*' group-name ''
zstyle ':completion:*' list-dirs-first true
zstyle ':completion:*' accept-exact-dirs true
zstyle ':completion:*' squeeze-slashes true
zstyle ':completion:*' show-completer true # Show which completer is currently running
zstyle ':completion:*' single-ignored show
zstyle ':completion:*' users off
zstyle ':completion:*' special-dirs ..
zstyle ':completion:*' list-prompt '%SAt %p: Hit TAB for more, or the character to insert%s'
zstyle ':completion:*' select-prompt '%SScrolling active: current selection at %p%s'
zstyle ':completion:*:options' description 'yes'
zstyle ':completion:*:options' auto-description '%d'
zstyle -e ':completion:*:approximate:*' max-errors 'reply=($((($#PREFIX+$#SUFFIX)/3)) numeric)'
zstyle ':completion:*:*:cd:*:directory-stack' force-list always
zstyle ':completion:*:*:cd:*:directory-stack' menu yes select
zstyle ':completion:*:correct:*' insert-unambiguous true
zstyle ':completion:*:corrections' format ' %F{green}-- %d (errors: %e) --%f'
zstyle ':completion:*:descriptions' format ' %F{yellow}-- %d --%f'
zstyle ':completion:*:messages' format ' %F{purple} -- %d --%f'
zstyle ':completion:*:warnings' format ' %F{red}-- no matches found --%f'
zstyle ':completion:*:default' list-prompt '%S%M matches%s'
zstyle ':completion:*:match:*' original only
zstyle ':completion:*' matcher-list 'm:{a-zA-Z}={A-Za-z}'
zstyle ':completion:*:-command-:*:' verbose false
zstyle ':completion:*:*:*:*:processes' force-list always
zstyle ':completion:*:*:*:*:processes' menu yes select
zstyle ':completion:*:*:*:*:processes' list-colors '=(#b) #([0-9]#) ([0-9a-z-]#)*=01;34=0=01'
zstyle ':completion:*:*:*:*:processes' command "ps -u $USER -o pid,user,args -w -w"
zstyle ':completion:*:default' list-colors ${(s.:.)LS_COLORS}
zstyle -e ':completion:*' hosts 'reply=()'
zstyle ':completion:*:functions' ignored-patterns '(_*|pre(cmd|exec))'


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