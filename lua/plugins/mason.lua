---@type LazySpec
return {
  {
    "mason-org/mason.nvim",
    version = false,
    cmd = { "Mason" },
    init = function()
      require("config.mason").init()
    end,
    opts = {},
  },
}
