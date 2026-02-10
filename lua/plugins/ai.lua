---@type LazySpec
return {
  {
    "olimorris/codecompanion.nvim",
    dependencies = {
      "nvim-lua/plenary.nvim",
    },
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
    opts = {
      interactions = {
        chat = {
          keymaps = {
            send = {
              callback = function(chat)
                vim.cmd("stopinsert")
                chat:submit()
                chat:add_buf_message({ role = "llm", content = "" })
              end,
            },
          },
        },
      },
      adapters = {
        http = {
          oaipro = function()
            return require("codecompanion.adapters").extend("openai_compatible", {
              name = "oaipro",
              formatted_name = "OAIPro",
              env = {
                url = "https://api.oaipro.com",
                api_key = "OAIPRO_API_KEY",
                chat_url = "/v1/chat/completions",
              },
            })
          end,

          openrouter = function()
            return require("codecompanion.adapters").extend("openai_compatible", {
              name = "openrouter",
              formatted_name = "OpenRouter",
              env = {
                url = "https://openrouter.ai/api",
                api_key = "OPENROUTER_API_KEY",
                chat_url = "/v1/chat/completions",
              },
            })
          end,
        },
      },
      extensions = {},
    },
    config = function(_, opts)
      require("config.codecompanion.spinner"):init()
      require("codecompanion").setup(opts)
    end,
  },

  {
    "folke/sidekick.nvim",
    event = "VeryLazy",
    keys = {
      { "<leader>ss", "<cmd>Sidekick cli toggle<cr>" },
      { "<leader>sp", "<cmd>Sidekick cli prompt<cr>", mode = { "n", "v" } },
    },
    opts = {},
  },
}
