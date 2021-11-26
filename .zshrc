eval "$(direnv hook zsh)"


#######################################################
# Theme
#######################################################

export ZSH="/Users/munammubashir/.oh-my-zsh"
ZSH_THEME="cloud"
source $ZSH/oh-my-zsh.sh

#######################################################
# Theme
#######################################################


plugins=( 
    zsh-autosuggestions macos
)

#######################################################
# general aliases
#######################################################

alias cp='cp -v -R'
alias find='noglob find'
alias ftp='noglob ftp'
alias history='fc -il 1'
alias lsa='ls -a'
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
alias python='/usr/bin/python3'
alias g='git'


for method in GET HEAD POST PUT DELETE TRACE OPTIONS; do
  alias "$method"="curl -iX '$method'"
done


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