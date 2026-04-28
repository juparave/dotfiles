require("lsp-format").setup({})
local lspconfig = require("lspconfig")
local util = require("lspconfig.util")

vim.api.nvim_create_autocmd("LspAttach", {
	callback = function(args)
		local client = assert(vim.lsp.get_client_by_id(args.data.client_id))
		require("lsp-format").on_attach(client, args.buf)

		-- Disable semantic tokens for certain clients to avoid conflicts
		if client.name == "ts_ls" or client.name == "tsserver" or client.name == "angularls" then
			client.server_capabilities.semanticTokensProvider = nil
		end

		-- Enable format on save for most servers
		if client:supports_method("textDocument/formatting") then
			vim.api.nvim_create_autocmd("BufWritePre", {
				buffer = args.buf,
				callback = function()
					vim.lsp.buf.format({ async = false, timeout_ms = 2000 })
				end,
			})
		end

		-- Set up keymaps
		local opts = { buffer = args.buf, remap = false }
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
	end,
})

-- Enhanced capabilities with additional features
local capabilities = require("cmp_nvim_lsp").default_capabilities()
capabilities.textDocument.completion.completionItem.snippetSupport = true
capabilities.textDocument.foldingRange = {
	dynamicRegistration = false,
	lineFoldingOnly = true,
}

-- Set up mason for package management only
require("mason").setup()

require("mason-lspconfig").setup({
	ensure_installed = { "lua_ls", "gopls", "pyright", "angularls", "ts_ls", "eslint", "svelte" },
	automatic_installation = false,
})

-- Configure LSP servers using the correct vim.lsp.config() API

-- Lua LSP
vim.lsp.config("lua_ls", {
	cmd = { "lua-language-server" },
	capabilities = capabilities,
	settings = {
		Lua = {
			runtime = { version = "LuaJIT" },
			diagnostics = { globals = { "vim" } },
			workspace = {
				library = vim.api.nvim_get_runtime_file("", true),
				checkThirdParty = false,
			},
			telemetry = { enable = false },
		},
	},
})

-- Go LSP
vim.lsp.config("gopls", {
	cmd = { "gopls" },
	capabilities = capabilities,
})

-- TypeScript LSP
vim.lsp.config("ts_ls", {
	cmd = { "typescript-language-server", "--stdio" },
	capabilities = capabilities,
	filetypes = { "typescript", "typescriptreact", "javascript", "javascriptreact" },
	root_markers = { "package.json", "tsconfig.json", "jsconfig.json" },
	settings = {
		typescript = {
			preferences = { includePackageJsonAutoImports = "on" },
		},
	},
})

-- Angular LSP (using FileType autocmd for proper dynamic configuration)
-- Helper to find project's node_modules directory
local function get_probe_dir(root_dir)
	if not root_dir or root_dir == "" then
		return nil
	end
	local node_modules = vim.fs.find("node_modules", { path = root_dir, upward = true })[1]
	if node_modules then
		return vim.fs.dirname(node_modules) .. "/node_modules"
	end
	return nil
end

-- Helper to get Angular core version from package.json
local function get_angular_core_version(root_dir)
	if not root_dir or root_dir == "" then
		return nil
	end
	local node_modules = vim.fs.find("node_modules", { path = root_dir, upward = true })[1]
	if not node_modules then
		return nil
	end
	local project_root = vim.fs.dirname(node_modules)

	local package_json = project_root .. "/package.json"
	if not vim.uv.fs_stat(package_json) then
		return nil
	end

	local f = io.open(package_json)
	if not f then
		return nil
	end
	local contents = f:read("*a")
	f:close()

	local ok, json = pcall(vim.json.decode, contents)
	if not ok or not json.dependencies then
		return nil
	end

	local angular_core_version = json.dependencies["@angular/core"]
	angular_core_version = angular_core_version and angular_core_version:match("%d+%.%d+%.%d+")
	return angular_core_version
end

-- Start Angular LSP manually for Angular project files
vim.api.nvim_create_autocmd("FileType", {
	pattern = { "typescript", "html", "typescriptreact", "htmlangular" },
	callback = function(args)
		local bufname = vim.api.nvim_buf_get_name(args.buf)
		if bufname == "" then
			return
		end

		-- Check if this is an Angular project
		local angular_json = vim.fs.find("angular.json", { path = vim.fs.dirname(bufname), upward = true })[1]
		if not angular_json then
			return -- Not an Angular project
		end

		local root_dir = vim.fs.dirname(angular_json)
		local project_probe = get_probe_dir(root_dir)
		if not project_probe then
			return -- No node_modules
		end

		local angular_version = get_angular_core_version(root_dir)
		local cmd = {
			"ngserver",
			"--stdio",
			"--tsProbeLocations",
			project_probe,
			"--ngProbeLocations",
			project_probe,
		}

		if angular_version then
			table.insert(cmd, "--angularCoreVersion")
			table.insert(cmd, angular_version)
		end

		vim.lsp.start({
			name = "angularls",
			cmd = cmd,
			root_dir = root_dir,
			capabilities = capabilities,
		})
	end,
})

-- Svelte LSP
vim.lsp.config("svelte", {
	cmd = { "svelteserver", "--stdio" },
	capabilities = capabilities,
	filetypes = { "svelte" },
	root_markers = { "svelte.config.js", "svelte.config.mjs", "package.json" },
	settings = {
		svelte = {
			plugin = {
				html = { completions = { emmet = false } },
				svelte = { compilerWarnings = { ["a11y-click-events-have-key-events"] = "ignore" } },
			},
		},
	},
})

-- Python LSP
vim.lsp.config("pyright", {
	cmd = { "pyright-langserver", "--stdio" },
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
})

-- ESLint LSP
vim.lsp.config("eslint", {
	cmd = { "vscode-eslint-language-server", "--stdio" },
	capabilities = capabilities,
	filetypes = { "javascript", "javascriptreact", "typescript", "typescriptreact", "vue", "svelte" },
	root_markers = {
		".eslintrc",
		".eslintrc.js",
		".eslintrc.cjs",
		".eslintrc.yaml",
		".eslintrc.yml",
		".eslintrc.json",
		"eslint.config.js",
		"package.json",
	},
	settings = {
		codeAction = {
			disableRuleComment = { enable = true, location = "separateLine" },
			showDocumentation = { enable = true },
		},
		codeActionOnSave = { enable = false, mode = "all" },
		format = true,
		nodePath = "",
		onIgnoredFiles = "off",
		packageManager = "npm",
		quiet = false,
		rulesCustomizations = {},
		run = "onType",
		useESLintClass = false,
		validate = "on",
		workingDirectory = { mode = "location" },
	},
})

-- Enhanced diagnostic configuration
vim.diagnostic.config({
	virtual_text = { enabled = true, source = "if_many", prefix = "●" },
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

-- Enable LSP servers
vim.lsp.enable("lua_ls")
vim.lsp.enable("gopls")
vim.lsp.enable("ts_ls")
-- Note: angularls is started via FileType autocmd above
vim.lsp.enable("svelte")
vim.lsp.enable("pyright")
vim.lsp.enable("eslint")
