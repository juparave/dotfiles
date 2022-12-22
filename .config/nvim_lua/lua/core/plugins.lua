local ensure_packer = function()
  local fn = vim.fn
  local install_path = fn.stdpath('data') .. '/site/pack/packer/start/packer.nvim'
  if fn.empty(fn.glob(install_path)) > 0 then
    fn.system({ 'git', 'clone', '--depth', '1', 'https://github.com/wbthomason/packer.nvim', install_path })
    vim.cmd [[packadd packer.nvim]]
    return true
  end
  return false
end

local packer_bootstrap = ensure_packer()

return require('packer').startup(function(use)
  use 'wbthomason/packer.nvim'
  -- My plugins here
  use 'nvim-lua/popup.nvim' -- An implementation of the Popup API from vim in Neovim
  use 'nvim-tree/nvim-tree.lua'
  use 'nvim-tree/nvim-web-devicons'

  -- like powerline but for neovim
  use {
    'nvim-lualine/lualine.nvim',
    requires = { 'kyazdani42/nvim-web-devicons', opt = true }
  }
  use("mbbill/undotree")

  -- theme
  use 'gruvbox-community/gruvbox'
  use { 'catppuccin/nvim', as = 'catppuccin' }
  use {
    'svrana/neosolarized.nvim',
    requires = { 'tjdevries/colorbuddy.nvim' }
  }
  use 'folke/tokyonight.nvim'
  use "EdenEast/nightfox.nvim"

  -- use 'arcticicestudio/nord-vim'

  use('nvim-treesitter/nvim-treesitter', {
    -- run = ":TSUpdate",
    run = function() require('nvim-treesitter.install').update({ with_sync = true }) end,
  })
  -- use 'nvim-treesitter/playground'

  use {
    'nvim-telescope/telescope.nvim',
    tag = '0.1.0',
    requires = { { 'nvim-lua/plenary.nvim' } },
  }
  use { 'nvim-telescope/telescope-fzf-native.nvim', run = 'make' }
  use 'nvim-telescope/telescope-file-browser.nvim'

  use 'tpope/vim-fugitive'

  -- Better surround
  use { "tpope/vim-surround", event = "BufReadPre" }
  use {
    "Matt-A-Bennett/vim-surround-funk",
    event = "BufReadPre",
    config = function()
      require("core.plugin_config.surroundfunk").setup()
    end,
    disable = true,
  }

  -- Buffer line
  use {
    "akinsho/nvim-bufferline.lua",
    event = "BufReadPre",
    wants = "nvim-web-devicons",
    config = function()
      require("core.plugin_config.bufferline").setup()
    end,
  }

  -- emmet
  use "mattn/emmet-vim"

  -- Svelte plugins for linting, highliting and prettifing
  use 'pangloss/vim-javascript'
  use 'maxmellon/vim-jsx-pretty'
  use 'w0rp/ale'
  use 'burner/vim-svelte'
  use 'leafOfTree/vim-svelte-plugin'

  -- which key
  use {
    "folke/which-key.nvim",
    config = function()
      require("which-key").setup {
        -- your configuration comes here
        -- or leave it empty to use the default settings
        -- refer to the configuration section below
      }
    end
  }

  -- Cmp plugins
  use "hrsh7th/nvim-cmp" -- The completion plugin
  use "hrsh7th/cmp-buffer" -- buffer completions
  use "hrsh7th/cmp-path" -- path completions
  use "hrsh7th/cmp-cmdline" -- cmdline completions
  use "saadparwaiz1/cmp_luasnip" -- snippet completions
  use "hrsh7th/cmp-nvim-lsp" -- lsp completion
  use "hrsh7th/cmp-nvim-lua"

  -- Snippets
  use "L3MON4D3/LuaSnip" --snippet engine
  use "rafamadriz/friendly-snippets" -- a bunch of snippets to use

  use "tpope/vim-commentary"

  -- LSP
  use 'williamboman/mason.nvim'
  use 'williamboman/mason-lspconfig.nvim'
  use 'neovim/nvim-lspconfig' -- Enable LSP
  use 'jose-elias-alvarez/null-ls.nvim' -- Use Neovim as a language server to inject LSP diagnostics, code actions, and more via Lua
  use 'MunifTanjim/prettier.nvim' -- Prettier
  use 'sveltejs/prettier-plugin-svelte'
  use 'lukas-reineke/lsp-format.nvim'

--  -- Debugging
--  use 'mfussenegger/nvim-dap'
--  use 'leoluz/nvim-dap-go'
--  use 'rcarriga/nvim-dap-ui'
--  use 'theHamsta/nvim-dap-virtual-text'
--  use 'nvim-telescope/telescope-dap.nvim'
--
--  -- Misc
  use 'windwp/nvim-autopairs' -- Autopairs
  use 'windwp/nvim-ts-autotag' -- Use treesitter to auto close and auto rename html tag
--  use 'norcalli/nvim-colorizer.lua'
--  use 'folke/zen-mode.nvim'
--  use({
--    "iamcco/markdown-preview.nvim",
--    run = function() vim.fn["mkdp#util#install"]() end,
--  })
--
--  use 'lewis6991/gitsigns.nvim'
--  use 'dinhhuy258/git.nvim' -- For git blame & browse

  -- Automatically set up your configuration after cloning packer.nvim
  -- Put this at the end after all plugins
  if packer_bootstrap then
    require('packer').sync()
  end
end)
