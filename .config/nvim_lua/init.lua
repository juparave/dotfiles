-- Make nvm-managed node visible to plugins (Copilot, tree-sitter, etc.)
local nvm_default = vim.fn.expand("~/.nvm/alias/default")
if vim.fn.filereadable(nvm_default) == 1 then
    local major = vim.fn.trim(vim.fn.readfile(nvm_default)[1])
    local matches = vim.fn.glob(vim.fn.expand("~/.nvm/versions/node/v") .. major .. ".*", false, true)
    table.sort(matches)
    if #matches > 0 then
        vim.env.PATH = matches[#matches] .. "/bin:" .. vim.env.PATH
    end
end

require("core.set")
require("core.keymaps")
require("core.plugins")
require("core.plugin_config")
require("core.theme")
