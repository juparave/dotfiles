function ColorMyPencils(color)
    color = color or "tokyonight"
    vim.cmd.colorscheme(color)

    --	vim.api.nvim_set_hl(0, "Normal", { bg = "none" })
    --	vim.api.nvim_set_hl(0, "NormalFloat", { bg = "none" })
end

require('nightfox').setup({
    options = {
        styles = {
            --     comments = "italic",
            keywords = "bold",
            types = "bold",
            comments = "NONE", -- Value is any valid attr-list value `:help attr-list`
            conditionals = "NONE",
            constants = "NONE",
            functions = "NONE",
            numbers = "NONE",
            operators = "NONE",
            strings = "NONE",
            variables = "NONE",
        }
    }
})


ColorMyPencils("nightfox")

function Dayfox()
    vim.cmd.colorscheme("dayfox")
    require("lualine").setup {
        options = {
            theme = "dayfox",
        },
    }
end

function Dawnfox()
    vim.cmd.colorscheme("dawnfox")
    require("lualine").setup {
        options = {
            theme = "dawnfox",
        },
    }
end

function Nightfox()
    vim.cmd.colorscheme("nightfox")
    require("lualine").setup {
        options = {
            theme = "nightfox",
        },
    }
end
