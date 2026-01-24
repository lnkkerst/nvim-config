---@type LazySpec
return {
  {
    "rebelot/heirline.nvim",
    enabled = true,
    version = false,
    event = { "VeryLazy" },
    keys = {
      { "<M-p>", "<cmd>bp<cr>", desc = "Previous buffer" },
      { "<M-n>", "<cmd>bn<cr>", desc = "Next buffer" },
    },
    opts = function()
      local statuslines = require("config.heirline.statuslines")
      local tabline = require("config.heirline.tabline")
      local colors = require("config.heirline.colors")
      local conditions = require("heirline.conditions")

      return {
        statusline = statuslines.Statusline,
        -- winbar = { statuslines.WinBar },
        tabline = { tabline.make_bufferline() },
        opts = {
          colors = colors.setup(),
          disable_winbar_cb = function(args)
            return conditions.buffer_matches({
              buftype = { "nofile", "prompt", "help", "quickfix", "terminal" },
              filetype = { "^git.*", "fugitive", "Trouble", "dashboard" },
            }, args.buf)
          end,
        },
      }
    end,
    init = function()
      vim.opt.showtabline = 2

      vim.api.nvim_create_autocmd("FileType", {
        pattern = { "snacks_dashboard" },
        callback = function()
          vim.opt.showtabline = 0
        end,
      })

      vim.api.nvim_create_autocmd("BufWinLeave", {
        pattern = "*",
        callback = function()
          vim.opt.showtabline = 2
        end,
      })
    end,
    config = function(_, opts)
      vim.api.nvim_set_hl(0, "StatusLine", {})

      require("heirline").setup(opts)
    end,
  },
}
