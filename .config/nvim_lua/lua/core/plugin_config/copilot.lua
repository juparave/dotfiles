-- disable copilot.lua's suggestion and panel modules
require('copilot').setup({
    suggestion = { enable = false },
    panel = { enable = false },
})

-- ref: https://github.com/zbirenbaum/copilot-cmp
-- require('copilot_cmp').setup {
--     method = 'getCompletionsCycling',
-- }
