---@type LazySpec
return {

  {
    "Bekaboo/dropbar.nvim",
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
    event = { "WinLeave" },
    opts = {
      border = "single",
      animate = {
        enabled = false,
      },
    },
  },

  { "mrjones2014/smart-splits.nvim", build = "./kitty/install-kittens.bash" },
}
