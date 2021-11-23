# If you come from bash you might have to change your $PATH.
# export PATH=$HOME/bin:/usr/local/bin:$PATH
eval "$(direnv hook zsh)"

export PATH=/Library/PostgreSQL/14/bin:$PATH
export PYENV_ROOT="$HOME/.pyenv"
export PATH="$PYENV_ROOT/bin:$PATH"
eval "$(pyenv init -)"


export ZSH="/Users/munammubashir/.oh-my-zsh"
ZSH_THEME="cloud"
DISABLE_AUTO_UPDATE="true"
plugins=(
	git
	osx
)

source $ZSH/oh-my-zsh.sh

alias python="/usr/bin/python3"

