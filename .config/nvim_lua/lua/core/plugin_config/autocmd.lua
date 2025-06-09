-- Format code on save using LSP
-- vim.cmd [[autocmd BufWritePre <buffer> lua vim.lsp.buf.formatting_sync()]]
-- vim.cmd [[autocmd BufWritePre * lua vim.lsp.buf.formatting_sync()]]

-- Formatting and Autoimports in Go
function nvim_create_augroups(definitions)
    for group_name, definition in pairs(definitions) do
        vim.api.nvim_command('augroup ' .. group_name)
        vim.api.nvim_command('autocmd!')
        for _, def in ipairs(definition) do
            local command = table.concat(vim.tbl_flatten { 'autocmd', def }, ' ')
            vim.api.nvim_command(command)
        end
        vim.api.nvim_command('augroup END')
    end
end

nvim_create_augroups({
    go_save = {
        -- disabled if using lsp-formar.nvim plugin
        -- { "BufWritePre", "*.go", "lua vim.lsp.buf.format({ async = true, offset_encoding = 'utf-16' })" },

        { "BufWritePre", "*.go", "lua go_org_imports(500)" },
        -- { "BufWritePre", "*.go", "lua goimports(500)" },
    },
    html_shiftwith = {
        { "BufNewFile,BufRead", "*.html", "setlocal expandtab tabstop=2 shiftwidth=2 softtabstop=2" },
    },
    svelte_shiftwith = {
        { "BufNewFile,BufRead", "*.svelte", "setlocal expandtab tabstop=2 shiftwidth=2 softtabstop=2" },
        -- {"BufNewFile,BufRead", "*.svelte", "setlocal equalprg=lua vim.lsp.buf.format()"},
    },
    typescript_shiftwith = {
        { "BufNewFile,BufRead", "*.ts", "setlocal expandtab tabstop=2 shiftwidth=2 softtabstop=2" },
        -- {"BufNewFile,BufRead", "*.svelte", "setlocal equalprg=lua vim.lsp.buf.format()"},
    },
    svelte_save = {
        -- disabled if using lsp-formar.nvim plugin
        -- {"BufWritePre", "*.svelte", "lua vim.lsp.buf.format()"},
    },
    go_shiftwith = {
        { "BufNewFile,BufRead", "*.tmpl", "setlocal expandtab tabstop=2 shiftwidth=2 softtabstop=2" },
        { "BufNewFile,BufRead", "*.go",   "setlocal noexpandtab tabstop=4 shiftwidth=4 softtabstop=4" },
    },
    restore_cursor = {
        { 'BufRead', '*', [[call setpos(".", getpos("'\""))]] },
    },
    lua_shiftwith = {
        { "BufNewFile,BufRead", "*.lua", "setlocal expandtab tabstop=4 shiftwidth=4 softtabstop=4" },
    },
})

function go_org_imports(wait_ms)
    local params = vim.lsp.util.make_range_params()
    params.context = { only = { "source.organizeImports" } }
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

-- ref: https://www.getman.io/posts/programming-go-in-neovim/
function goimports(timeoutms)
    -- local context = { source = { organizeImports = true } }
    local context = { only = { "source.organizeImports" } }
    vim.validate { context = { context, "t", true } }

    local params = vim.lsp.util.make_range_params()
    params.context = context

    -- See the implementation of the textDocument/codeAction callback
    -- (lua/vim/lsp/handler.lua) for how to do this properly.
    local result = vim.lsp.buf_request_sync(0, "textDocument/codeAction", params, timeoutms)
    if not result or next(result) or result[1] == nil then return end
    local actions = result[1].result
    if not actions then return end
    local action = actions[1]

    -- textDocument/codeAction can return either Command[] or CodeAction[]. If it
    -- is a CodeAction, it can have either an edit, a command or both. Edits
    -- should be executed first.
    if action.edit or type(action.command) == "table" then
        if action.edit then
            -- local enc = (vim.lsp.get_client_by_id(cid) or {}).offset_encoding or "utf-16"
            local enc = "utf-16"
            vim.lsp.util.apply_workspace_edit(action.edit, enc)
        end
        if type(action.command) == "table" then
            vim.lsp.buf.execute_command(action.command)
        end
    else
        vim.lsp.buf.execute_command(action)
    end
end
