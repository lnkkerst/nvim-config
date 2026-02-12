---@type LazySpec
return {
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
