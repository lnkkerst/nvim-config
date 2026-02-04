---@type LazySpec
return {
  {
    "nvimtools/none-ls.nvim",
    dependencies = { "nvim-lua/plenary.nvim", "mason.nvim" },
    event = { "BufReadPre", "BufNewFile" },
    config = function()
      local none_ls = require("null-ls")
      local builtins = require("null-ls.builtins")

      local cond = require("utils.conditions")
      local utils = require("utils")

      none_ls.setup({
        sources = {
          builtins.formatting.stylua,
          builtins.formatting.shfmt,
          builtins.formatting.prettier.with({
            condition = function()
              return not cond.has_biome()
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
              return cond.has_commitlint()
            end,
          }),
          builtins.diagnostics.selene,
        },
      })

      if utils.executable("muon") then
        none_ls.register({
          name = "muon",
          method = none_ls.methods.FORMATTING,
          filetypes = { "meson" },
          generator = require("null-ls.helpers").formatter_factory({
            command = "muon",
            args = { "fmt", "-" },
          }),
        })
      end

      if utils.executable("caddy") then
        none_ls.register({
          name = "caddy",
          method = none_ls.methods.FORMATTING,
          filetypes = { "Caddyfile" },
          generator = require("null-ls.helpers").formatter_factory({
            command = "caddy",
            to_stdin = true,
            args = { "fmt", "-" },
          }),
        })
      end

      if utils.executable("kdlfmt") then
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
      end
    end,
  },
}
