---@type LazySpec
return {
  {
    "Bekaboo/dropbar.nvim",
    event = { "LazyFile" },
    opts = {
      bar = {},
      icons = {
        ui = {
          bar = {
            separator = " › ",
          },
        },
      },
    },
  },

  {
    "nvim-zh/colorful-winsep.nvim",
    event = { "WinLeave" },
    opts = {
      border = "single",
      animate = {
        enabled = false,
      },
    },
  },

  {
    "mrjones2014/smart-splits.nvim",
    build = "./kitty/install-kittens.bash",
    lazy = false,
    keys = {
      {
        "<C-h>",
        function()
          require("smart-splits").move_cursor_left()
        end,
        desc = "Move cursor left",
        mode = { "n", "t" },
      },
      {
        "<C-j>",
        function()
          require("smart-splits").move_cursor_down()
        end,
        desc = "Move cursor down",
        mode = { "n", "t" },
      },
      {
        "<C-k>",
        function()
          require("smart-splits").move_cursor_up()
        end,
        desc = "Move cursor up",
        mode = { "n", "t" },
      },
      {
        "<C-l>",
        function()
          require("smart-splits").move_cursor_right()
        end,
        desc = "Move cursor right",
        mode = { "n", "t" },
      },
      {
        "<M-h>",
        function()
          require("smart-splits").resize_left()
        end,
        desc = "Resize left",
        mode = { "n", "t" },
      },
      {
        "<M-j>",
        function()
          require("smart-splits").resize_down()
        end,
        desc = "Resize down",
        mode = { "n", "t" },
      },
      {
        "<M-k>",
        function()
          require("smart-splits").resize_up()
        end,
        desc = "Resize up",
        mode = { "n", "t" },
      },
      {
        "<M-l>",
        function()
          require("smart-splits").resize_right()
        end,
        desc = "Resize right",
        mode = { "n", "t" },
      },
      {
        "<leader><leader>h",
        function()
          require("smart-splits").swap_buf_left()
        end,
        desc = "Swap buffer left",
        mode = { "n" },
      },
      {
        "<leader><leader>j",
        function()
          require("smart-splits").swap_buf_down()
        end,
        desc = "Swap buffer down",
        mode = { "n" },
      },
      {
        "<leader><leader>k",
        function()
          require("smart-splits").swap_buf_up()
        end,
        desc = "Swap buffer up",
        mode = { "n" },
      },
      {
        "<leader><leader>l",
        function()
          require("smart-splits").swap_buf_right()
        end,
        desc = "Swap buffer right",
        mode = { "n" },
      },
    },
    opts = {
      default_amount = 1,
    },
  },
}
