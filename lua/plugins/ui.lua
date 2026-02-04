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
}
