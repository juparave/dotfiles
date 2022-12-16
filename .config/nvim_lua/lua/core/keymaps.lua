vim.g.mapleader = ' '
vim.g.maplocalleader = ' '

vim.opt.backspace = '2'
vim.opt.showcmd = true
vim.opt.laststatus = 2
-- autowrite write the contents of the file, I prefer hidden
--vim.opt.autowrite = true 
vim.opt.hidden = true
vim.opt.cursorline = true
vim.opt.autoread = true -- keep block cursor on insert mode

-- use spaces for tabs and whatnot
vim.opt.tabstop = 2
vim.opt.softtabstop = 4
vim.opt.shiftwidth = 2
vim.opt.shiftround = true
vim.opt.expandtab = true
vim.opt.smarttab = true

vim.opt.smartindent = true

vim.opt.wrap = false

-- go to previous/next line with h,l,left arrow and right arrow when cursor reaches end/beginning of line
vim.opt.whichwrap:append "<>[]hl"

-- Undo
vim.opt.swapfile = false
vim.opt.backup = false
vim.opt.undofile = true
vim.opt.undodir = os.getenv("HOME") .. "/.vim/undodir"
--if vim.fn.isdirectory(vim.inspect(vim.opt.undodir:get())) == 0 then
--  vim.fn.mkdir(vim.inspect(vim.opt.undodir:get()), "p")
--end

vim.opt.clipboard = "unnamedplus" -- Access system clipboard

no_buffers_menu = 1

-- Encoding
vim.opt.encoding= 'utf-8'
vim.opt.fileencoding= 'utf-8'
vim.opt.fileencodings= 'utf-8'

-- Searching
vim.opt.hlsearch = false
vim.opt.incsearch = true
vim.opt.ignorecase = false
vim.opt.smartcase = false
vim.opt.hlsearch = false          -- remove highlight after search

-- Better search
vim.opt.path:remove "/usr/include"
vim.opt.path:append "**"
-- vim.cmd [[set path=.,,,$PWD/**]] -- Set the path directly

vim.opt.wildignorecase = true
vim.opt.wildignore:append "**/node_modules/*"
vim.opt.wildignore:append "**/.git/*"

-- Treesitter based folding
vim.cmd [[
  set foldlevel=20
  set foldmethod=expr
  set foldexpr=nvim_treesitter#foldexpr()
]]

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
vim.opt.guifont="Inconsolata:16"
--vim.g.webdevicons_enable = 0
--vim.g.webdevicons_enable_nerdtree = 1

-- Mouse support
vim.opt.mouse = 'a'
vim.opt.mousemodel = 'popup'

-- Cursor
vim.opt.guicursor = '' -- keep block cursor on insert mode

--- My remaps
-- Auto closing brackets
vim.keymap.set('i', '{<CR>', '{<CR>}<Esc>ko')
vim.keymap.set('i', '(<CR>', '(<CR>)<Esc>ko')
vim.keymap.set('i', '[<CR>', '[<CR>]<Esc>ko')

-- Special Yanks
vim.keymap.set('n', 'Y', 'y$') -- Copy from cursor to end of line
vim.keymap.set('n', 'x', '"_x') -- Do not yank with x

vim.keymap.set('n', '<leader>h', ':nohlsearch<CR>') -- clear highlights on search results

-- Switching windows
vim.keymap.set('n', '<C-h>', '<C-w>h') -- left
vim.keymap.set('n', '<C-l>', '<C-w>l') -- right
vim.keymap.set('n', '<C-k>', '<C-w>k') -- up
vim.keymap.set('n', '<C-j>', '<C-w>j') -- down

-- Buffers
vim.keymap.set('n', '<leader>z', ':bp<CR>') -- navigate previous buffer
vim.keymap.set('n', '<leader>q', ':bp<CR>') -- navigate previous buffer
vim.keymap.set('n', '<leader>x', ':bn<CR>') -- navigate next buffer
vim.keymap.set('n', '<leader>w', ':bn<CR>') -- navigate next buffer
vim.keymap.set('n', '<leader>c', ':bd<CR>') -- close buffer

-- Split
vim.keymap.set('n', '<leader>h', ':<C-u>split<CR>') -- horizontal split
vim.keymap.set('n', '<leader>v', ':<C-u>vsplit<CR>') -- vertical split

-- Move visual block
vim.cmd [[vnoremap J :m '>+1<CR>gv=gv]]
vim.cmd [[vnoremap K :m '<-2<CR>gv=gv]]
-- having trouble to set it in lua
-- vim.keymap.set('n', 'J', ":m '>+1<CR>gv=gv")
-- vim.keymap.set('n', 'K', ":m '<-2<CR>gv=gv")

vim.keymap.set('v', '<', '<gv') -- in visual mode, move block to the right
vim.keymap.set('v', '>', '>gv') -- in visual mode, move block to the left

-- Undotree
vim.keymap.set('n', '<leader>u', ':UndotreeShow<CR>')

-- print(vim.inspect(vim.opt.formatoptions:get()))
