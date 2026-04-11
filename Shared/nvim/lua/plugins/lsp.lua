return {
  {
    "neovim/nvim-lspconfig",
    opts = function(_, opts)
      opts.servers = opts.servers or {}

      opts.servers.html = {}
      opts.servers.cssls = {}
      opts.servers.emmet_language_server = {
        filetypes = {
          "css",
          "eruby",
          "html",
          "htmldjango",
          "javascriptreact",
          "less",
          "pug",
          "sass",
          "scss",
          "templ",
          "typescriptreact",
        },
      }
      opts.servers.pyright = {
        settings = {
          python = {
            analysis = {
              autoSearchPaths = true,
              diagnosticMode = "workspace",
              useLibraryCodeForTypes = true,
            },
          },
        },
      }
      opts.servers.ruff = {}
      opts.servers.tsserver = false
      opts.servers.vtsls = {
        settings = {
          typescript = {
            preferences = {
              includePackageJsonAutoImports = "on",
            },
          },
        },
      }
      opts.servers.clangd = {
        cmd = {
          "clangd",
          "--background-index",
          "--clang-tidy",
          "--completion-style=detailed",
          "--fallback-style=llvm",
        },
      }
      local gdscript_server = {
        filetypes = { "gd", "gdscript", "gdshader" },
      }

      if vim.g.glyphforged_environment == "wsl" and vim.fn.executable("godot-wsl-lsp") == 1 then
        gdscript_server.cmd = { "godot-wsl-lsp" }
      end

      opts.servers.gdscript = gdscript_server
    end,
  },
  {
    "seblyng/roslyn.nvim",
    ft = "cs",
    dependencies = {
      "mason-org/mason.nvim",
    },
    opts = {
      filewatching = "auto",
      broad_search = true,
      silent = false,
    },
  },
}
