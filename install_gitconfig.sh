#!/usr/bin/env bash

git_config=".gitconfig"
git_config_private=".gitconfig-private"

echo 'Put in place .gitconfig...'
temp="$(mktemp -d)"
curl -sSo "${temp}/${git_config}" https://raw.githubusercontent.com/marcofranssen/dotfiles/main/${git_config}
curl -sSo "${temp}/${git_config_private}" https://raw.githubusercontent.com/marcofranssen/dotfiles/main/${git_config_private}

function set-git-user {
  local git_user_name git_user_email
  git_user_name=$(grep name "$HOME/${1}" | sed 's/^.*= //')
  git_user_email=$(grep email "$HOME/${1}" | sed 's/^.*= //')

  if [ -z "$git_user_name" ]; then
    read -r -p "$(tput setaf 3)Your git username: " git_user_name
  fi

  if [ -z "$git_user_email" ]; then
    read -r -p "$(tput setaf 3)Your git user email: " git_user_email
  fi

  git config -f "${temp}/${1}" user.name "$git_user_name"
  git config -f "${temp}/${1}" user.email "$git_user_email"
  sed -i "s/AUTHOR_EMAIL/$git_user_email/" "${temp}/${1}"
}

function install-config {
  if [ -e "${HOME}/${1}" ]; then
    echo
    if git --no-pager diff --no-index --minimal "${HOME}/${1}" "${temp}/${1}" ; then
      echo "${HOME}/${1} is already in sync."
      exit
    fi

    echo
    read -r -p "$(tput setaf 3)Do you want to replace the ${HOME}/${1}?$(tput sgr0) [y/N] " response
    # remove leading whitespace characters
    response="${response#"${response%%[![:space:]]*}"}"
    # remove trailing whitespace characters
    response="${response%"${response##*[![:space:]]}"}"

    if [[ "$response" =~ ^(yes|y)$ ]]; then
      mv "${temp}/${git_config}" "${HOME}/${1}"
      echo "Updated your existing ${HOME}/${1}".
    else
      echo "Your existing ${HOME}/${1} was kept."
    fi
  else
    mv "${temp}/${1}" "${HOME}/${1}"
  fi
}

set-git-user ${git_config}
set-git-user ${git_config_private}

install-config ${git_config}
install-config ${git_config_private}

rm -r "${temp}"
