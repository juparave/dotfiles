
-- Format code on save using LSP
-- vim.cmd [[autocmd BufWritePre <buffer> lua vim.lsp.buf.formatting_sync()]]
-- vim.cmd [[autocmd BufWritePre * lua vim.lsp.buf.formatting_sync()]]

-- Formatting and Autoimports in Go
function nvim_create_augroups(definitions)
  for group_name, definition in pairs(definitions) do
    vim.api.nvim_command('augroup '..group_name)
    vim.api.nvim_command('autocmd!')
    for _, def in ipairs(definition) do
      local command = table.concat(vim.tbl_flatten{'autocmd', def}, ' ')
      vim.api.nvim_command(command)
    end
    vim.api.nvim_command('augroup END')
  end
end

nvim_create_augroups({
    go_save = {
      {"BufWritePre", "*.go", "lua vim.lsp.buf.format({ async = true, offset_encoding = 'utf-16' })"},
      {"BufWritePre", "*.go", "lua go_org_imports"},
      -- {"BufWritePre", "*.go", "lua goimports(1000)"},
    },
    go_shiftwith = {
      {"BufNewFile,BufRead", "*.go", "setlocal noexpandtab tabstop=4 shiftwidth=4 softtabstop=4"},
    }
  })

function go_org_imports(wait_ms)
    local params = vim.lsp.util.make_range_params()
    params.context = {only = {"source.organizeImports"}}
    local result = vim.lsp.buf_request_sync(0, "textDocument/codeAction", params, wait_ms)
    for cid, res in pairs(result or {}) do
      for _, r in pairs(res.result or {}) do
        if r.edit then
          local enc = (vim.lsp.get_client_by_id(cid) or {}).offset_encoding or "utf-16"
          vim.lsp.util.apply_workspace_edit(r.edit, enc)
        end
      end
    end
  end
