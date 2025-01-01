-- reference: https://zenn.dev/hisasann/articles/neovim-settings-to-lua
local options = {
	encoding = "utf-8",
	fileencoding = "utf-8",
	title = true, -- なぞ
	clipboard = "unnamedplus", -- ヤンクをクリップボードに保存
	cmdheight = 0, -- コマンドライン領域を非表示にする
	-- completeopt = { "menuone", "noselect" }, -- vimの標準の補完機能の設定
	-- conceallevel = 0, -- わからん
	-- 検索に関する設定
	hlsearch = true, -- 検索時のハイライトを有効にする
	ignorecase = true, -- 検索時に大文字/小文字を区別しない
    mouse = "a", -- マウス操作を有効化
    -- pumheight = 10, -- 補完メニュー(?)の高さ
    showmode = true, -- 現在のモードを最下部に表示する
    showtabline = 2,
    smartcase = true,
    smartindent = true,
    -- swapfile = false, -- スワップファイルを作成しないようにする
    -- timeoutlen = 300,
    -- updatetime = 300,
    -- writebackup = false,
    -- backupskip = { "/tmp/*", "/provate/tmp" },
    expandtab = true,
    shiftwidth = 2,
    tabstop = 2,
    cursorline = true,
    number = true,
    -- relativenumber = true, -- 行表示を相対的にする
    numberwidth = 4,
    signcolumn = "yes",
    wrap = false,
    -- 背景透過
    termguicolors = false, 
    winblend = 30,
	pumblend = 30,

	-- background = "dark",
	-- scrolloff = 8,
	-- sidescrolloff = 8,
	-- guifont = "monospace:h17",
	-- splitbelow = false,
	-- splitright = false,
}

vim.opt.shortmess:append("c")
vim.opt.clipboard = 'unnamedplus' -- システムクリップボードを使用

for k, v in pairs(options) do
	vim.opt[k] = v
end

vim.cmd("set whichwrap+=<,>,[,],h,l")
vim.cmd("set modifiable")
vim.cmd([[set iskeyword+=-]])
vim.cmd([[set formatoptions-=cro]])

