---@type LazySpec
return {
  {
    "stevearc/oil.nvim",
    dependencies = { "nvim-tree/nvim-web-devicons" },
    version = false,
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
    },
  },
}
