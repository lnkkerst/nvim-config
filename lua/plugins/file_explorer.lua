return {
  {
    "stevearc/oil.nvim",
    dependencies = { "nvim-tree/nvim-web-devicons" },
    lazy = false,
    keys = {
      { "<leader>o", "<cmd>Oil<cr>", desc = "Open oil" },
      { "-", "<CMD>Oil<CR>", desc = "Open parent directory" },
    },
    ---@module 'oil'
    ---@type oil.SetupOpts
    opts = {
      columns = {
        "icon",
        "permissions",
        "size",
        "mtime",
      },
      keymaps = {
        ["<C-s>"] = false,
        ["<C-v>"] = { "actions.select", opts = { vertical = true } },
        ["<C-p>"] = false,
        ["gp"] = { "actions.preview", mode = "n" },
        ["q"] = { "actions.close", mode = "n" },
      },
      delete_to_trash = true,
      view_options = {
        show_hidden = true,
      },

      float = {
        border = "single",
      },
      confirmation = {
        border = "single",
      },
      progress = {
        border = "single",
      },
      ssh = {
        border = "single",
      },
      keymaps_help = {
        border = "single",
      },
    },
  },

  {
    "mikavilpas/yazi.nvim",
    enabled = true,
    event = "VeryLazy",
    dependencies = { "folke/snacks.nvim", lazy = true },
    opts = {
      yazi_floating_window_border = "single",
    },
  },
}
