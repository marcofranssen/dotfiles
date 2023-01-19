#!/usr/bin/env bash

echo 'Put in place .gitconfig...'
mkdir -p temp
curl -sSo temp/.gitconfig https://raw.githubusercontent.com/marcofranssen/dotfiles/master/.gitconfig

function set-git-user() {
  local git_user_name git_user_email
  git_user_name=$(grep name "$HOME/.gitconfig" | sed 's/^.*= //')
  git_user_email=$(grep email "$HOME/.gitconfig" | sed 's/^.*= //')

  if [ -z "$git_user_name" ]; then
    read -r -p "$(tput setaf 3)Your git username: " git_user_name
  fi

  if [ -z "$git_user_email" ]; then
    read -r -p "$(tput setaf 3)Your git user email: " git_user_email
  fi

  git config -f temp/.gitconfig user.name "$git_user_name"
  git config -f temp/.gitconfig user.email "$git_user_email"
  sed -i "s/AUTHOR_EMAIL/$git_user_email/" temp/.gitconfig
}

set-git-user

if [ -e "$HOME/.gitconfig" ]; then
  echo
  read -r -p "$(tput setaf 3)Please take a look at the following diff to decide if you want to overwrite your existing .gitconfig$(tput sgr0)"
  echo
  git diff ~/.gitconfig temp/.gitconfig
  echo
  read -r -p "$(tput setaf 3)Do you want to replace the .gitconfig file at $HOME/.gitconfig?$(tput sgr0) [y/N] " response
  response=${response,,}
  if [[ "$response" =~ ^(yes|y)$ ]]; then
    mv temp/.gitconfig ~/.gitconfig
    echo Updated your existing .gitconfig
  else
    echo Your existing .gitconfig was kept.
  fi
else
  mv temp/.gitconfig ~/.gitconfig
fi
rm -r temp
