---@type LazySpec
return {
  {
    "kevinhwang91/nvim-bqf",
    enabled = true,
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
    enabled = true,
    ft = "qf",
    keys = {
      {
        "<leader>qq",
        function()
          require("quicker").toggle()
        end,
      },

      {
        "<leader>ll",
        function()
          require("quicker").toggle({ loclist = true })
        end,
      },
    },
    ---@module "quicker"
    ---@type quicker.SetupOptions
    opts = {},
  },
}
