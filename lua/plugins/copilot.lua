return {
  "zbirenbaum/copilot.lua",
  lazy = false,
  priority = 1000,
  config = function()
    require("copilot").setup {
      suggestion = { enabled = false },
      panel = { enabled = false },
      server_opts_overrides = {
        trace = "verbose",
        cmd = {
          vim.fn.expand("~/.config/nvim/copilot/bin/copilot-language-server"),
          "--stdio"
        },
        settings = {
          advanced = {
            listCount = 10,
            inlineSuggestCount = 3,
          },
        },
      },
    }
  end,
}
