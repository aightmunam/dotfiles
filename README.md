 dotfiles

My Dotfiles for git, vim/nvim, zsh and more.

### Steps to setup these dotfiles on your machine
1. Clone this repo in $HOME/dotfiles (~/dotfiles) directory
  ```
  # if SSH has been added for the machine
  git clone git@github.com:aightmunam/dotfiles.git

  git clone https://github.com/aightmunam/dotfiles.git
  ```
#### Using Nix home-manager:
2. Navigate into dotfiles/nix directory
```
make setup
make build
```
