-- Session management
vim.g.session_autoload = "no"
vim.g.session_autosave = "no"
vim.g.session_command_aliases = 1

vim.g.session_directory = "~/.vim/session"

--if vim.fn.isdirectory(vim.g.session_directory) == 0 then
--  vim.fn.mkdir(vim.g.session_directory, "p")
--end
