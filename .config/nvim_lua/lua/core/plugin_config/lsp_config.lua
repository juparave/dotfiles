require("lsp-format").setup({})

vim.api.nvim_create_autocmd("LspAttach", {
	callback = function(args)
		local client = assert(vim.lsp.get_client_by_id(args.data.client_id))
		require("lsp-format").on_attach(client, args.buf)
	end,
})

-- Enhanced capabilities with additional features
local capabilities = require("cmp_nvim_lsp").default_capabilities()
capabilities.textDocument.completion.completionItem.snippetSupport = true
capabilities.textDocument.foldingRange = {
	dynamicRegistration = false,
	lineFoldingOnly = true,
}

-- LSP Format on Save
local format_on_save = function(bufnr)
	vim.api.nvim_create_autocmd("BufWritePre", {
		buffer = bufnr,
		callback = function()
			vim.lsp.buf.format({ async = false, timeout_ms = 2000 })
		end,
	})
end

-- Enhanced on_attach function
local on_attach = function(client, bufnr)
	-- Enable format on save for most servers
	if client.supports_method("textDocument/formatting") then
		format_on_save(bufnr)
	end

	-- Disable semantic tokens for certain clients to avoid conflicts
	if client.name == "ts_ls" or client.name == "angularls" then
		client.server_capabilities.semanticTokensProvider = nil
	end

	local opts = { buffer = bufnr, remap = false }
	vim.keymap.set("n", "gd", vim.lsp.buf.definition, opts)
	vim.keymap.set("n", "gD", vim.lsp.buf.declaration, opts)
	vim.keymap.set("n", "K", vim.lsp.buf.hover, opts)
	vim.keymap.set("n", "gi", vim.lsp.buf.implementation, opts)
	vim.keymap.set("n", "<leader>vws", vim.lsp.buf.workspace_symbol, opts)
	vim.keymap.set("n", "<leader>vd", vim.diagnostic.open_float, opts)
	vim.keymap.set("n", "[d", vim.diagnostic.goto_prev, opts)
	vim.keymap.set("n", "]d", vim.diagnostic.goto_next, opts)
	vim.keymap.set("n", "<leader>vca", vim.lsp.buf.code_action, opts)
	vim.keymap.set("n", "<leader>vrr", vim.lsp.buf.references, opts)
	vim.keymap.set("n", "<leader>vrn", vim.lsp.buf.rename, opts)
	vim.keymap.set("i", "<C-h>", vim.lsp.buf.signature_help, opts)
	-- vim.keymap.set("n", "<leader>f", function()
	-- 	vim.lsp.buf.format({ async = true })
	-- end, opts)
end

-- Set up mason for package management only (no automatic LSP setup)
require("mason").setup()

require("mason-lspconfig").setup({
	ensure_installed = { "lua_ls", "gopls", "pyright", "angularls", "ts_ls", "eslint", "svelte" }, -- Specify the servers you want to ensure are installed
	automatic_installation = false, -- Disable automatic installation
	automatic_enable = {
		exclude = { "gopls", "angularls", "svelteserver" }, -- Exclude servers from automatic enabling
	},
})

-- Manual setup for each server to ensure only one instance
-- Lua LSP
vim.lsp.config.lua_ls = {
	cmd = { 'lua-language-server' },
	on_attach = on_attach,
	capabilities = capabilities,
	settings = {
		Lua = {
			runtime = {
				version = "LuaJIT",
			},
			diagnostics = {
				globals = { "vim" },
			},
			workspace = {
				library = vim.api.nvim_get_runtime_file("", true),
				checkThirdParty = false,
			},
			telemetry = {
				enable = false,
			},
		},
	},
}

vim.lsp.config.gopls = {
	cmd = { "gopls" }, -- Use simple command, let mason handle the path
	on_attach = on_attach,
	capabilities = capabilities,
	settings = {
		gopls = {
			analyses = {
				unusedparams = true,
			},
			staticcheck = true,
			gofumpt = true,
		},
	},
}

