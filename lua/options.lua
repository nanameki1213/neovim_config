-- reference: https://zenn.dev/hisasann/articles/neovim-settings-to-lua
local options = {
	encoding = 'utf-8',
	fileencoding = 'utf-8',
	title = true, -- なぞ
	clipboard = 'unnamedplus', -- ヤンクをクリップボードに保存
	cmdheight = 0, -- コマンドライン領域を非表示にする
	-- completeopt = { "menuone", "noselect" }, -- vimの標準の補完機能の設定
	-- conceallevel = 0, -- わからん
	-- 検索に関する設定
	hlsearch = true, -- 検索時のハイライトを有効にする
	ignorecase = true, -- 検索時に大文字/小文字を区別しない
	mouse = 'a', -- マウス操作を有効化
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
	signcolumn = 'yes',
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

vim.opt.shortmess:append('c')

if vim.fn.has('wsl') == 1 and vim.fn.executable('win32yank') == 1 then
	vim.g.clipboard = {
		name = 'win32yank',
		copy = {
			['+'] = 'win32yank -i --crlf',
			['*'] = 'win32yank -i --crlf',
		},
		paste = {
			['+'] = 'win32yank -o --lf',
			['*'] = 'win32yank -o --lf',
		},
		cache_enabled = true,
	}
else
	-- OSC 52: 端末エスケープでクリップボードに書き込む。
	-- docker / ssh / tmux を貫通して手元の端末 (Windows Terminal 等) のクリップボードに届く。
	-- tmux 側は `set -g set-clipboard on` が必要。
	-- 端末からの読み取り (OSC 52 paste) は Windows Terminal が非対応で固まるので、
	-- p は最後にヤンクした内容を使い、Windows側からの貼り付けは端末の Ctrl+V で行う。
	local osc52 = require('vim.ui.clipboard.osc52')
	local cache = {}
	local function copy(reg)
		local send = osc52.copy(reg)
		return function(lines, regtype)
			cache[reg] = { lines, regtype }
			send(lines)
		end
	end
	local function paste(reg)
		return function()
			return cache[reg] or { {}, 'v' }
		end
	end
	vim.g.clipboard = {
		name = 'OSC 52',
		copy = { ['+'] = copy('+'), ['*'] = copy('*') },
		paste = { ['+'] = paste('+'), ['*'] = paste('*') },
	}
end

for k, v in pairs(options) do
	vim.opt[k] = v
end

vim.cmd('set whichwrap+=<,>,[,],h,l')
vim.cmd('set modifiable')
vim.cmd([[set iskeyword+=-]])
vim.cmd([[set formatoptions-=cro]])
