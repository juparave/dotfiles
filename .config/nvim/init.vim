:set number
" :set relativenumber
:set autoindent
:set tabstop=4
:set smarttab
:set softtabstop=4
" :set mouse=a

call plug#begin()

Plug 'https://github.com/vim-airline/vim-airline'  " Status bar
Plug 'fatih/vim-go', { 'do': ':GoUpdateBinaries' } " Golang plug in

set encoding=UTF-8

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

