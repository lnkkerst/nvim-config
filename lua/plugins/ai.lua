---@type LazySpec
return {
  {
    "zbirenbaum/copilot.lua",
    cmd = "Copilot",
    event = "InsertEnter",
    opts = {
      suggestion = { enabled = true, auto_trigger = true },
      panel = { enabled = false },
    },
  },

  {
    "olimorris/codecompanion.nvim",
    version = false,
    cmd = {
      "CodeCompanion",
      "CodeCompanionChat",
      "CodeCompanionActions",
      "CodeCompanionCmd",
    },
    keys = {
      { "<leader>aa", "<cmd>CodeCompanionActions<cr>", desc = "CodeCompanion actions" },
      { "<leader>ai", "<cmd>CodeCompanion<cr>", mode = { "n", "x" }, "CodeCompanion" },
      { "<leader>ac", "<cmd>CodeCompanionChat Toggle<cr>", desc = "Toggle codecompanion chat" },
      { "ga", "<cmd>CodeCompanionChat Add<cr>", mode = { "x" }, desc = "Add code to codecompanion chat" },
    },
    dependencies = {
      "nvim-lua/plenary.nvim",
      "nvim-treesitter/nvim-treesitter",
    },
    opts = {},
    config = function(_, opts)
      require("plugins.codecompanion.fidget_spinner"):init()
      require("codecompanion").setup(opts)
    end,
  },
}
