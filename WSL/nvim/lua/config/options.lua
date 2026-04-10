--------------------------------
-- Glyphforged LazyVim Config --
--------------------------------
-- Default docs:
-- Options are automatically loaded before lazy.nvim startup
-- Default options that are always set:
-- https://github.com/LazyVim/LazyVim/blob/main/lua/lazyvim/config/options.lua

local opt = vim.opt

opt.shiftwidth = 2 -- Size of an indent
opt.tabstop = 2 -- Tab width

----------------------
-- Markdown Options --
----------------------
vim.api.nvim_create_autocmd("FileType", {
  pattern = "markdown",
  callback = function()
    vim.opt_local.textwidth = 80
    vim.opt_local.colorcolumn = "80"
    vim.opt_local.formatoptions:append("tcq")
  end,
})
