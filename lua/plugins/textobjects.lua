---@type LazySpec
return {
  {
    "echasnovski/mini.ai",
    version = false,
    event = "VeryLazy",
    dependencies = { "nvim-treesitter/nvim-treesitter-textobjects" },
    opts = function()
      local gen_spec = require("mini.ai").gen_spec
      return {
        custom_textobjects = {
          f = gen_spec.treesitter({ a = "@function.outer", i = "@function.inner" }),
        },
      }
    end,
  },
}
