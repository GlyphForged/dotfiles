return {
  "saghen/blink.cmp",
  opts = function(_, opts)
    local keymap = opts.keymap or {}

    -- Use Ctrl-j/k to navigate autocomplete
    -- Ctrl-j
    keymap["<C-j>"] = {
      function(cmp)
        if cmp.is_visible() then
          cmp.select_next()
        end
      end,
    }

    -- Ctrl-k
    keymap["<C-k>"] = {
      function(cmp)
        if cmp.is_visible() then
          cmp.select_prev()
        end
      end,
    }

    opts.keymap = keymap
  end,
}
