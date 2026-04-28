# Upgrading to Neovim 0.12.1 — nvim-treesitter Migration Guide

## What breaks

After upgrading to NVIM v0.12.1, **nvim-treesitter** (on the `master` branch) throws:

```
Decoration provider "conceal_line" (ns=nvim.treesitter.highlighter):
Lua: .../vim/treesitter.lua:196: attempt to call method 'range' (a nil value)
```

This is caused by a breaking change in the Neovim 0.12 treesitter node API. The `master`
branch of nvim-treesitter is **archived** and will not receive a fix. The actively
maintained branch is now `main`, which is a full v1 rewrite.

---

## Step 1 — Switch nvim-treesitter to the `main` branch

### If using Packer

In your plugins file, add `branch = 'main'` to the nvim-treesitter entry:

```lua
use('nvim-treesitter/nvim-treesitter', {
    branch = 'main',
    run = function() require('nvim-treesitter.install').update({ with_sync = true }) end,
})
```

Then run `:PackerSync` inside Neovim.

### If using Lazy.nvim

```lua
{
    'nvim-treesitter/nvim-treesitter',
    branch = 'main',
    build = function() require('nvim-treesitter').update() end,
}
```

---

## Step 2 — Update your treesitter config

The `nvim-treesitter.configs` module **no longer exists** in v1. Replace your old config:

```lua
-- OLD (master branch) — will error on v1
require('nvim-treesitter.configs').setup {
  ensure_installed = { ... },
  auto_install = true,
  highlight = { enable = true },
}
```

With the new v1 API:

```lua
-- NEW (main branch / v1)
require('nvim-treesitter').setup()

-- Install parsers
require('nvim-treesitter').install({ "c", "lua", "rust", "go", "vim", "javascript", "typescript" })

-- Enable highlighting (now handled by Neovim's built-in vim.treesitter)
vim.api.nvim_create_autocmd('FileType', {
  callback = function(args)
    pcall(vim.treesitter.start, args.buf)
  end,
})
```

---

## Step 3 — Install the `tree-sitter` CLI

nvim-treesitter v1 **requires the `tree-sitter` CLI** to compile parsers locally.
Pre-built binaries are no longer downloaded automatically.

```bash
# via npm (recommended, faster)
npm install -g tree-sitter-cli

# or via cargo
cargo install tree-sitter-cli
```

---

## Step 4 — Install parsers

After restarting Neovim, install your parsers:

```vim
:TSInstall c lua rust go vim javascript typescript
```

Or install all stable parsers:

```vim
:TSInstall stable
```

---

## Notes on dependent plugins

Some plugins that rely on nvim-treesitter may also need updates:

- **nvim-treesitter-context** — update to latest, may need config adjustments
- **nvim-ts-autotag** — update to latest; v1 compatibility was added recently
- **nvim-treesitter/playground** — discontinued, use `:InspectTree` (built into Neovim 0.9+)
