---@type LazySpec
return {
  {
    "PHSix/faster.nvim",
    -- event = "VeryLazy",
    vscode = true,
    keys = {
      {
        "j",
        "<Plug>(faster_move_j)",
        desc = "Faster move j",
        mode = { "n" },
        silent = true,
      },
      {
        "k",
        "<Plug>(faster_move_k)",
        desc = "Faster move k",
        mode = { "n" },
        silent = true,
      },
    },
  },

  {
    "windwp/nvim-autopairs",
    enabled = true,
    event = "InsertEnter",
    opts = {
      check_ts = true,
      ts_config = {
        lua = { "string" },
        javascript = { "template_string" },
      },
    },
  },
  {
    "altermo/ultimate-autopair.nvim",
    enabled = false,
    event = { "InsertEnter", "CmdlineEnter" },
    branch = "v0.6", --recommended as each new version will have breaking changes
    opts = {
      --Config goes here
    },
  },
  {
    "RRethy/nvim-treesitter-endwise",
    ft = { "lua", "ruby", "vimscript" },
  },

  {
    "gbprod/yanky.nvim",
    opts = {},
    keys = {
      { "p", "<Plug>(YankyPutAfter)", mode = { "n", "x" } },
      { "P", "<Plug>(YankyPutBefore)", mode = { "n", "x" } },
      { "gp", "<Plug>(YankyGPutAfter)", mode = { "n", "x" } },
      { "gP", "<Plug>(YankyGPutBefore)", mode = { "n", "x" } },
      { "y", "<Plug>(YankyYank)", mode = { "n", "x" } },
      { "<M-S-n>", "<Plug>(YankyCycleForward)", mode = { "n" } },
      { "<M-S-p>", "<Plug>(YankyCycleBackward)", mode = { "n" } },
      {
        "[y",
        "<Plug>(YankyCycleForward)",
        desc = "Cycle Forward Through Yank History",
      },
      {
        "]y",
        "<Plug>(YankyCycleBackward)",
        desc = "Cycle Backward Through Yank History",
      },
    },
  },

  {
    "tzachar/highlight-undo.nvim",
    keys = { { "u" }, { "<C-r>" }, { "p" }, { "P" } },
    opts = {
      ignored_filetypes = {
        "neo-tree",
        "fugitive",
        "TelescopePrompt",
        "mason",
        "lazy",
        "leetcode.nvim",
      },
    },
  },

  {
    "nacro90/numb.nvim",
    event = { "CmdlineEnter" },
    vscode = true,
    opts = {},
  },

  {
    "max397574/better-escape.nvim",
    event = "InsertEnter",
    vscode = true,
    opts = {
      default_mappings = false,
      mappings = {
        i = {
          j = {
            k = "<Esc>",
            j = "<Esc>",
          },
        },
      },
    },
  },
}
