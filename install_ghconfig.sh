#!/usr/bin/env bash

gh_config_dir=.config/gh
gh_config="${gh_config_dir}/config.yml"

echo "Put in place ${HOME}/${gh_config}"
temp="$(mktemp -d)"
mkdir -p "${temp}/${gh_config_dir}"
curl -sSo "${temp}/${gh_config}" https://raw.githubusercontent.com/marcofranssen/dotfiles/main/${gh_config}

if [ -e "${HOME}/${gh_config}" ]; then
  echo

  if git --no-pager diff --no-index --minimal "${HOME}/${gh_config}" "${temp}/${gh_config}" ; then
    echo "${HOME}/${gh_config} is already in sync."
    exit
  fi
  echo
  read -r -p "$(tput setaf 3)Do you want to replace the ${HOME}/${gh_config}?$(tput sgr0) [y/N] " response
  # remove leading whitespace characters
  response="${response#"${response%%[![:space:]]*}"}"
  # remove trailing whitespace characters
  response="${response%"${response##*[![:space:]]}"}"

  if [[ "$response" =~ ^(yes|y)$ ]]; then
    mv "${temp}/${gh_config}" "${HOME}/${gh_config}"
    echo "Updated your existing ${HOME}/${gh_config}"
  else
    echo "Your existing  ${HOME}/${gh_config} was kept."
  fi
else
  mv "${temp}/${gh_config}" "${HOME}/${gh_config}"
fi
rm -r "${temp}"
