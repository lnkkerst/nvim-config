---@type LazySpec
return {
  {
    "folke/which-key.nvim",
    event = "VeryLazy",
    vscode = true,
    opts = {
      preset = "modern",
      delay = 1000,
      win = {
        border = "single",
      },
    },
    keys = {
      {
        "<leader>?",
        function()
          require("which-key").show({ global = false })
        end,
        desc = "Buffer Local Keymaps (which-key)",
      },
    },
    config = function(_, opts)
      local wk = require("which-key")
      wk.setup(opts)
      wk.add({
        { "<leader>a", group = "AI" },
        { "<leader>d", group = "DAP" },
        { "<leader>f", group = "Pickers" },
        { "<leader>q", group = "Quickfix" },
      })
    end,
  },

  {
    "uga-rosa/ccc.nvim",
    event = "VeryLazy",
    opts = {
      highlighter = {
        auto_enable = true,
        lsp = false,
        update_insert = false,
      },
      lsp = false,
      win_opts = {
        border = "single",
      },
    },
  },

  {
    "danymat/neogen",
    cmd = "Neogen",
    opts = {},
  },

  {
    "ThePrimeagen/refactoring.nvim",
    cmd = { "Refactor" },
    dependencies = {
      { "nvim-lua/plenary.nvim" },
    },
    opts = {},
  },

  {
    "echasnovski/mini.keymap",
    version = false,
    vscode = true,
    opts = {},
  },

  {
    "willothy/flatten.nvim",
    opts = {},
    lazy = false,
    priority = 1001,
  },
}
