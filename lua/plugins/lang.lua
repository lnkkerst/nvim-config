---@type LazySpec
return {
  -- rust
  {
    "vxpm/ferris.nvim",
    ft = { "rust" },
    opts = { create_commands = true },
  },

  {
    "Saecki/crates.nvim",
    event = "BufRead Cargo.toml",
    opts = {
      lsp = {
        enabled = true,
        actions = true,
        completion = true,
        hover = true,
      },
    },
  },

  -- lua
  {
    "folke/lazydev.nvim",
    opts = {
      library = {
        {
          path = "lazy.nvim",
          words = { "Lazy.*Spec" },
        },
      },
    },
    lazy = true,
    ft = "lua",
  },

  -- python
  {
    "AckslD/swenv.nvim",
    ft = { "python" },
    init = function()
      vim.api.nvim_create_autocmd("FileType", {
        group = vim.api.nvim_create_augroup("swenv_auto", { clear = true }),
        pattern = { "python" },
        callback = function()
          require("swenv.api").auto_venv()
        end,
      })
      vim.api.nvim_create_user_command("SwitchVenv", function()
        require("swenv.api").pick_venv()
      end, {})
    end,
    opts = function()
      return {
        venvs_path = vim.fn.expand("~/.virtualenvs"),
        post_set_venv = function()
          for _, client_name in ipairs({ "basedpyright", "pyright" }) do
            local client = vim.lsp.get_clients({ name = client_name })[1]
            if not client then
              return
            end
            local venv = require("swenv.api").get_current_venv()
            if not venv then
              return
            end
            local venv_python = venv.path .. "/bin/python"
            if client.settings then
              client.settings = vim.tbl_deep_extend("force", client.settings, { python = { pythonPath = venv_python } })
            else
              client.config.settings =
                vim.tbl_deep_extend("force", client.config.settings, { python = { pythonPath = venv_python } })
            end
            client.notify("workspace/didChangeConfiguration", { settings = nil })
          end
        end,
      }
    end,
  },

  -- go
  {
    "olexsmir/gopher.nvim",
    enabled = true,
    -- branch = "develop", -- if you want develop branch
    -- keep in mind, it might break everything
    ft = "go",
    cmd = { "GoInstallDeps" },
    dependencies = {
      "nvim-lua/plenary.nvim",
      "mfussenegger/nvim-dap", -- (optional) only if you use `gopher.dap`
    },

    -- (optional) will update plugin's deps on every update
    build = function()
      require("gopher")
      vim.cmd.GoInstallDeps()
    end,
    ---@type gopher.Config
    opts = {},
  },

  -- markdown
  {
    "iamcco/markdown-preview.nvim",
    ft = "markdown",
    build = "cd app && pnpm install",
  },

  -- java
  {
    "mfussenegger/nvim-jdtls",
    lazy = true,
  },
}
