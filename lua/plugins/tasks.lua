---@type LazySpec
return {
  {
    "stevearc/overseer.nvim",
    cmd = {
      "OverseerRun",
      "OverseerOpen",
      "OverseerClose",
      "OverseerToggle",
      "OverseerShell",
      "OverseerTaskAction",
    },
    opts = {
      templates = { "builtin" },
    },
    init = function()
      vim.cmd.cnoreabbrev("OS OverseerShell")
    end,
    config = function(_, opts)
      local overseer = require("overseer")
      overseer.setup(opts)

      overseer.register_template({
        name = "g++ build",
        builder = function()
          -- Full path to current file (see :help expand())
          local file = vim.fn.expand("%:p")
          return {
            cmd = { "g++" },
            args = { file },
            components = { { "on_output_quickfix", open = true }, "default" },
          }
        end,
        condition = {
          filetype = { "cpp" },
        },
      })
    end,
  },
}
