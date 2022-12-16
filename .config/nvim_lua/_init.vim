" Setting config options that I haven't figure out how to set them on lua
" To avoid conflict we rename `init.lua` to `config.lua` and call it from here
lua require('~/.config/nvim/config')

"" Move visual block
vnoremap J :m '>+1<CR>gv=gv
vnoremap K :m '<-2<CR>gv=gv
