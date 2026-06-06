-- nvim-treesitter v1 (main branch) — no longer uses nvim-treesitter.configs
-- Highlighting is now handled by Neovim's built-in vim.treesitter

local ts = require('nvim-treesitter')
ts.setup()

-- Install parsers on startup (equivalent to old ensure_installed)
local parsers = { "c", "lua", "rust", "go", "vim", "javascript", "typescript", "html", "angular", "gitcommit", "diff", "git_rebase" }

-- Only install parsers that are not yet compiled
vim.schedule(function()
    local installed = {}
    for _, p in ipairs(ts.get_installed()) do installed[p] = true end

    local missing = {}
    for _, p in ipairs(parsers) do
        if not installed[p] then table.insert(missing, p) end
    end

    if #missing > 0 then
        ts.install(missing)
    end
end)

-- Enable treesitter highlighting per filetype (replaces highlight.enable = true)
vim.api.nvim_create_autocmd('FileType', {
  callback = function()
    local ft = vim.bo.filetype
    local lang = vim.treesitter.language.get_lang(ft) or ft
    pcall(vim.treesitter.start, nil, lang)
  end,
})
