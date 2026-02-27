syntax on
set number
set relativenumber
set cursorline
set scrolloff=8
set incsearch
set hidden
set wildmenu
set noerrorbells
set tabstop=4
set shiftwidth=4
set expandtab
set autoindent
set smartindent
set mouse=a
set termguicolors

if has('termguicolors')
  set termguicolors
endif

let mapleader = " "
nnoremap <leader>w :w<CR>
nnoremap <leader>q :q<CR>
nnoremap <leader>h :nohlsearch<CR>
