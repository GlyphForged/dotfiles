local palette = require("glyphforged.palette")

return {
  "saghen/blink.cmp",
  opts = function(_, opts)
    local keymap = opts.keymap or {}

    keymap["<C-j>"] = {
      function(cmp)
        if cmp.is_visible() then
          cmp.select_next()
        end
      end,
    }

    keymap["<C-k>"] = {
      function(cmp)
        if cmp.is_visible() then
          cmp.select_prev()
        end
      end,
    }

    opts.keymap = keymap
    opts.completion = opts.completion or {}
    opts.completion.menu = opts.completion.menu or {}
    opts.completion.menu.border = "rounded"
    opts.completion.documentation = opts.completion.documentation or {}
    opts.completion.documentation.window = opts.completion.documentation.window or {}
    opts.completion.documentation.window.border = "rounded"

    vim.api.nvim_set_hl(0, "BlinkCmpGhostText", { fg = palette.blue, italic = true })
  end,
}
