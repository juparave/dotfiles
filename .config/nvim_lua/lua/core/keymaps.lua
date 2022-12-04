vim.g.mapleader = ' '
vim.g.maplocalleader = ' '

vim.opt.backspace = '2'
vim.opt.showcmd = true
vim.opt.laststatus = 2
-- autowrite write the contents of the file, I prefer hidden
--vim.opt.autowrite = true 
vim.opt.hidden = true
vim.opt.cursorline = true
vim.opt.autoread = true

-- use spaces for tabs and whatnot
vim.opt.tabstop = 2
vim.opt.softtabstop = 4
vim.opt.shiftwidth = 2
vim.opt.shiftround = true
vim.opt.expandtab = true

vim.opt.smartindent = true

vim.opt.wrap = false

-- Undo
vim.opt.swapfile = false
vim.opt.backup = false
vim.opt.undodir = os.getenv("HOME") .. "/.vim/undodir"
vim.opt.undofile = true

no_buffers_menu = 1

-- Encoding
vim.opt.encoding= 'utf-8'
vim.opt.fileencoding= 'utf-8'
vim.opt.fileencodings= 'utf-8'

-- Searching
vim.opt.hlsearch = false
vim.opt.incsearch = true
vim.opt.ignorecase = true
vim.opt.smartcase = true
vim.opt.hlsearch = false          -- remove highlight after search

--
-- Visual Settings
--
vim.opt.ruler = true
vim.opt.number = true
vim.opt.colorcolumn = '+1'
vim.opt.signcolumn = 'yes'
vim.opt.cursorline = true
vim.o.termguicolors = true
vim.opt.scrolloff = 7
-- Font
vim.opt.guifont="Hack:14"
--vim.g.webdevicons_enable = 0
--vim.g.webdevicons_enable_nerdtree = 1

-- Mouse support
vim.opt.mouse = 'a'
vim.opt.mousemodel = 'popup'

-- Cursor
--vim.opt.

--- My remaps
-- Auto closing brackets
vim.keymap.set('i', '{<CR>', '{<CR>}<Esc>ko')
vim.keymap.set('i', '(<CR>', '(<CR>)<Esc>ko')
vim.keymap.set('i', '[<CR>', '[<CR>]<Esc>ko')

-- Yank to the end of line
vim.keymap.set('n', 'Y', 'y$')


vim.keymap.set('n', '<leader>h', ':nohlsearch<CR>')

-- Switching windows
vim.keymap.set('n', '<C-j>', '<C-w>j')
vim.keymap.set('n', '<C-k>', '<C-w>k')
vim.keymap.set('n', '<C-l>', '<C-w>l')
vim.keymap.set('n', '<C-h>', '<C-w>h')

-- Buffers
vim.keymap.set('n', '<leader>z', ':bp<CR>') -- navigate previous buffer
vim.keymap.set('n', '<leader>q', ':bp<CR>') -- navigate previous buffer
vim.keymap.set('n', '<leader>x', ':bn<CR>') -- navigate next buffer
vim.keymap.set('n', '<leader>w', ':bn<CR>') -- navigate next buffer
vim.keymap.set('n', '<leader>c', ':bd<CR>') -- close buffer

-- Split
vim.keymap.set('n', '<leader>h', ':<C-u>split<CR>')
vim.keymap.set('n', '<leader>v', ':<C-u>vsplit<CR>')

-- Move visual block
--- HELP !!! not working, added in `init.vim`
-- vim.keymap.set('n', 'J', ":m '>+1<CR>gv=gv")
-- vim.keymap.set('n', 'K', ":m '<-2<CR>gv=gv")
vim.keymap.set('v', '<', '<gv')
vim.keymap.set('v', '>', '>gv')

-- print(vim.inspect(vim.opt.formatoptions:get()))
