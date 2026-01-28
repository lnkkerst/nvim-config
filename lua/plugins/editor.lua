---@type LazySpec
return {
  {
    "PHSix/faster.nvim",
    vscode = true,
    keys = {
      { "j", "<Plug>(faster_move_gj)", desc = "Faster move j", mode = { "n" }, silent = true },
      { "k", "<Plug>(faster_move_gk)", desc = "Faster move k", mode = { "n" }, silent = true },

      { "j", "<Plug>(faster_vmove_j)", desc = "Faster move j", mode = { "v" }, silent = true },
      { "k", "<Plug>(faster_vmove_k)", desc = "Faster move k", mode = { "v" }, silent = true },
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
      map_cr = false,
      map_bs = false,
    },
  },

  {
    "RRethy/nvim-treesitter-endwise",
    ft = { "lua", "ruby", "vimscript" },
  },

  {
    "tzachar/highlight-undo.nvim",
    event = "VeryLazy",
    opts = {
      ignored_filetypes = {
        "neo-tree",
        "fugitive",
        "TelescopePrompt",
        "mason",
        "lazy",
        "leetcode.nvim",
        "snacks_dashboard",
      },
    },
    config = function(_, opts)
      require("highlight-undo").setup(opts)
      vim.api.nvim_set_hl(0, "HighlightUndo", { link = "Search" })
    end,
  },

  {
    "nacro90/numb.nvim",
    event = { "CmdlineEnter" },
    vscode = true,
    opts = {},
  },

  {
    "JoosepAlviste/nvim-ts-context-commentstring",
    lazy = true,
    opts = {
      enable_autocmd = false,
    },
    init = function()
      local get_option = vim.filetype.get_option
      vim.filetype.get_option = function(filetype, option)
        return option == "commentstring" and require("ts_context_commentstring.internal").calculate_commentstring()
          or get_option(filetype, option)
      end
    end,
  },

  {
    "nmac427/guess-indent.nvim",
    -- Make sure to register autocmd after builtin editorconfig plugin
    event = { "BufReadPre" },
    opts = {
      override_editorconfig = true,
    },
  },
}
