# dotfiles

My Dotfiles for git, vim, zsh and more. 

### Steps to setup these dotfiles on your machine
1. Clone this repo in $HOME/.dotfiles (~/.dotfiles) directory
  ```
  # if SSH has been added for the machine
  git clone git@github.com:aightmunam/dotfiles.git 
  
  git clone https://github.com/aightmunam/dotfiles.git
  ```
  
2. Navigate into the newly created .dotfiles directory
  ```
  cd $HOME/.dotfiles
  ```
3. Run the setup.sh script to automatically set all the symlinks.
  ```
  chmod +x setup.sh
  ./setup.sh
  ```
