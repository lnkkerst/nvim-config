---@type LazySpec
return {
  {
    "olimorris/codecompanion.nvim",
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

  {
    "GeorgesAlkhouri/nvim-aider",
    cmd = "Aider",
    opts = {},
  },

  {
    "milanglacier/minuet-ai.nvim",
    opts = {
      provider = "openai_compatible",
      provider_options = {
        openai_compatible = {
          model = "google/gemini-2.0-flash-001",
        },
      },

      virtualtext = {
        auto_trigger_ft = { "*" },
        keymap = {
          prev = "<A-[>",
          next = "<A-]>",
        },
      },
    },
  },
}
