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
    "JoosepAlviste/nvim-ts-context-commentstring",
    dependencies = { "nvim-treesitter/nvim-treesitter" },
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
}
