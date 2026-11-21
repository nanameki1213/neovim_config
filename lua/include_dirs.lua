-- プロジェクト配下のヘッダーを探して clangd の fallbackFlags (-I...) を作る
-- clangd は compile_commands.json 等が無いときだけ fallbackFlags を使うので、
-- ちゃんとしたビルド設定があるプロジェクトの邪魔はしない
local M = {}

local MAX_DIRS = 1000

function M.flags(root)
	root = root or vim.uv.cwd()
	-- rg は .gitignore を尊重するので build/ や third_party の生成物はある程度除外される
	local res = vim.system({
		"rg", "--files", "--no-messages",
		"-g", "*.{h,hh,hpp,hxx,h++,inl,ipp,tpp}",
		"-g", "!{.git,node_modules,target,.cache}/",
		root,
	}, { text = true }):wait()
	if res.code ~= 0 and (res.stdout or "") == "" then
		return { "-I" .. root }
	end

	local seen, dirs = {}, {}
	local function add(d)
		if not seen[d] and #dirs < MAX_DIRS then
			seen[d] = true
			table.insert(dirs, d)
		end
	end
	add(root)
	for file in vim.gsplit(res.stdout, "\n", { trimempty = true }) do
		-- ヘッダーのあるディレクトリから root までの全ての親を追加
		-- (include/mylib/foo.hpp を "mylib/foo.hpp" でも "foo.hpp" でも引けるように)
		local d = vim.fs.dirname(file)
		while d and #d > #root and not seen[d] do
			add(d)
			d = vim.fs.dirname(d)
		end
	end

	return vim.tbl_map(function(d)
		return "-I" .. d
	end, dirs)
end

return M
