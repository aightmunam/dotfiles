#!/usr/bin/env bash

CWD="$(cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd)"


install () {
  rm -rf "$HOME/$2"
  mkdir -p "$(dirname "$HOME/$2")"

  ln -s "$CWD/$1" "$HOME/$2"
  
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
  .vimrc
)

for file in "${files[@]}"; do
  if [[ -f $file ]]; then
    install "$file" "$file"
  fi
done

uninstall ".config/nvim"
uninstall ".vim"
uninstall ".vimrc"

install ".vim" ".config/nvim"
install ".vimrc" ".config/nvim/init.vim"
install ".vim" ".vim"
install ".vimrc" ".vimrc"

if [ ! -f "$HOME/.vim/autoload/plug.vim" ]; then
  curl -sfLo "$HOME/.vim/autoload/plug.vim" --create-dirs 'https://raw.githubusercontent.com/junegunn/vim-plug/master/plug.vim'
fi

vim -c ':PlugInstall! | :PlugUpdate! | :q! | :q!'

echo -e "Installation done for the following ${#files[*]} dotfiles: ${files[*]}"