vim.g.mapleader = " "
vim.g.maplocalleader = " "

local lazypath = vim.fn.stdpath("data") .. "/lazy/lazy.nvim"
if not vim.uv.fs_stat(lazypath) then
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

require("lazy").setup({
	spec = {
		-- LSP・補完・telescope は lua/plugins/lsp.lua
		{ import = "plugins" },
		-- Rustのコード整形
		"rust-lang/rust.vim",
	},
	-- Dockerイメージは使い捨てなので更新チェックはしない
	checker = { enabled = false },
	change_detection = { enabled = false },
})

require("options")
vim.cmd.colorscheme("catppuccin")

-- keybind
local keymap = vim.keymap
keymap.set("n", "ss", ":split<Return><C-w>w")
keymap.set("n", "sv", ":vsplit<Return><C-w>w")

keymap.set("n", "sh", "<C-w>h")
keymap.set("n", "sk", "<C-w>k")
keymap.set("n", "sj", "<C-w>j")
keymap.set("n", "sl", "<C-w>l")
