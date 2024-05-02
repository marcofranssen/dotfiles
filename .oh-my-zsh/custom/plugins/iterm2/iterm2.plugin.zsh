# Add your own custom plugins in the custom/plugins directory. Plugins placed
# here will override ones with the same name in the main plugins directory.
# See: https://github.com/ohmyzsh/ohmyzsh/wiki/Customization#overriding-and-adding-plugins

if ! [ -e "${HOME}/.iterm2_shell_integration.zsh" ] ; then
  curl -L https://iterm2.com/shell_integration/zsh \
    -o ~/.iterm2_shell_integration.zsh
fi

source "${HOME}/.iterm2_shell_integration.zsh"
