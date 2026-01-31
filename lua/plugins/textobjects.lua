---@type LazySpec
return {
  {
    "echasnovski/mini.ai",
    version = false,
    vscode = true,
    event = "VeryLazy",
    dependencies = { "nvim-treesitter/nvim-treesitter-textobjects", branch = "main" },
    opts = function()
      local gen_spec = require("mini.ai").gen_spec
      return {
        mappings = {
          around_next = "",
          inside_next = "",
          around_last = "",
          inside_last = "",
        },
        custom_textobjects = {
          f = gen_spec.treesitter({ a = "@function.outer", i = "@function.inner" }),
        },
      }
    end,
  },
}
