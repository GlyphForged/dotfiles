vim.g.glyphforged_environment = "wsl"

vim.g.clipboard = {
  name = "Windows Clipboard (WSL)",
  copy = {
    ["+"] = { "clip.exe" },
    ["*"] = { "clip.exe" },
  },
  paste = {
    ["+"] = { "pwsh.exe", "-NoProfile", "-Command", "Get-Clipboard -Raw" },
    ["*"] = { "pwsh.exe", "-NoProfile", "-Command", "Get-Clipboard -Raw" },
  },
  cache_enabled = 0,
}

local function enable_windows_clipboard()
  vim.opt.clipboard = "unnamedplus"
end
enable_windows_clipboard()

vim.api.nvim_create_autocmd("User", {
  group = vim.api.nvim_create_augroup("GlyphforgedWslClipboard", { clear = true }),
  pattern = "VeryLazy",
  once = true,
  callback = enable_windows_clipboard,
})
