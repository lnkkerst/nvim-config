---@type LazySpec
return {
  {
    "nvim-treesitter/nvim-treesitter",
    branch = "main",
    version = false,
    opts = {},
  },

  {
    "HiPhish/rainbow-delimiters.nvim",
    submodules = false,
    event = { "BufReadPost" },
    dependencies = { { "nvim-treesitter/nvim-treesitter" } },
  },

  {
    "nvim-treesitter/nvim-treesitter-context",
    event = { "BufReadPost" },
    opts = {},
  },

  {
    "windwp/nvim-ts-autotag",
    event = { "BufReadPre", "BufNewFile" },
    opts = {
      opts = {
        enable_close_on_slash = true,
      },
    },
  },

  {
    "kylechui/nvim-surround",
    event = "VeryLazy",
    opts = {},
  },

  {
    "andymass/vim-matchup",
    version = false,
    event = { "BufReadPost" },
    ---@module 'match-up'
    ---@type matchup.Config
    opts = {
      matchparen = {
        offscreen = {
          method = "popup",
        },
      },
      treesitter = {
        stopline = 500,
      },
    },
  },
}
