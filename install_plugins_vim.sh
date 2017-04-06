#!/bin/bash

echo 'Cloning Vundle...'
git clone --quiet https://github.com/VundleVim/Vundle.vim.git ~/.vim/bundle/Vundle.vim

echo 'Put in place .vimrc config...'
mkdir temp
curl -sSo temp/.vimrc https://raw.githubusercontent.com/marcofranssen/dotfiles/master/.vimrc

if [ -e "$HOME/.vimrc" ] ; then
  echo Please take a look at the following diff to decide if you want to overwrite your existing .vimrc
  git diff ~/.vimrc temp/.vimrc 
  read -r -p "Do you want to replace the .vimrc file at $HOME/.vimrc? [y/N] " response
  response=${response,,}
  if [[ "$response" =~ ^(yes|y)$ ]] ; then
    mv temp/.vimrc ~/.vimrc
    echo Your existing .vimrc
  else
    echo Your existing .vimrc was kept.
  fi

else
  mv temp/.vimrc ~/.vimrc
fi
rm -r temp

echo 'Installing Vundle plugins...'
yes | vim +PluginInstall +qall > /dev/null 2>&1
