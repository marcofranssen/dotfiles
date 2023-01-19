#!/usr/bin/env bash

echo 'Cloning Vundle...'
if [ -d "$HOME/.vim/bundle/Vundle.vim" ]; then
  pushd "$HOME/.vim/bundle/Vundle.vim" >/dev/null || exit 1
  git pull --quiet
  popd >/dev/null || exit 1
else
  git clone --quiet https://github.com/VundleVim/Vundle.vim.git ~/.vim/bundle/Vundle.vim
fi

vimrc=.vimrc

echo "Put in place $HOME/${vimrc} config..."
temp="$(mktemp -d)"
curl -sSo "${temp}/${vimrc}" https://raw.githubusercontent.com/marcofranssen/dotfiles/main/${vimrc}

if [ -e "$HOME/${vimrc}" ]; then
  echo
  if git --no-pager diff --no-index --minimal "${HOME}/${vimrc}" "${temp}/${vimrc}" ; then
    echo "${HOME}/${vimrc} is already in sync."
  else
    echo
    read -r -p "$(tput setaf 3)Do you want to replace the $HOME/${vimrc}?$(tput sgr0) [y/N] " response
    # remove leading whitespace characters
    response="${response#"${response%%[![:space:]]*}"}"
    # remove trailing whitespace characters
    response="${response%"${response##*[![:space:]]}"}"

    if [[ "$response" =~ ^(yes|y)$ ]]; then
      mv "${temp}/${vimrc}" "${HOME}/${vimrc}"
      echo "Updated your existing ${vimrc}"
    else
      echo "Your existing ${vimrc} was kept."
    fi
  fi
else
  mv "${temp}/${vimrc}" "${HOME}/${vimrc}"
fi
rm -r "${temp}"

echo
echo 'Installing Vundle plugins...'
yes | vim +PluginInstall +qall >/dev/null 2>&1
mkdir -p "${HOME}/.vim"
