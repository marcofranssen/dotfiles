#!/usr/bin/env bash

echo 'Cloning Vundle...'
if [ -d "$HOME/.vim/bundle/Vundle.vim" ]; then
  pushd "$HOME/.vim/bundle/Vundle.vim" >/dev/null || exit 1
  git pull --quiet
  popd >/dev/null || exit 1
else
  git clone --quiet https://github.com/VundleVim/Vundle.vim.git ~/.vim/bundle/Vundle.vim
fi

echo 'Put in place .vimrc config...'
mkdir -p temp
curl -sSo temp/.vimrc https://raw.githubusercontent.com/marcofranssen/dotfiles/master/.vimrc

if [ -e "$HOME/.vimrc" ]; then
  echo
  read -r -p "$(tput setaf 3)Please take a look at the following diff to decide if you want to overwrite your existing .vimrc$(tput sgr0)"
  echo
  git diff ~/.vimrc temp/.vimrc
  echo
  read -r -p "$(tput setaf 3)Do you want to replace the .vimrc file at $HOME/.vimrc?$(tput sgr0) [y/N] " response
  response=${response,,}
  if [[ "$response" =~ ^(yes|y)$ ]]; then
    mv temp/.vimrc ~/.vimrc
    echo Updated your existing .vimrc
  else
    echo Your existing .vimrc was kept.
  fi
else
  mv temp/.vimrc ~/.vimrc
fi
rm -r temp

echo 'Installing Vundle plugins...'
yes | vim +PluginInstall +qall >/dev/null 2>&1
