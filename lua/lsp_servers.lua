-- 使う言語サーバー(nvim-lspconfig の名前)
-- ここに追加すると、Dockerビルド時の :MasonInstallAll でイメージに焼き込まれる
return {
	"clangd", -- C / C++
	"pyright", -- Python
	"rust_analyzer", -- Rust
	"lua_ls", -- Lua
	"ts_ls", -- TypeScript / JavaScript
	"bashls", -- Bash
	"jsonls", -- JSON
	"yamlls", -- YAML
	"dockerls", -- Dockerfile
}
