-- ale for linting
-- using vim configuration to set ale

local fixers = {
    ['*'] = { 'remove_trailing_lines', 'trim_whitespace' },
    ruby = { 'rubocop' },
    python = { 'flake8' },
    json = { 'prettier' },
}

vim.g.ale_fixers = fixers

-- auto linting fixed using lsp-format and installing jsonlsp from Mason
