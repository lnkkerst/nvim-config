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
    "nvim-zh/colorful-winsep.nvim",
    enabled = false,
    event = { "WinLeave" },
    opts = {
      border = "single",
      animate = {
        enabled = false,
      },
    },
  },
}