-- TypeScript LSP (primary for Angular/JS/TS projects)
vim.lsp.config.ts_ls = {
	cmd = { 'typescript-language-server', '--stdio' },
	on_attach = on_attach,
	capabilities = capabilities,
	filetypes = { "typescript", "typescriptreact", "javascript", "javascriptreact" },
	root_dir = require('lspconfig.util').root_pattern("package.json", "tsconfig.json", "jsconfig.json"),
	settings = {
		typescript = {
			preferences = {
				includePackageJsonAutoImports = "on",
			},
		},
	},
}

-- Angular LSP (for Angular-specific features)
vim.lsp.config.angularls = {
	cmd = { 'ngserver', '--stdio', '--tsProbeLocations', '', '--ngProbeLocations', '' },
	on_attach = function(client, bufnr)
		-- Disable formatting, let ts_ls handle it
		client.server_capabilities.documentFormattingProvider = false
		client.server_capabilities.documentRangeFormattingProvider = false
		on_attach(client, bufnr)
	end,
	capabilities = capabilities,
	filetypes = { "typescript", "html", "typescriptreact", "typescript.tsx" },
	root_dir = require('lspconfig.util').root_pattern("angular.json", "project.json"),
}

-- Svelte LSP
vim.lsp.config.svelte = {
	cmd = { 'svelteserver', '--stdio' },
	on_attach = function(client, bufnr)
		-- Enable formatting for svelte files
		client.server_capabilities.documentFormattingProvider = true
		on_attach(client, bufnr)
	end,
	capabilities = capabilities,
	filetypes = { "svelte" },
	root_dir = require('lspconfig.util').root_pattern("svelte.config.js", "svelte.config.mjs", "package.json"),
	settings = {
		svelte = {
			plugin = {
				html = {
					completions = {
						emmet = false,
					},
				},
				svelte = {
					compilerWarnings = {
						["a11y-click-events-have-key-events"] = "ignore",
					},
				},
			},
		},
	},
}

-- Python LSP
vim.lsp.config.pyright = {
	cmd = { 'pyright-langserver', '--stdio' },
	on_attach = on_attach,
	capabilities = capabilities,
	settings = {
		python = {
			analysis = {
				autoSearchPaths = true,
				useLibraryCodeForTypes = true,
				diagnosticMode = "workspace",
			},
		},
	},
}

-- ESLint LSP
local util = require("lspconfig.util")
vim.lsp.config.eslint = {
	cmd = { 'vscode-eslint-language-server', '--stdio' },
	on_attach = function(client, bufnr)
		-- Enable formatting and code actions
		client.server_capabilities.documentFormattingProvider = true
		on_attach(client, bufnr)

		-- Auto-fix on save
		vim.api.nvim_create_autocmd("BufWritePre", {
			buffer = bufnr,
			command = "EslintFixAll",
		})
	end,
	capabilities = capabilities,
	filetypes = { "javascript", "javascriptreact", "typescript", "typescriptreact", "vue", "svelte" },
	root_dir = util.root_pattern(
		".eslintrc",
		".eslintrc.js",
		".eslintrc.cjs",
		".eslintrc.yaml",
		".eslintrc.yml",
		".eslintrc.json",
		"eslint.config.js",
		"package.json"
	),
	settings = {
		codeAction = {
			disableRuleComment = {
				enable = true,
				location = "separateLine",
			},
			showDocumentation = {
				enable = true,
			},
		},
		codeActionOnSave = {
			enable = false,
			mode = "all",
		},
		format = true,
		nodePath = "",
		onIgnoredFiles = "off",
		packageManager = "npm",
		quiet = false,
		rulesCustomizations = {},
		run = "onType",
		useESLintClass = false,
		validate = "on",
		workingDirectory = {
			mode = "location",
		},
	},
}

-- Enhanced diagnostic configuration
vim.diagnostic.config({
	virtual_text = {
		enabled = true,
		source = "if_many",
		prefix = "●",
	},
	signs = true,
	underline = true,
	update_in_insert = false,
	severity_sort = true,
	float = {
		border = "rounded",
		source = "always",
		header = "",
		prefix = "",
	},
})

-- Define diagnostic signs
local signs = { Error = "󰅚 ", Warn = "󰀪 ", Hint = "󰌶 ", Info = " " }
for type, icon in pairs(signs) do
	local hl = "DiagnosticSign" .. type
	vim.fn.sign_define(hl, { text = icon, texthl = hl, numhl = hl })
end
