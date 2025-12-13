---@type LazySpec
return {
  {
    "nvimtools/none-ls.nvim",
    dependencies = { "nvim-lua/plenary.nvim", "mason.nvim" },
    event = { "BufReadPre", "BufNewFile" },
    config = function()
      local none_ls = require("null-ls")
      local conditions = require("utils.conditions")
      local builtins = require("null-ls.builtins")

      none_ls.setup({
        sources = {
          builtins.formatting.stylua,
          builtins.formatting.shfmt,
          builtins.formatting.prettierd.with({
            condition = function()
              return conditions.use_prettier()
            end,
          }),
          builtins.formatting.fish_indent,
          builtins.formatting.nginx_beautifier,
          builtins.formatting.cmake_format,
          builtins.formatting.dart_format,
          builtins.formatting.csharpier,
          builtins.formatting.clang_format,
          -- builtins.formatting.rustywind,

          builtins.diagnostics.fish,
          builtins.diagnostics.checkmake,
          builtins.diagnostics.commitlint.with({
            condition = function()
              return conditions.use_commitlint()
            end,
          }),
          builtins.diagnostics.selene,
        },
      })

      -- local muon = {
      --   name = "muon",
      --   method = none_ls.methods.FORMATTING,
      --   filetypes = { "meson" },
      --   generator = require("null-ls.helpers").formatter_factory({
      --     command = "muon",
      --     args = { "fmt", "-" },
      --   }),
      -- }
      -- none_ls.register(muon)

      local caddy = {
        name = "caddy",
        method = none_ls.methods.FORMATTING,
        filetypes = { "Caddyfile" },
        generator = require("null-ls.helpers").formatter_factory({
          command = "caddy",
          to_stdin = true,
          args = { "fmt", "-" },
        }),
      }
      none_ls.register(caddy)

      none_ls.register({
        name = "kdlfmt",
        method = none_ls.methods.FORMATTING,
        filetypes = { "kdl" },
        generator = require("null-ls.helpers").formatter_factory({
          command = "kdlfmt",
          to_stdin = true,
          args = { "format", "--stdin" },
        }),
      })
    end,
  },
}
