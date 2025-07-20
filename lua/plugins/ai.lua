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
    event = { "InsertEnter", "LazyFile" },
    enabled = function()
      -- Disabled by default
      return vim.env["NVIM_MINUET_CONFIG"] ~= nil
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
}
