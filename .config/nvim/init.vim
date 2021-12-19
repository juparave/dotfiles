syntax on

set noerrorbells
set tabstop=4 softtabstop=4
set shiftwidth=4
set smarttab
set smartindent
set number
set nowrap
set swapfile
set nobackup
set undodir=~/.nvim/undodir
set undofile
set incsearch
" set relativenumber
"rset mouse=a
set encoding=UTF-8

set colorcolumn=80
highlight ColorColumn ctermbg=lightgrey guibg=lightgrey

let mapleader = " " " map leader to Space"

call plug#begin()

Plug 'https://github.com/vim-airline/vim-airline'  " Status bar
Plug 'fatih/vim-go', { 'do': ':GoUpdateBinaries' } " Golang plug in


" dependency for telescope
" ripgrep
" brew install ripgrep
Plug 'nvim-lua/plenary.nvim'
Plug 'nvim-telescope/telescope.nvim'


call plug#end()

" air-line
let g:airline_powerline_fonts = 1

if !exists('g:airline_symbols')
    let g:airline_symbols = {}
endif

" airline symbols
let g:airline_left_sep = ''
let g:airline_left_alt_sep = ''
let g:airline_right_sep = ''
let g:airline_right_alt_sep = ''
let g:airline_symbols.branch = ''
let g:airline_symbols.readonly = ''
let g:airline_symbols.linenr = ''

" ******************************************************************************************
" Telescope
" ******************************************************************************************
" Using Lua functions
nnoremap <leader>ff <cmd>lua require('telescope.builtin').find_files()<cr>
nnoremap <leader>fg <cmd>lua require('telescope.builtin').live_grep()<cr>
nnoremap <leader>fb <cmd>lua require('telescope.builtin').buffers()<cr>
nnoremap <leader>fh <cmd>lua require('telescope.builtin').help_tags()<cr>
