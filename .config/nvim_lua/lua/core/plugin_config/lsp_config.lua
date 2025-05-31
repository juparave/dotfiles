require("mason").setup()
require("mason-lspconfig").setup({
    ensure_installed = { "lua_ls", "gopls", "pyright" }
})

require("lsp-format").setup {}

-- lemminx, substitute for xmlformat
-- https://github.com/neovim/nvim-lspconfig/blob/master/doc/server_configurations.md#lemminx
-- require'lspconfig'.lemminx.setup{}


local capabilities = require('cmp_nvim_lsp').default_capabilities()
local on_attach = function(client, bufnr)
    -- attach lsp-format
    require("lsp-format").on_attach(client)

    local opts = { buffer = bufnr, remap = false }

    if client.name == "eslint" then
        vim.cmd.LspStop('eslint')
        return
    end


    vim.keymap.set("n", "gd", vim.lsp.buf.definition, opts)
    vim.keymap.set("n", "K", vim.lsp.buf.hover, opts)
    vim.keymap.set("n", "<leader>vws", vim.lsp.buf.workspace_symbol, opts)
    vim.keymap.set("n", "<leader>vd", vim.diagnostic.open_float, opts)
    vim.keymap.set("n", "[d", vim.diagnostic.goto_next, opts)
    vim.keymap.set("n", "]d", vim.diagnostic.goto_prev, opts)
    vim.keymap.set("n", "<leader>vca", vim.lsp.buf.code_action, opts)
    vim.keymap.set("n", "<leader>vrr", vim.lsp.buf.references, opts)
    vim.keymap.set("n", "<leader>vrn", vim.lsp.buf.rename, opts)
    vim.keymap.set("i", "<C-h>", vim.lsp.buf.signature_help, opts)
end

local lspconfig = require("lspconfig")
lspconfig.lua_ls.setup {
    on_attach = on_attach,
    capabilities = capabilities,
}
lspconfig.gopls.setup {
    on_attach = on_attach,
    capabilities = capabilities,
}
lspconfig.pyright.setup {
    on_attach = on_attach,
    capabilities = capabilities,
}


-- require("lspconfig").sumneko_lua.setup {
--   on_attach = on_attach,
--   capabilities = capabilities,
-- }

-- require("lspconfig").gopls.setup {
--   on_attach = on_attach,
--   capabilities = capabilities,
-- }

-- require("lspconfig").pyright.setup {
--   on_attach = on_attach,
--   capabilities = capabilities,
-- }

local util = require 'lspconfig.util'
require 'lspconfig'.eslint.setup {
    -- `vscode-eslint-language-server` is a linting engine for JavaScript / Typescript.
    -- It can be installed via `npm`:
    -- npm i -g vscode-langservers-extracted
    -- Copied from nvim-lspconfig/lua/lspconfig/server_conigurations/eslint.js
    root_dir = util.root_pattern(
        '.eslintrc',
        '.eslintrc.js',
        '.eslintrc.cjs',
        '.eslintrc.yaml',
        '.eslintrc.yml',
        '.eslintrc.json'
    -- Disabled to prevent "No ESLint configuration found" exceptions
    -- 'package.json',
    ),
}

vim.diagnostic.config({
    virtual_text = true,
})
