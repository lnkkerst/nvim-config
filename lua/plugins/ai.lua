---@type LazySpec
return {
  {
    "olimorris/codecompanion.nvim",
    dependencies = {
      "nvim-lua/plenary.nvim",
      "nvim-treesitter/nvim-treesitter",
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
      require("config.codecompanion.fidget_spinner"):init()
      require("codecompanion").setup(opts)
    end,
  },

  {
    "milanglacier/minuet-ai.nvim",
    event = { "InsertEnter", "LazyFile" },
    enabled = function()
      -- Disabled by default
      return vim.env["NVIM_MINUET_CONFIG"] ~= nil and false
    end,
    opts = function()
      local env_config_str = vim.env["NVIM_MINUET_CONFIG"]
      local env_config = vim.json.decode(env_config_str)

      local config = {
        provider = "openai_compatible",
        provider_options = {
          openai_compatible = {
            model = env_config.model,
            end_point = env_config.end_point,
            api_key = env_config.api_key,
            name = "OpenAI Compatible",
          },
        },

        virtualtext = {
          auto_trigger_ft = { "*" },
          keymap = {
            prev = "<A-[>",
            next = "<A-]>",
          },
        },
      }

      if env_config.override ~= nil then
        config = vim.tbl_extend("force", config, env_config.override)
      end

      return config
    end,
  },

  {
    "folke/sidekick.nvim",
    event = "VeryLazy",
    keys = { { "<leader>as", "<cmd>Sidekick cli toggle<cr>" } },
    opts = {},
  },
}
