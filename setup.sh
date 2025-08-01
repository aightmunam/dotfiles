#!/usr/bin/env

echo "Setting up..."

CWD="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

# Installs a file or directory from a source path to a destination path within the user's home directory.
# This function first removes any existing item at the destination and ensures its parent directories exist.
#
# Arguments:
#   $1 (source_path):       The path to the source file or directory, relative to the current working directory ($CWD).
#   $2 (dest_path):         The desired destination path, relative to the user's home directory ($HOME).
#   $3 (copy_mode_flag):    Optional. If '1', performs a full recursive copy (`cp -Ra`).
#                           Otherwise (default), creates a symbolic link (`ln -s`).
install() {
  echo "Insalling: $@"

  rm -rf "$HOME/$2"
  mkdir -p "$(dirname "$HOME/$2")"

  if ! [[ "$3" -eq 1 ]]; then
    ln -s "$CWD/$1" "$HOME/$2"
  else
    cp -Ra "$CWD/$1" "$HOME/$2"
  fi
}

uninstall() {
  rm -rf "$HOME/$1"
}

# clone_if_empty <target_dir> <repo_url>
#
# Clones a Git repository into the specified target directory,
# but only if the directory does not exist or is empty.
#
# Arguments:
#   target_dir - The directory to clone the repository into.
#   repo_url   - The URL of the Git repository to clone.
#
clone_if_empty() {
  local target_dir="$1"
  local repo_url="$2"

  if [ ! -d "$target_dir" ] || [ -z "$(ls -A "$target_dir")" ]; then
    echo "Cloning into $target_dir..."
    git clone --depth=1 "$repo_url" "$target_dir"
  else
    echo "Directory '$target_dir' exists and is not empty. Skipping clone."
  fi
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
# vim, nvim, tmux
###############################################################################

uninstall ".config/nvim"
uninstall ".vim"
uninstall ".vimrc"
uninstall ".tmux.conf"

install "nvim" ".config/nvim" 1
install "vim" ".vim" 1
install ".vimrc" ".vimrc" 1
install "tmux/.tmux.conf" ".tmux.conf" 1

###############################################################################
# wezterm
###############################################################################

uninstall ".config/wezterm"
install "wezterm" ".config/wezterm" 1

###############################################################################
# oh my zsh
###############################################################################

clone_if_empty "~/.oh-my-zsh" "https://github.com/ohmyzsh/ohmyzsh.git"
clone_if_empty "${ZSH_CUSTOM:-$HOME/.oh-my-zsh/custom}/themes/powerlevel10k" "https://github.com/romkatv/powerlevel10k.git"
clone_if_empty "${ZSH_CUSTOM:-$HOME/.oh-my-zsh/custom}/plugins/zsh-autosuggestions" "https://github.com/zsh-users/zsh-autosuggestions"
clone_if_empty "${ZSH_CUSTOM:-$HOME/.oh-my-zsh/custom}/plugins/zsh-syntax-highlighting" "https://github.com/zsh-users/zsh-syntax-highlighting.git"
clone_if_empty "${ZSH_CUSTOM:-$HOME/.oh-my-zsh/custom}/plugins/fast-syntax-highlighting" "https://github.com/zdharma-continuum/fast-syntax-highlighting.git"
clone_if_empty "${ZSH_CUSTOM:-$HOME/.oh-my-zsh/custom}/plugins/k" "https://github.com/supercrabtree/k"
clone_if_empty "${ZSH_CUSTOM:-$HOME/.oh-my-zsh/custom}/plugins/zsh-autocomplete" "https://github.com/marlonrichert/zsh-autocomplete.git"
clone_if_empty "${ZSH_CUSTOM:-$HOME/.oh-my-zsh/custom}/plugins/autojump-setup" "https://github.com/wting/autojump.git"
cd ${ZSH_CUSTOM:-$HOME/.oh-my-zsh/custom}/plugins/autojump-setup && python3 install.py
###############################################################################
# zinit
###############################################################################

rm -rf "$HOME/.zinit"
mkdir "$HOME/.zinit"
git clone --depth=1 https://github.com/zdharma-continuum/zinit.git "$HOME/.zinit/bin"

echo -e "Installation done for the following ${#files[*]} dotfiles: ${files[*]}"

source $HOME/.zshrc
