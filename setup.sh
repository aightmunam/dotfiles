#!/usr/bin/env bash

CWD="$(cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd)"

install () {
  echo "Insalling $#: $@"

  rm -rf "$HOME/$2"
  mkdir -p "$(dirname "$HOME/$2")"

  if ! [[ "$3" -eq 1 ]]; then
    ln -s "$CWD/$1" "$HOME/$2"
  else
    cp -Ra "$CWD/$1" "$HOME/$2"
  fi
}

uninstall () {
  rm -rf "$HOME/$1"
}


###############################################################################
# dotfiles
###############################################################################

declare -a files=(
  .bash_profile
  .bashrc
  .dircolors
  .editorconfig
  .gitconfig
  .zshrc
)

for file in "${files[@]}"; do
  if [[ -f $file ]]; then
    install "$file" "$file"
  fi
done


###############################################################################
# vim
###############################################################################

uninstall ".config/nvim"
uninstall ".vim"
uninstall ".vimrc"

if [ ! -f "$HOME/.vim/autoload/plug.vim" ]; then
  curl -sfLo "$HOME/.vim/autoload/plug.vim" --create-dirs 'https://raw.githubusercontent.com/junegunn/vim-plug/master/plug.vim'
fi

install ".vim" ".config/nvim" 1
install ".vimrc" ".config/nvim/init.vim" 1
install ".vim" ".vim" 1
install ".vimrc" ".vimrc" 1

vim -c ':PlugInstall! | :PlugUpdate! | :q! | :q!'


###############################################################################
# zinit
###############################################################################

rm -rf "$HOME/.zinit"
mkdir "$HOME/.zinit"
git clone --depth=1 https://github.com/zdharma-continuum/zinit.git "$HOME/.zinit/bin"


echo -e "Installation done for the following ${#files[*]} dotfiles: ${files[*]}"