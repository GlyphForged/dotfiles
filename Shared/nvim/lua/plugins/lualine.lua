local palette = require("glyphforged.palette")

local theme = {
  normal = {
    a = { fg = palette.ink, bg = palette.cyan, gui = "bold" },
    b = { fg = palette.pearl, bg = palette.panel },
    c = { fg = palette.pearl, bg = palette.night },
  },
  insert = {
    a = { fg = palette.ink, bg = palette.violet, gui = "bold" },
    b = { fg = palette.pearl, bg = palette.panel },
  },
  visual = {
    a = { fg = palette.ink, bg = palette.magenta, gui = "bold" },
    b = { fg = palette.pearl, bg = palette.panel },
  },
  replace = {
    a = { fg = palette.ink, bg = palette.red, gui = "bold" },
    b = { fg = palette.pearl, bg = palette.panel },
  },
  command = {
    a = { fg = palette.ink, bg = palette.warning, gui = "bold" },
    b = { fg = palette.pearl, bg = palette.panel },
  },
  inactive = {
    a = { fg = palette.blue, bg = palette.panel },
    b = { fg = palette.blue, bg = palette.panel },
    c = { fg = palette.blue, bg = palette.night },
  },
}

return {
  "nvim-lualine/lualine.nvim",
  opts = function(_, opts)
    opts.options = opts.options or {}
    opts.options.theme = theme
    opts.options.component_separators = { left = "│", right = "│" }
    opts.options.section_separators = { left = "", right = "" }
  end,
}
