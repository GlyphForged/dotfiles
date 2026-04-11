return {
  {
    "habamax/vim-godot",
    ft = { "gd", "gdscript", "gdshader" },
  },
  {
    "L3MON4D3/LuaSnip",
    optional = true,
    config = function(_, opts)
      require("luasnip").config.setup(opts or {})

      local ls = require("luasnip")
      local snippet = ls.snippet
      local text = ls.text_node
      local insert = ls.insert_node

      ls.add_snippets("html", {
        snippet("hx-get", {
          text('hx-get="'),
          insert(1, "/endpoint"),
          text('" hx-target="'),
          insert(2, "#target"),
          text('" hx-swap="innerHTML"'),
        }),
        snippet("hx-post", {
          text('hx-post="'),
          insert(1, "/endpoint"),
          text('" hx-target="'),
          insert(2, "#target"),
          text('" hx-swap="outerHTML"'),
        }),
        snippet("hx-trigger", {
          text('hx-trigger="'),
          insert(1, "click"),
          text('"'),
        }),
      })
    end,
  },
}
