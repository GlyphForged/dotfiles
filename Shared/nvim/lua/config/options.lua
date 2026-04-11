--------------------------------
-- Glyphforged LazyVim Config --
--------------------------------

local opt = vim.opt

opt.shiftwidth = 2
opt.tabstop = 2
opt.termguicolors = true
opt.cursorline = true
opt.scrolloff = 6
opt.sidescrolloff = 8
opt.splitbelow = true
opt.splitright = true
opt.wrap = false
opt.colorcolumn = "100"

vim.g.autoformat = true

vim.api.nvim_create_autocmd("FileType", {
  pattern = "markdown",
  callback = function()
    vim.opt_local.textwidth = 80
    vim.opt_local.colorcolumn = "80"
    vim.opt_local.formatoptions:append("tcq")
  end,
})
