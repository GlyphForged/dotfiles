vim.api.nvim_create_autocmd("FileType", {
  pattern = { "c", "cpp", "cs", "gdscript", "gdshader", "go", "html", "json", "lua", "python", "rust", "typescript" },
  callback = function()
    vim.opt_local.colorcolumn = "100"
  end,
})
