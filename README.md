# Dotfiles

- [.config/gh/config.yml](https://raw.githubusercontent.com/marcofranssen/dotfiles/main/.config/gh/config.yml)
- [.gnupg/gpg-agent.conf](https://raw.githubusercontent.com/marcofranssen/dotfiles/main/.gnupg/gpg-agent.conf)
- [.bashrc](https://raw.githubusercontent.com/marcofranssen/dotfiles/main/.bashrc)
- [.gitconfig](https://raw.githubusercontent.com/marcofranssen/dotfiles/main/.gitconfig)
- [.gitconfig-private](https://raw.githubusercontent.com/marcofranssen/dotfiles/main/.gitconfig-private)
- [.inputrc](https://raw.githubusercontent.com/marcofranssen/dotfiles/main/.inputrc)
- [.vimrc](https://raw.githubusercontent.com/marcofranssen/dotfiles/main/.vimrc)

## Prerequisites

- [Homebrew](https://brew.sh/)
- [Tmux](https://tmux.github.io/)
- [GNU stow](https://www.gnu.org/software/stow/)
- [ZSH](https://www.zsh.org/)
- [GH Cli](https://cli.github.com/)
- [delta](https://github.com/dandavison/delta)

Once Homebrew is installed the remainder of the prerequisites can be installed with the following command:

```shell
brew install git tmux stow zsh gh
```

## Installation

Checkout the repository into `~/.dotfiles` and use stow to create the symlinks:

```shell
git clone git@github.com/marcofranssen/dotfiles.git ~/.dotfiles
cd ~/.dotfiles
stow .
```

### Configure ViM

```shell
curl -sS https://raw.githubusercontent.com/marcofranssen/dotfiles/main/install_plugins_vim.sh | bash
```

## Configure git

### Prerequisites

```shell
curl -sS https://raw.githubusercontent.com/marcofranssen/dotfiles/main/install_gitconfig.sh | bash
```

## Configure gh cli

```shell
curl -sS https://raw.githubusercontent.com/marcofranssen/dotfiles/main/install_ghconfig.sh | bash
```
