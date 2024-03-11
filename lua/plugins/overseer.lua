return {
  {
    "stevearc/overseer.nvim",
    cmd = {
      "OverseerRun",
      "OverseerInfo",
      "OverseerOpen",
      "OverseerBuild",
      "OverseerClose",
      "OverseerRunCmd",
      "OverseerToggle",
      "OverseerCleanCache",
      "OverseerLoadBundle",
      "OverseerSaveBundle",
      "OverseerTaskAction",
      "OverseerQuickAction",
      "OverseerDeleteBundle",
    },
    config = function()
      local overseer = require("overseer")
      overseer.setup()

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
