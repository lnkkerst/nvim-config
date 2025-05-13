---@type LazySpec
return {
  {
    "michaelb/sniprun",
    cmd = { "SnipRun" },
    build = "bash install.sh",
    opts = {},
  },

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
      overseer.setup({
        templates = { "builtin" },
      })

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

  {
    "skywind3000/asyncrun.vim",
    cmd = { "AsyncRun", "AsyncStop", "AsyncReset" },
    init = function()
      vim.g.asyncrun_open = 6
    end,
  },
  {
    "skywind3000/asynctasks.vim",
    dependencies = { "skywind3000/asyncrun.vim" },
    keys = {
      {
        "<leader>ft",
        function()
          local items = {}
          local longest_name = 0
          for i, task in ipairs(vim.fn["asynctasks#source"](math.floor(vim.opt.columns:get() * 48 / 100))) do
            local text = table.concat(task, " ")
            local name = table.remove(task, 1)
            local command = table.concat(task, " ")
            table.insert(items, {
              idx = i,
              score = i,
              name = name,
              command = command,
              text = text,
            })
            longest_name = math.max(longest_name, #name)
          end
          longest_name = longest_name + 2
          require("snacks").picker({
            items = items,
            format = function(item)
              local ret = {}
              ret[#ret + 1] = { ("%-" .. longest_name .. "s"):format(item.name), "SnacksPickerLabel" }
              ret[#ret + 1] = { item.command, "SnacksPickerComment" }
              return ret
            end,
            layout = {
              preset = "select",
            },
            confirm = function(picker, item)
              picker:close()
              vim.cmd("AsyncTask " .. item.name)
            end,
          })
        end,
      },
    },
    cmd = {
      "AsyncTask",
      "AsyncTaskEdit",
      "AsyncTaskLast",
      "AsyncTaskList",
      "AsyncTaskMacro",
      "AsyncTaskEnviron",
      "AsyncTaskProfile",
    },
  },
}
