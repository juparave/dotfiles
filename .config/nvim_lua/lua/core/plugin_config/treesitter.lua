-- nvim-treesitter v1 (main branch) — no longer uses nvim-treesitter.configs
-- Highlighting is now handled by Neovim's built-in vim.treesitter

local ts = require('nvim-treesitter')
ts.setup()

-- Install parsers on startup (equivalent to old ensure_installed)
local parsers = { "c", "lua", "rust", "go", "vim", "javascript", "typescript", "html", "angular", "gitcommit", "diff", "git_rebase" }

-- Defensive installation call for v1
local function install_parsers()
  if type(ts.install) == "function" then
    ts.install(parsers)
  else
    local ok, tsi = pcall(require, 'nvim-treesitter.install')
    if ok and type(tsi.install) == "function" then
      tsi.install(parsers)
    end
  end
end

-- Schedule it to avoid potential race conditions during startup
vim.schedule(install_parsers)

-- Enable treesitter highlighting per filetype (replaces highlight.enable = true)
vim.api.nvim_create_autocmd('FileType', {
  callback = function()
    local ft = vim.bo.filetype
    local lang = vim.treesitter.language.get_lang(ft) or ft
    pcall(vim.treesitter.start, nil, lang)
  end,
})
=======
-- require'nvim-treesitter.configs'.setup {
--   -- A list of parser names, or "all"
--   ensure_installed = { "c", "lua", "rust", "go", "vim", "javascript", "typescript" },

--   -- Install parsers synchronously (only applied to `ensure_installed`)
--   sync_install = false,
--   auto_install = true,
--   highlight = {
--     enable = true,
--   },
-- }
