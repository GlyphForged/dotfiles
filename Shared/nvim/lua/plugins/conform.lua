return {
  "stevearc/conform.nvim",
  opts = function(_, opts)
    opts.formatters_by_ft = opts.formatters_by_ft or {}

    opts.formatters_by_ft.c = { "clang_format" }
    opts.formatters_by_ft.cpp = { "clang_format" }
    opts.formatters_by_ft.css = { "prettierd" }
    opts.formatters_by_ft.gdscript = {}
    opts.formatters_by_ft.go = { "goimports", "gofumpt" }
    opts.formatters_by_ft.html = { "prettierd" }
    opts.formatters_by_ft.javascript = { "prettierd" }
    opts.formatters_by_ft.javascriptreact = { "prettierd" }
    opts.formatters_by_ft.json = { "prettierd" }
    opts.formatters_by_ft.jsonc = { "prettierd" }
    opts.formatters_by_ft.python = { "ruff_format" }
    opts.formatters_by_ft.rust = { "rustfmt" }
    opts.formatters_by_ft.typescript = { "prettierd" }
    opts.formatters_by_ft.typescriptreact = { "prettierd" }

    opts.default_format_opts = {
      lsp_format = "fallback",
    }
  end,
}
