require("lsp-format").setup({})

vim.api.nvim_create_autocmd("LspAttach", {
    callback = function(args)
        local client = assert(vim.lsp.get_client_by_id(args.data.client_id))
        require("lsp-format").on_attach(client, args.buf)
    end,
})

-- lemminx, substitute for xmlformat
-- https://github.com/neovim/nvim-lspconfig/blob/master/doc/server_configurations.md#lemminx
-- require'lspconfig'.lemminx.setup{}

-- LSP Format on Save
local format_on_save = function(bufnr)
    vim.api.nvim_create_autocmd("BufWritePre", {
        buffer = bufnr,
        callback = function()
            vim.lsp.buf.format({ async = false })
        end,
    })
end

-- Define capabilities and on_attach BEFORE using them
local capabilities = require("cmp_nvim_lsp").default_capabilities()
local on_attach = function(client, bufnr)
    if client.name == "eslint" then
        vim.cmd.LspStop("eslint")
        return
    end

    -- Attach formatting on save
    -- format_on_save(bufnr)

    local opts = { buffer = bufnr, remap = false }
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

-- Set up mason for package management only (no automatic LSP setup)
require("mason").setup()

require("mason-lspconfig").setup({
    ensure_installed = { "lua_ls", "gopls", "pyright", "angularls", "ts_ls", "eslint" }, -- Specify the servers you want to ensure are installed
    automatic_installation = false,                                                   -- Disable automatic installation
    automatic_enable = {
        exclude = { "gopls", "angularls", "svelteserver" },                           -- Exclude servers from automatic enabling
    },
})

-- Manual setup for each server to ensure only one instance
local lspconfig = require("lspconfig")

-- lspconfig.lua_ls.setup {
--     on_attach = on_attach,
--     capabilities = capabilities,
-- }

lspconfig.gopls.setup({
    on_attach = on_attach,
    capabilities = capabilities,
    cmd = { "gopls" }, -- Use simple command, let mason handle the path
    settings = {
        gopls = {
            analyses = {
                unusedparams = true,
            },
            staticcheck = true,
            gofumpt = true,
        },
    },
})

lspconfig.angularls.setup({
    on_attach = on_attach,
    capabilities = capabilities,
    cmd = { "angularls" }, -- Use simple command, let mason handle the path
    filetypes = { "typescript", "html", "typescriptreact", "typescript.tsx" },
    root_dir = lspconfig.util.root_pattern("angular.json", "package.json"),
})

lspconfig.svelte.setup({
    on_attach = on_attach,
    capabilities = capabilities,
    cmd = { "svelteserver", "--stdio" }, -- Use simple command, let mason handle the path
    filetypes = { "svelte" },
    root_dir = lspconfig.util.root_pattern("svelte.config.js", "package.json"),
})

-- lspconfig.pyright.setup {
--     on_attach = on_attach,
--     capabilities = capabilities,
-- }

local util = require("lspconfig.util")
require("lspconfig").eslint.setup({
    -- `vscode-eslint-language-server` is a linting engine for JavaScript / Typescript.
    -- It can be installed via `npm`:
    -- npm i -g vscode-langservers-extracted
    -- Copied from nvim-lspconfig/lua/lspconfig/server_conigurations/eslint.js
    root_dir = util.root_pattern(
        ".eslintrc",
        ".eslintrc.js",
        ".eslintrc.cjs",
        ".eslintrc.yaml",
        ".eslintrc.yml",
        ".eslintrc.json"
    -- Disabled to prevent "No ESLint configuration found" exceptions
    -- 'package.json',
    ),
})

vim.diagnostic.config({
    virtual_text = true,
})
