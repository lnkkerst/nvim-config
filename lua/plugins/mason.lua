---@type LazySpec
return {
  {
    "mason-org/mason-lspconfig.nvim",
    version = false,
    event = { "LazyFile" },
    cmd = { "Mason" },
    opts = function()
      local lsp = require("lsp")
      ---@module 'mason-lspconfig'
      ---@type MasonLspconfigSettings
      return {
        ensure_installed = vim.g.mason_auto_install and lsp.server_lists.servers_with_mason or {},
        automatic_enable = false,
      }
    end,
    dependencies = {
      { "mason-org/mason.nvim", version = false, opts = {} },
      { "neovim/nvim-lspconfig", version = false },
    },
  },

  {
    "jay-babu/mason-null-ls.nvim",
    event = { "LazyFile" },
    dependencies = {
      "williamboman/mason.nvim",
      "nvimtools/none-ls.nvim",
    },
    opts = {
      automatic_installation = vim.g.mason_auto_install,
    },
  },

  {
    "jay-babu/mason-nvim-dap.nvim",
    event = { "LazyFile" },
    dependencies = {
      "williamboman/mason.nvim",
      "mfussenegger/nvim-dap",
    },
    opts = {
      automatic_installation = vim.g.mason_auto_install,
    },
  },

  {
    "WhoIsSethDaniel/mason-tool-installer.nvim",
    event = { "LazyFile" },
    opts = {},
  },
}
