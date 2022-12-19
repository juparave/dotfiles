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
-- vim.keymap.set('v', 'J', ":m '>+1<CR>gv=gv")
-- vim.keymap.set('v', 'K', ":m '<-2<CR>gv=gv")

vim.keymap.set('v', '<', '<gv') -- in visual mode, move block to the right
vim.keymap.set('v', '>', '>gv') -- in visual mode, move block to the left

-- Undotree
vim.keymap.set('n', '<leader>u', ':UndotreeShow<CR>')

-- Paste without copying replaced text
vim.keymap.set('x', '<leader>p', "\"_dP")

-- print(vim.inspect(vim.opt.formatoptions:get()))
