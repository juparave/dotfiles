
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
      {"BufWritePre", "*.go", "lua goimports(1000)"},
    }
  })

function goimports(timeout_ms)
  local context = { source = { organizeImports = true } }
  vim.validate { context = { context, "t", true } }

  local params = vim.lsp.util.make_range_params()
  params.context = context

  -- See the implementation of the textDocument/codeAction callback
  -- (lua/vim/lsp/handler.lua) for how to do this properly.
  local result = vim.lsp.buf_request_sync(0, "textDocument/codeAction", params, timeout_ms)
  for cid, res in pairs(result or {}) do
    for _, r in pairs(res.result or {}) do

      -- textDocument/codeAction can return either Command[] or CodeAction[]. If it
      -- is a CodeAction, it can have either an edit, a command or both. Edits
      -- should be executed first.
      if r.edit or type(r.command) == "table" then
        if r.edit then
          local enc = (vim.lsp.get_client_by_id(cid) or {}).offset_encoding or "utf-16"
          vim.lsp.util.apply_workspace_edit(r.edit, enc)
        end
        if type(r.command) == "table" then
          vim.lsp.buf.execute_command(r.command)
        end
      else
        vim.lsp.buf.execute_command(r)
      end
    end
  end
end
