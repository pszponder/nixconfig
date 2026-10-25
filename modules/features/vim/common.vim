set nocompatible
syntax on
filetype plugin indent on

" Use the theme's full palette in terminals with true-color support.
set termguicolors
set background=dark

" Keep position and partially typed commands visible.
set number
set relativenumber
set cursorline

" Use absolute numbers while inserting, then restore relative motions.
augroup RelativeLineNumbers
    autocmd!
    autocmd InsertEnter * setlocal norelativenumber
    autocmd InsertLeave * setlocal relativenumber
augroup END

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
set tabstop=2
set shiftwidth=2
set softtabstop=2
set autoindent
set backspace=indent,eol,start

" Treat hyphenated names as one word for motions and word operations.
set iskeyword+=-

" Share yanks, deletes, and pastes with the system clipboard.
set clipboard+=unnamedplus

" Do not create swap or backup files.
set noswapfile
set nobackup
set nowritebackup

" Allow switching buffers with unsaved edits; confirm before discarding.
set hidden
set confirm
set wildmenu
set wildmode=longest:full,full
