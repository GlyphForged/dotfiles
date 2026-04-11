return {
  "nvim-treesitter/nvim-treesitter",
  opts = function(_, opts)
    opts.ensure_installed = opts.ensure_installed or {}

    local parsers = {
      "bash",
      "c",
      "cpp",
      "c_sharp",
      "css",
      "gdscript",
      "gdshader",
      "gitignore",
      "go",
      "gomod",
      "gosum",
      "html",
      "javascript",
      "json",
      "lua",
      "markdown",
      "markdown_inline",
      "python",
      "regex",
      "rust",
      "toml",
      "tsx",
      "typescript",
      "vim",
      "vimdoc",
      "xml",
      "yaml",
    }

    for _, parser in ipairs(parsers) do
      if not vim.tbl_contains(opts.ensure_installed, parser) then
        table.insert(opts.ensure_installed, parser)
      end
    end
  end,
}
