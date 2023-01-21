local builtin = require('telescope.builtin')
-- ref: https://github.com/alpha2phi/neovim-for-beginner/blob/13-fuzzysearch-02/lua/config/telescope.lua
local telescope = require('telescope')
local actions = require('telescope.actions')
-- print("telescope setup")


telescope.setup {
    defaults = {
        -- Default configuration for telescope goes here:
        -- config_key = value,
        mappings = {
            i = {
                -- map actions.which_key to <C-h> (default: <C-/>)
                -- actions.which_key shows the mappings for your picker,
                -- e.g. git_{create, delete, ...}_branch for the git_branches picker
                ["<C-h>"] = "which_key",
                ["<C-j>"] = actions.move_selection_next,
                ["<C-k>"] = actions.move_selection_previous,
                ["<C-n>"] = actions.cycle_history_next,
                ["<C-p>"] = actions.cycle_history_prev,
            }
        },
        file_ignore_patterns = { "node_modules" }
    },
    pickers = {
        -- Default configuration for builtin pickers goes here:
        -- picker_name = {
        --   picker_config_key = value,
        --   ...
        -- }
        -- Now the picker_config_key will be applied every time you call this
        -- builtin picker
    },
    extensions = {
        -- Your extension configuration goes here:
        -- extension_name = {
        --   extension_config_key = value,
        -- }
        -- please take a look at the readme of the extension you want to configure
        fzf = {
            fuzzy = true, -- false will only do exact matching
            override_generic_sorter = true, -- override the generic sorter
            override_file_sorter = true, -- override the file sorter
            case_mode = "smart_case", -- or "ignore_case" or "respect_case"
            -- the default case_mode is "smart_case"
        }
    }

}

require('telescope').load_extension('fzf')


vim.keymap.set('n', '<leader>e', builtin.find_files, { desc = "telescope find fil[e]s" })
--vim.keymap.set('n', '<Space><Space>', builtin.oldfiles, {})
vim.keymap.set('n', '<leader>f', builtin.live_grep, { desc = "[f] telescope live grep" })
vim.keymap.set('n', '<leader>t', builtin.help_tags, { desc = "telescope help [t]ags" })
vim.keymap.set('n', '<leader>b', builtin.buffers, { desc = "telescope [b]uffers" })
vim.keymap.set('n', '<leader>W', builtin.grep_string, { desc = '[S]earch current [W]ord' })
vim.keymap.set('n', '<leader>r', builtin.lsp_references, { desc = 'LSP [R]eferences for word' })
vim.keymap.set('n', '<leader>d', builtin.diagnostics, { desc = '[S]earch [D]iagnostics' })
vim.keymap.set('n', '<leader>?', builtin.oldfiles, { desc = '[?] Find recently opened files' })
vim.keymap.set('n', '<leader>/', function()
    -- You can pass additional configuration to telescope to change theme, layout, etc.
    require('telescope.builtin').current_buffer_fuzzy_find(require('telescope.themes').get_dropdown {
        winblend = 10,
        previewer = false,
    })
end, { desc = '[/] Fuzzily search in current buffer]' })
