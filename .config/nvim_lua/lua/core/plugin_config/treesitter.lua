-- nvim-treesitter v1 (main branch) — no longer uses nvim-treesitter.configs
-- Highlighting is now handled by Neovim's built-in vim.treesitter

require('nvim-treesitter').setup()

-- Install parsers on startup (equivalent to old ensure_installed)
local parsers = { "c", "lua", "rust", "go", "vim", "javascript", "typescript" }
require('nvim-treesitter.install').ensure_installed(parsers)

-- Enable treesitter highlighting per filetype (replaces highlight.enable = true)
vim.api.nvim_create_autocmd('FileType', {
  callback = function(args)
    pcall(vim.treesitter.start, args.buf)
  end,
})
