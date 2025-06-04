-- Keymaps are automatically loaded on the VeryLazy event
-- Default keymaps that are always set: https://github.com/LazyVim/LazyVim/blob/main/lua/lazyvim/config/keymaps.lua
-- Add any additional keymaps here

-- Import & assign the map() function from the utils module
local map = require("utils").map

--- My remaps
-- Auto closing brackets
map('i', '{<CR>', '{<CR>}<Esc>ko')
map('i', '(<CR>', '(<CR>)<Esc>ko')
map('i', '[<CR>', '[<CR>]<Esc>ko')

-- Special Yanks
map('n', 'Y', 'y$')                      -- Copy from cursor to end of line
map('n', 'x', '"_x')                     -- Do not yank with x

map('n', '<leader>h', ':nohlsearch<CR>') -- clear highlights on search results

-- Switching windows
map('n', '<C-h>', '<C-w>h') -- left
map('n', '<C-l>', '<C-w>l') -- right
map('n', '<C-k>', '<C-w>k') -- up
map('n', '<C-j>', '<C-w>j') -- down

-- Buffers
map('n', '<leader>z', ':bp<CR>') -- navigate previous buffer
map('n', '<leader>q', ':bp<CR>') -- navigate previous buffer
map('n', '<leader>x', ':bn<CR>') -- navigate next buffer
map('n', '<leader>w', ':bn<CR>') -- navigate next buffer
-- map('n', '<leader>c', ':bd<CR>') -- close buffer

-- Split
map('n', '<leader>h', ':<C-u>split<CR>')  -- horizontal split
map('n', '<leader>v', ':<C-u>vsplit<CR>') -- vertical split

-- Move visual block
vim.cmd [[vnoremap J :m '>+1<CR>gv=gv]]
vim.cmd [[vnoremap K :m '<-2<CR>gv=gv]]
-- having trouble to set it in lua
-- map('v', 'J', ":m '>+1<CR>gv=gv")
-- map('v', 'K', ":m '<-2<CR>gv=gv")

map('v', '<', '<gv') -- in visual mode, move block to the right
map('v', '>', '>gv') -- in visual mode, move block to the left

-- Undotree
map('n', '<leader>u', ':UndotreeShow<CR>')

-- Paste without copying replaced text
map('x', '<leader>p', "\"_dP")

-- replace current word, ref: ThePrimeagen (fantastic!)
vim.keymap.set("n", "<leader>s", ":%s/\\<<C-r><C-w>\\>/<C-r><C-w>/gI<Left><Left><Left>")

-- zoom like a pro
map('n', 'Zz', '<C-w>_ | <C-w>|')
map('n', 'Zo', '<C-w>=')

-- close all buffer but this one
map('n', '<leader>o', ':%bd|e#|bd#<CR>', { desc = 'Close all but' })

-- print(vim.inspect(vim.opt.formatoptions:get()))
