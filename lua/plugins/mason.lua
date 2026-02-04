---@type LazySpec
return {
  {
    "mason-org/mason.nvim",
    version = false,
    init = function()
      require("config.mason").init()
    end,
    opts = {},
  },
}
