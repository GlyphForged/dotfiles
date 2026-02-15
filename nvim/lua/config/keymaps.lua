-- Keymaps are automatically loaded on the VeryLazy event
-- Default keymaps that are always set: https://github.com/LazyVim/LazyVim/blob/main/lua/lazyvim/config/keymaps.lua

-- Exit insert mode with jj/jk/kk without taking forever
vim.keymap.set("i", "jj", "<Esc>", { desc = "Exit insert mode with jj" })
vim.keymap.set("i", "jk", "<Esc>", { desc = "Exit insert mode with jk" })
vim.keymap.set("i", "kk", "<Esc>", { desc = "Exit insert mode with kk" })
vim.opt.timeout = true
vim.opt.timeoutlen = 300

-- Change lines while in insert mode with Alt+j/k
vim.keymap.set("i", "<A-j>", "<Esc>:m .+1<CR>==gi")
vim.keymap.set("i", "<A-k>", "<Esc>:m .-2<CR>==gi")

-- Quick clear search highligh
vim.keymap.set("n", "<leader>h", ":nohlsearch<CR>")

-- Make current file executable
vim.keymap.set("n", "<leader>x", "<cmd>!chmod +x %<CR>", { silent = true })
