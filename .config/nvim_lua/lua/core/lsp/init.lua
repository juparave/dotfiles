local status_ok, _ = pcall(require, "lspconfig")
if not status_ok then
  return
end

-- require("core.lsp.lsp-installer")
-- require("core.lsp.handlers").setup()
require("core.lsp.autocmd")

require("mason").setup()
require("mason-lspconfig").setup({
        ensure_installed = {
            "sumneko_lua",
            "gopls"
        }
    })

require("lspconfig").sumneko_lua.setup { }
