local status_ok, _ = pcall(require, "nvim-lsp-installer")
if not status_ok then
  return
end

-- Register a handler that will be called for all installed servers.
-- Alternatively, you may also register handlers on specific server instances instead (see example below).
local lsp_installer = require("nvim-lsp-installer")
local nvim_lsp = require("lspconfig")

lsp_installer.settings({
    ui = {
      icons = {
        server_installed = "✓",
        server_pending = "➜",
        server_uninstalled = "✗"
      }
    }
  })

lsp_installer.on_server_ready(function(server)
  local opts = {
    on_attach = require("core.lsp.handlers").on_attach,
    capabilities = require("core.lsp.handlers").capabilities,
  }

  if server.name == "jsonls" then
    local jsonls_opts = require("core.lsp.settings.jsonls")
    opts = vim.tbl_deep_extend("force", jsonls_opts, opts)
  end

  -- if server.name == "sumneko_lua" then
  -- local sumneko_opts = require("core.lsp.settings.sumneko_lua")
  -- opts = vim.tbl_deep_extend("force", sumneko_opts, opts)
  -- end
  if server.name == "gopls" then
    local gopls_ops = require("core.lsp.settings.gopls")
    opts = vim.tbl_deep_extend("force", gopls_ops, opts)
  end

  if server.name == "pyright" then
    local pyright_opts = require("core.lsp.settings.pyright")
    opts = vim.tbl_deep_extend("force", pyright_opts, opts)
  end

  -- This setup() function is exactly the same as lspconfig's setup function.
  -- Refer to https://github.com/neovim/nvim-lspconfig/blob/master/doc/server_configurations.md
  server:setup(opts)
end)