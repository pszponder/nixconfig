set nocompatible
syntax on
filetype plugin indent on

" Use the theme's full palette in terminals with true-color support.
set termguicolors
set background=dark

" Keep position and partially typed commands visible.
set number
set ruler
set showcmd
set laststatus=2
set scrolloff=5

" Search as you type; use capitals for case-sensitive searches.
set incsearch
set hlsearch
set ignorecase
set smartcase
nnoremap <silent> <Esc><Esc> :nohlsearch<CR>

" Use spaces by default; filetype indentation can override these.
set expandtab
set tabstop=4
set shiftwidth=4
set softtabstop=4
set autoindent
set backspace=indent,eol,start

" Allow switching buffers with unsaved edits; confirm before discarding.
set hidden
set confirm
set wildmenu
set wildmode=longest:full,full
