return {
  {
    "nvim-treesitter/nvim-treesitter",
    build = ":TSUpdate",
    config = function()
      local config = require("nvim-treesitter.configs")
      config.setup({
        -- A list of parser names, or "all"
        ensure_installed = { "c", "lua", "rust", "go", "vim", "javascript", "typescript" },

        auto_install = true,
        highlight = { enable = true },
        indent = { enable = true },
      })
    end
  }
}
