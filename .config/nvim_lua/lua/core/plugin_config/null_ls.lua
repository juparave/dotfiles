local null_ls = require("null-ls")

-- ref: https://raw.githubusercontent.com/jose-elias-alvarez/null-ls.nvim/main/doc/BUILTINS.md
-- run :lua vim.lsp.buf.format() to format the current buffer

null_ls.setup({
    sources = {
        null_ls.builtins.formatting.stylua,
        null_ls.builtins.formatting.xmlformat,
        null_ls.builtins.diagnostics.eslint,
        -- null_ls.builtins.completion.spell,
    },
})
