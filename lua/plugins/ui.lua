---@type LazySpec
return {
  {
    "Bekaboo/dropbar.nvim",
    event = { "LazyFile" },
    opts = {
      bar = {},
      icons = {
        ui = {
          bar = {
            separator = " › ",
          },
        },
      },
    },
  },
  {
    "folke/edgy.nvim",
    event = "VeryLazy",
    opts = {
      animate = {
        enabled = false,
      },
      wo = {
        winbar = false,
      },
      bottom = {
        {
          ft = "snacks_terminal",
          size = { height = 0.3 },
        },
        { ft = "qf", title = "QuickFix" },
        {
          ft = "help",
          size = { height = 20 },
        },
      },
      left = {},
      right = {
        {
          ft = "grug-far",
          size = { width = 0.4 },
        },
        {
          ft = "sidekick_terminal",
          size = { width = 0.4 },
        },
        {
          ft = "codecompanion",
          size = { width = 0.4 },
        },
      },
    },
  },
  {
    "nvim-zh/colorful-winsep.nvim",
    event = { "WinLeave" },
    opts = {
      border = "single",
      animate = {
        enabled = false,
      },
    },
  },
}
