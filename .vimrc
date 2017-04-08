" enable project specific .vimrc
set exrc

set nocompatible
filetype off

set rtp+=~/.vim/bundle/Vundle.vim
call vundle#begin()

Plugin 'VundleVim/Vundle.vim'

Plugin 'altercation/vim-colors-solarized'
Plugin 'flazz/vim-colorschemes'
Plugin 'airblade/vim-gitgutter'
Plugin 'kien/ctrlp.vim'
Plugin 'scrooloose/nerdcommenter'
Plugin 'scrooloose/syntastic'
Plugin 'ervandew/supertab'

" All of your Plugins must be added before the following line
call vundle#end()
filetype plugin indent on
" To ignore plugin indent changes, instead use:
" filetype plugin on
"
" Brief help
" :PluginList       - lists configured plugins
" :PluginInstall    - installs plugins; append `!` to update or just :PluginUpdate
" :PluginSearch foo - searches for foo; append `!` to refresh local cache
" :PluginClean      - confirms removal of unused plugins; append `!` to auto-approve removal
"
" see :h vundle for more details or wiki for FAQ
" Put your non-Plugin stuff after this line

" Syntax highlighting + color scheme
syntax on
set t_Co=256
colorscheme jellybeans

" makes sure we don't lose history when switching buffers
" http://stackoverflow.com/a/2732336
set hidden

set hlsearch
set incsearch

set cul
set number
set laststatus=2

set autoindent
set expandtab
set shiftwidth=4
set softtabstop=4
set tabstop=4

au FileType yaml setlocal tabstop=2 expandtab shiftwidth=2 softtabstop=2

" remove trailing whitespace on save
autocmd FileType java,php,js,yaml,json,sh autocmd BufWritePre <buffer> :%s/\s\+$//e

" give us some left margin (also disable highlighting for the fold
" column 'F' with 'n', so that it really shows up as a margin
set highlight=Fn
set foldcolumn=5

" Configure nerdcommenter
let g:NERDSpaceDelims = 1
let g:NERDTrimTrailingWhitespace = 1

" Syntastic configuration
set statusline+=%#warningmsg#
set statusline+=%{SyntasticStatuslineFlag()}
set statusline+=%*

let g:syntastic_always_populate_loc_list = 1
let g:syntastic_auto_loc_list = 1
let g:syntastic_check_on_open = 1
let g:syntastic_check_on_wq = 0


" disable unsafe commands from project specific .vimrc
set secure
