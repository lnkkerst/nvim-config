return {
  { "nvim-lua/plenary.nvim" },

  {
    "nvim-zh/colorful-winsep.nvim",
    enabled = true,
    event = "VimEnter",
    config = true,
  },

  {
    "danymat/neogen",
    dependencies = { "nvim-treesitter/nvim-treesitter" },
    cmd = "Neogen",
    opts = {
      snippet_engine = "luasnip",
    },
  },

  {
    "max397574/better-escape.nvim",
    event = "InsertEnter",
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

  {
    "NvChad/nvim-colorizer.lua",
    enabled = false,
    config = true,
  },
  {
    "uga-rosa/ccc.nvim",
    opts = {
      highlighter = {
        auto_enable = true,
        lsp = true,
      },
    },
  },

  {
    "nacro90/numb.nvim",
    event = { "CmdlineEnter" },
    config = true,
  },

  {
    "folke/twilight.nvim",
    cmd = { "Twilight", "TwilightEnable", "TwilightDisable" },
  },
  { "folke/zen-mode.nvim", cmd = { "ZenMode" } },

  {
    "skywind3000/asyncrun.vim",
    cmd = { "AsyncRun", "AsyncStop", "AsyncReset" },
    config = function()
      vim.g.asyncrun_open = 6
    end,
  },

  {
    "mrjones2014/legendary.nvim",
    priority = 10000,
    lazy = false,
    opts = {
      { extensions = { lazy_nvim = true } },
    },
  },

  {
    "iamcco/markdown-preview.nvim",
    ft = "markdown",
    build = "cd app && pnpm install",
  },

  {
    "sindrets/diffview.nvim",
    cmd = {
      "DiffviewOpen",
      "DiffviewClose",
      "DiffviewLog",
      "DiffviewRefresh",
      "DiffviewFocusFiles",
      "DiffviewFileHistory",
      "DiffviewToggleFiles",
    },
  },

  {
    "sbdchd/neoformat",
    cmd = "Neoformat",
    keys = {
      {
        "<M-S-f>",
        "<cmd>Neoformat<cr>",
        desc = "Neoformat",
      },
    },
  },

  -- nvim has built-in support for editorconfig: https://neovim.io/doc/user/editorconfig.html
  {
    "gpanders/editorconfig.nvim",
    enabled = false,
    event = "VeryLazy",
  },

  {
    "junegunn/fzf",
    enabled = false,
    lazy = true,
    build = function()
      vim.fn["fzf#install"]()
    end,
  },

  { "famiu/bufdelete.nvim", enable = false },

  {
    "stevearc/aerial.nvim",
    cmd = {
      "AerialToggle",
      "AerialGo",
      "AerialInfo",
      "AerialNavToggle",
      "AerialNext",
      "AerialPrev",
      "AerialOpen",
      "AerialClose",
      "AerialNavOpen",
      "AerialNavClose",
      "AerialOpenAll",
      "AerialCloseAll",
    },
    keys = {
      {
        "<A-a>",
        "<cmd>AerialToggle<cr>",
        desc = "Toggle Aerial",
      },
    },
    config = true,
  },

  { "nvim-lua/popup.nvim", lazy = true },

  {
    "eandrju/cellular-automaton.nvim",
    cmd = "CellularAutomaton",
  },

  {
    "xiyaowong/transparent.nvim",
    enabled = false,
    config = function()
      require("transparent").setup({
        extra_groups = { "Pmenu", "Float", "NormalFloat" },
      })
      require("transparent").clear_prefix("BufferLine")
    end,
  },

  {
    "tzachar/highlight-undo.nvim",
    opts = {},
  },

  {
    "stevearc/oil.nvim",
    opts = {
      columns = {
        "icon",
        "permissions",
        "size",
        "mtime",
      },
    },
  },

  {
    "folke/todo-comments.nvim",
    dependencies = { "nvim-lua/plenary.nvim" },
    opts = {},
  },
}
