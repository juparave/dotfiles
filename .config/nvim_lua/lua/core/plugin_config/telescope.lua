local builtin = require('telescope.builtin')

vim.keymap.set('n', '<leader>e', builtin.find_files, {})
--vim.keymap.set('n', '<Space><Space>', builtin.oldfiles, {})
vim.keymap.set('n', '<leader>f', builtin.live_grep, {})
vim.keymap.set('n', '<leader>t', builtin.help_tags, {})

vim.keymap.set('i', '<C-j>', '<Down>')
vim.keymap.set('i', '<C-k>', '<Up>')
