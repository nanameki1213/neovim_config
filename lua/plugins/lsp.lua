-- LSP / 補完 / ファジーファインダー
-- VSCode風キーマップ:
--   F12 / gd    定義へジャンプ        Shift+F12 / gr  参照一覧
--   gi          実装へジャンプ        gt              型定義へジャンプ
--   gD          宣言へジャンプ        K               ホバー
--   F2 / gn     リネーム              ga              コードアクション
--   gf          フォーマット          ge              診断をフロート表示
--   g] / g[     次/前の診断           Alt+Left/Right  ジャンプ履歴を戻る/進む
--   Ctrl+p      ファイル検索          <Space>g        grep (live grep)
--   <Space>o    ファイル内シンボル    <Space>s        ワークスペースシンボル
--   <Space>d    診断一覧              <Space>b        バッファ一覧
--   <Space>h    インレイヒント切替    (挿入モード) Ctrl+Space 補完 / Ctrl+k シグネチャ

local servers = require("lsp_servers")

local function setup_keymaps()
	local map = vim.keymap.set
	local tb = function(name, opts)
		return function()
			require("telescope.builtin")[name](opts)
		end
	end

	-- nvim 0.11+ の既定 gr* マップがあると gr が待たされるので消す
	for _, lhs in ipairs({ "grr", "gra", "grn", "gri", "grt", "grx" }) do
		pcall(vim.keymap.del, { "n", "x" }, lhs)
	end

	map("n", "<F12>", tb("lsp_definitions"), { desc = "定義へジャンプ" })
	map("n", "gd", tb("lsp_definitions"), { desc = "定義へジャンプ" })
	map("n", "<S-F12>", tb("lsp_references", { include_declaration = false }), { desc = "参照一覧" })
	map("n", "<F24>", tb("lsp_references", { include_declaration = false }), { desc = "参照一覧" }) -- 端末によっては Shift+F12 が F24 になる
	map("n", "gr", tb("lsp_references", { include_declaration = false }), { desc = "参照一覧" })
	map("n", "gi", tb("lsp_implementations"), { desc = "実装へジャンプ" })
	map("n", "gt", tb("lsp_type_definitions"), { desc = "型定義へジャンプ" })
	map("n", "gD", vim.lsp.buf.declaration, { desc = "宣言へジャンプ" })
	map("n", "K", function()
		vim.lsp.buf.hover()
	end, { desc = "ホバー" })
	map("n", "<F2>", vim.lsp.buf.rename, { desc = "リネーム" })
	map("n", "gn", vim.lsp.buf.rename, { desc = "リネーム" })
	map({ "n", "x" }, "ga", vim.lsp.buf.code_action, { desc = "コードアクション" })
	map({ "n", "x" }, "gf", function()
		vim.lsp.buf.format({ async = true })
	end, { desc = "フォーマット" })
	map("i", "<C-k>", vim.lsp.buf.signature_help, { desc = "シグネチャヘルプ" })

	map("n", "ge", vim.diagnostic.open_float, { desc = "診断を表示" })
	map("n", "g]", function()
		vim.diagnostic.jump({ count = 1, float = true })
	end, { desc = "次の診断" })
	map("n", "g[", function()
		vim.diagnostic.jump({ count = -1, float = true })
	end, { desc = "前の診断" })

	map("n", "<M-Left>", "<C-o>", { desc = "戻る" })
	map("n", "<M-Right>", "<C-i>", { desc = "進む" })

	map("n", "<C-p>", tb("find_files", { hidden = true }), { desc = "ファイル検索" })
	map("n", "<leader>f", tb("find_files", { hidden = true }), { desc = "ファイル検索" })
	map("n", "<leader>g", tb("live_grep"), { desc = "grep" })
	map("n", "<leader>o", tb("lsp_document_symbols"), { desc = "ファイル内シンボル" })
	map("n", "<leader>s", tb("lsp_dynamic_workspace_symbols"), { desc = "ワークスペースシンボル" })
	map("n", "<leader>d", tb("diagnostics"), { desc = "診断一覧" })
	map("n", "<leader>b", tb("buffers"), { desc = "バッファ一覧" })
	map("n", "<leader>h", function()
		vim.lsp.inlay_hint.enable(not vim.lsp.inlay_hint.is_enabled())
	end, { desc = "インレイヒント切替" })
end

return {
	{
		"neovim/nvim-lspconfig",
		dependencies = {
			"mason-org/mason.nvim",
			"mason-org/mason-lspconfig.nvim",
			"hrsh7th/cmp-nvim-lsp",
		},
		config = function()
			require("mason").setup()
			require("mason-lspconfig").setup({
				-- イメージに焼き込み済みのはずだが、足りなければ起動時に入れる
				ensure_installed = servers,
				automatic_enable = servers,
			})

			-- :MasonInstallAll  lsp_servers.lua のサーバーを全部入れる(headlessでは完了まで待つ)
			vim.api.nvim_create_user_command("MasonInstallAll", function()
				local map = require("mason-lspconfig").get_mappings().lspconfig_to_package
				local pkgs = vim.tbl_map(function(s)
					return map[s] or s
				end, servers)
				-- npm の警告がエラー扱いで飛んでくることがあるので握りつぶし、成否は下で確認する
				pcall(vim.cmd, "MasonInstall " .. table.concat(pkgs, " "))
				if #vim.api.nvim_list_uis() == 0 then
					local registry = require("mason-registry")
					local missing = vim.tbl_filter(function(p)
						return not registry.is_installed(p)
					end, pkgs)
					if #missing > 0 then
						io.stderr:write("MasonInstallAll: failed: " .. table.concat(missing, ", ") .. "\n")
						vim.cmd("cquit 1")
					end
				end
			end, {})

			vim.lsp.config("*", {
				capabilities = require("cmp_nvim_lsp").default_capabilities(),
			})
			vim.lsp.config("lua_ls", {
				settings = {
					Lua = {
						runtime = { version = "LuaJIT" },
						diagnostics = { globals = { "vim" } },
						workspace = { library = vim.api.nvim_get_runtime_file("", true), checkThirdParty = false },
					},
				},
			})
			vim.lsp.config("clangd", {
				cmd = { "clangd", "--background-index", "--clang-tidy", "--header-insertion=never" },
			})
			vim.lsp.config("rust_analyzer", {
				settings = { ["rust-analyzer"] = { check = { command = "clippy" } } },
			})

			vim.diagnostic.config({
				virtual_text = { spacing = 2, prefix = "●" },
				severity_sort = true,
				float = { source = true },
			})

			vim.api.nvim_create_autocmd("LspAttach", {
				callback = function(ev)
					local client = vim.lsp.get_client_by_id(ev.data.client_id)
					if client and client:supports_method("textDocument/inlayHint") then
						vim.lsp.inlay_hint.enable(true, { bufnr = ev.buf })
					end
				end,
			})

			setup_keymaps()
		end,
	},

	{
		"nvim-telescope/telescope.nvim",
		dependencies = {
			"nvim-lua/plenary.nvim",
			{ "nvim-telescope/telescope-fzf-native.nvim", build = "make" },
		},
		cmd = "Telescope",
		config = function()
			local telescope = require("telescope")
			telescope.setup({
				defaults = {
					path_display = { "truncate" },
					file_ignore_patterns = { "^.git/", "node_modules/", "target/" },
				},
			})
			pcall(telescope.load_extension, "fzf")
		end,
	},

	{
		"hrsh7th/nvim-cmp",
		event = "InsertEnter",
		dependencies = {
			"hrsh7th/cmp-nvim-lsp",
			"hrsh7th/cmp-nvim-lsp-signature-help",
			"hrsh7th/cmp-buffer",
			"hrsh7th/cmp-path",
			"hrsh7th/vim-vsnip",
			"hrsh7th/cmp-vsnip",
			"onsails/lspkind.nvim",
		},
		config = function()
			local cmp = require("cmp")
			cmp.setup({
				snippet = {
					expand = function(args)
						vim.fn["vsnip#anonymous"](args.body)
					end,
				},
				sources = cmp.config.sources({
					{ name = "nvim_lsp" },
					{ name = "nvim_lsp_signature_help" },
					{ name = "vsnip" },
					{ name = "path" },
				}, {
					{ name = "buffer" },
				}),
				mapping = cmp.mapping.preset.insert({
					["<C-p>"] = cmp.mapping.select_prev_item(),
					["<C-n>"] = cmp.mapping.select_next_item(),
					["<C-l>"] = cmp.mapping.abort(),
					["<C-Space>"] = cmp.mapping.complete(),
					["<Tab>"] = cmp.mapping.confirm({ select = true }),
				}),
				formatting = {
					format = require("lspkind").cmp_format({ mode = "symbol_text", maxwidth = 50 }),
				},
				window = {
					completion = cmp.config.window.bordered(),
					documentation = cmp.config.window.bordered(),
				},
				experimental = {
					ghost_text = true,
				},
			})
		end,
	},
}
