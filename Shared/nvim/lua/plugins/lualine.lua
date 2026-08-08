local palette = require("glyphforged.palette")

local mode_labels = {
  n = "ノーマル", -- ノ(no)ー(o)マ(ma)ル(ru) = "normal"
  no = "ノーマル", -- ノ(no)ー(o)マ(ma)ル(ru) = "normal (operator pending)"
  i = "インサート", -- イ(i)ン(n)サ(sa)ー(a)ト(to) = "insert"
  ic = "インサート", -- イ(i)ン(n)サ(sa)ー(a)ト(to) = "insert completion"
  v = "ビジュアル", -- ビ(bi)ジュ(ju)ア(a)ル(ru) = "visual"
  V = "ビジュアル", -- ビ(bi)ジュ(ju)ア(a)ル(ru) = "visual line"
  ["\22"] = "ビジュアル", -- ビ(bi)ジュ(ju)ア(a)ル(ru) = "visual block"
  R = "リプレース", -- リ(ri)プ(pu)レ(re)ー(e)ス(su) = "replace"
  c = "コマンド", -- コ(ko)マ(ma)ン(n)ド(do) = "command"
  t = "ターミナル", -- タ(ta)ー(a)ミ(mi)ナ(na)ル(ru) = "terminal"
}

local status_labels = {
  git = "ギット", -- ギ(gi)ッ(t)ト(to) = "git"
  file = "ファイル", -- ファ(fa)イ(i)ル(ru) = "file"
  progress = "パーセント", -- パ(pa)ー(a)セ(se)ン(n)ト(to) = "progress"
  position = "ライン", -- ラ(ra)イ(i)ン(n) = "line and column"
}

local function mode_label()
  return mode_labels[vim.fn.mode(1)] or "モード" -- モ(mo)ー(o)ド(do) = "mode"
end

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
    opts.sections = {
      lualine_a = { mode_label },
      lualine_b = {
        { "branch", icon = status_labels.git },
        "diff",
        "diagnostics",
      },
      lualine_c = {
        {
          function()
            return status_labels.file
          end,
          color = { fg = palette.cyan, gui = "bold" },
        },
        { "filename", path = 1, symbols = { modified = " ●", readonly = " 󰌾", unnamed = " ノーネーム" } }, -- ノ(no)ー(o)ネ(ne)ー(e)ム(mu) = "no name"
      },
      lualine_x = { "filetype", "encoding" },
      lualine_y = {
        {
          "progress",
          fmt = function(progress)
            return status_labels.progress .. " " .. progress
          end,
        },
      },
      lualine_z = {
        {
          "location",
          fmt = function(location)
            return status_labels.position .. " " .. location
          end,
        },
      },
    }
  end,
}
