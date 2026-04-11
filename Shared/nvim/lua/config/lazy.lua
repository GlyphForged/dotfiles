local lazypath = vim.fn.stdpath("data") .. "/lazy/lazy.nvim"

if not vim.loop.fs_stat(lazypath) then
  local lazy_repository = "https://github.com/folke/lazy.nvim.git"
  local clone_command = {
    "git",
    "clone",
    "--filter=blob:none",
    "--branch=stable",
    lazy_repository,
    lazypath,
  }

  vim.fn.system(clone_command)

  if vim.v.shell_error ~= 0 then
    error("Failed to clone lazy.nvim from " .. lazy_repository)
  end
end

vim.opt.rtp:prepend(lazypath)

require("lazy").setup({
  spec = {
    { "LazyVim/LazyVim", import = "lazyvim.plugins" },
    { import = "lazyvim.plugins.extras.lang.clangd" },
    { import = "lazyvim.plugins.extras.lang.go" },
    { import = "lazyvim.plugins.extras.lang.python" },
    { import = "lazyvim.plugins.extras.lang.rust" },
    { import = "lazyvim.plugins.extras.lang.typescript" },
    { import = "lazyvim.plugins.extras.lang.json" },
    { import = "lazyvim.plugins.extras.ui.treesitter-context" },
    { import = "lazyvim.plugins.extras.editor.inc-rename" },
    { import = "plugins" },
  },
  defaults = {
    lazy = false,
    version = false,
  },
  install = {
    colorscheme = { "nightfox", "habamax" },
  },
  checker = { enabled = true },
  change_detection = {
    notify = false,
  },
})
