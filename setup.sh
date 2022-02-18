#!/usr/bin/env

echo "Setting up..."

CWD="$(cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd)"

install () {
  echo "Insalling: $@"

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
  .dircolors
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

install ".vim" ".config/nvim" 1
install ".vimrc" ".config/nvim/init.vim" 1
install ".vim" ".vim" 1
install ".vimrc" ".vimrc" 1


###############################################################################
# oh my zsh
###############################################################################

git clone --depth=1 https://github.com/ohmyzsh/ohmyzsh.git ~/.oh-my-zsh
git clone --depth=1 https://github.com/romkatv/powerlevel10k.git ${ZSH_CUSTOM:-$HOME/.oh-my-zsh/custom}/themes/powerlevel10k
git clone --depth=1 https://github.com/zsh-users/zsh-autosuggestions ${ZSH_CUSTOM:-~/.oh-my-zsh/custom}/plugins/zsh-autosuggestions
git clone --depth=1 https://github.com/zsh-users/zsh-syntax-highlighting.git ${ZSH_CUSTOM:-~/.oh-my-zsh/custom}/plugins/zsh-syntax-highlighting
git clone --depth=1 https://github.com/supercrabtree/k ${ZSH_CUSTOM:-~/.oh-my-zsh/custom}/plugins//k

git clone --depth=1 git://github.com/wting/autojump.git ~/.oh-my-zsh/autojump-setup
$(cd ~/.oh-my-zsh/autojump-setup && ./install.py)


###############################################################################
# zinit
###############################################################################

rm -rf "$HOME/.zinit"
mkdir "$HOME/.zinit"
git clone --depth=1 https://github.com/zdharma-continuum/zinit.git "$HOME/.zinit/bin"

echo -e "Installation done for the following ${#files[*]} dotfiles: ${files[*]}"

source $HOME/.zshrc
