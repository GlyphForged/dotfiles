return {
  {
    "mason-org/mason.nvim",
    opts = function(_, opts)
      opts.registries = opts.registries or {
        "github:mason-org/mason-registry",
      }

      local crashdummy_registry = "github:Crashdummyy/mason-registry"
      local has_registry = false

      for _, registry in ipairs(opts.registries) do
        if registry == crashdummy_registry then
          has_registry = true
        end
      end

      if not has_registry then
        table.insert(opts.registries, crashdummy_registry)
      end

      opts.ensure_installed = opts.ensure_installed or {}

      local tools = {
        "clangd",
        "clang-format",
        "css-lsp",
        "emmet-language-server",
        "gofumpt",
        "goimports",
        "gopls",
        "html-lsp",
        "json-lsp",
        "lua-language-server",
        "prettierd",
        "pyright",
        "roslyn",
        "ruff",
        "rust-analyzer",
        "typescript-language-server",
      }

      for _, tool in ipairs(tools) do
        if not vim.tbl_contains(opts.ensure_installed, tool) then
          table.insert(opts.ensure_installed, tool)
        end
      end
    end,
  },
}
