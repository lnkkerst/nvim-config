---@type LazySpec
return {
  {
    "kevinhwang91/nvim-bqf",
    version = false,
    ft = "qf",
    dependencies = {
      {
        "junegunn/fzf",
      },
    },
    opts = {
      preview = {
        border = "single",
      },
    },
  },
  {
    "stevearc/quicker.nvim",
    ft = "qf",
    keys = {
      {
        "<leader>qq",
        function()
          require("quicker").toggle()
        end,
        desc = "Toggle quickfix",
      },

      {
        "<leader>ll",
        function()
          require("quicker").toggle({ loclist = true })
        end,
        desc = "Toggle loclist",
      },
    },
    ---@module "quicker"
    ---@type quicker.SetupOptions
    opts = {},
  },
}
