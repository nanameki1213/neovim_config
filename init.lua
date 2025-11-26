local lazypath = vim.fn.stdpath("data") .. "/lazy/lazy.nvim"
if not vim.loop.fs_stat(lazypath) then
	vim.fn.system({
		"git",
		"clone",
		"--filter=blob:none",
		"https://github.com/folke/lazy.nvim.git",
		"--branch=stable",
		lazypath,
	})
end
vim.opt.rtp:prepend(lazypath)

require('lazy').setup({
  spec = {
    { import = "plugins" },
    -- Rustのコード整形
    'rust-lang/rust.vim',
    -- LSP
    'mason-org/mason.nvim',
    'mason-org/mason-lspconfig.nvim',
    'neovim/nvim-lspconfig',
    'hrsh7th/nvim-cmp',
    'hrsh7th/cmp-nvim-lsp',
    'hrsh7th/vim-vsnip',
    'hrsh7th/cmp-buffer',
    'hrsh7th/cmp-path',
    'onsails/lspkind.nvim',
  }
})


require("options")
vim.cmd.colorscheme("catppuccin")

-- Reference: https://zenn.dev/botamotch/articles/21073d78bc68bf
-- 1. LSP Server management
require('mason').setup()
require('mason-lspconfig').setup({
	ensure_installed = { 'rust_analyzer', 'lua_ls' },
})

-- 2. build-in LSP function

local keymap = vim.keymap

-- keyboard shortcut
keymap.set('n', 'K', '<cmd>lua vim.lsp.buf.hover()<CR>')
keymap.set('n', 'gf', '<cmd>lua vim.lsp.buf.formatting()<CR>')
keymap.set('n', 'gr', '<cmd>lua vim.lsp.buf.references()<CR>')
keymap.set('n', '<F12>', '<cmd>lua vim.lsp.buf.definition()<CR>')
keymap.set('n', 'gD', '<cmd>lua vim.lsp.buf.declaration()<CR>')
keymap.set('n', 'gi', '<cmd>lua vim.lsp.buf.implementation()<CR>')
keymap.set('n', 'gt', '<cmd>lua vim.lsp.buf.type_definition()<CR>')
keymap.set('n', 'gn', '<cmd>lua vim.lsp.buf.rename()<CR>')
keymap.set('n', 'ga', '<cmd>lua vim.lsp.buf.code_action()<CR>')
keymap.set('n', 'ge', '<cmd>lua vim.diagnostic.open_float()<CR>')
keymap.set('n', 'g]', '<cmd>lua vim.diagnostic.goto_next()<CR>')
keymap.set('n', 'g[', '<cmd>lua vim.diagnostic.goto_prev()<CR>')

-- keybind
keymap.set('n', 'ss', ':split<Return><C-w>w')
keymap.set('n', 'sv', ':vsplit<Return><C-w>w')

keymap.set('n', 'sh', '<C-w>h')
keymap.set('n', 'sk', '<C-w>k')
keymap.set('n', 'sj', '<C-w>j')
keymap.set('n', 'sl', '<C-w>l')

-- 3. completion (hrsh7th/nvim-cmp)
local cmp = require('cmp')
cmp.setup({
	snippet = {
		expand = function(args)
			vim.fn['vsnip#anonymous'](args.body)
		end,
	},
	sources = {
		{ name = 'nvim_lsp' },
		{ name = 'buffer' },
		{ name = 'path' },
	},
	mapping = cmp.mapping.preset.insert({
		['<C-p>'] = cmp.mapping.select_prev_item(),
		['<C-n>'] = cmp.mapping.select_next_item(),
		['<C-l>'] = cmp.mapping.abort(),
		['<Tab>'] = cmp.mapping.confirm({ select = true }),
	}),
	experimental = {
		ghost_text = true,
	},
})
