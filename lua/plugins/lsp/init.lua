---@type LazySpec
return {
  {
    "nvimdev/lspsaga.nvim",
    -- branch = "main",
    event = "LspAttach",
    dependencies = {
      "nvim-treesitter/nvim-treesitter",
      "nvim-tree/nvim-web-devicons",
    },
    keys = {
      {
        "gd",
        "<cmd>Lspsaga peek_definition<cr>",
        desc = "Peek definition",
      },
      {
        "gD",
        "<cmd>Lspsaga peek_type_definition<cr>",
        desc = "Peek type definition",
      },
      {
        "gh",
        "<cmd>Lspsaga finder<cr>",
        desc = "Lsp finder",
      },
      {
        "]d",
        "<cmd>Lspsaga diagnostic_jump_next<cr>",
        desc = "Jump to next diagnostic",
      },
      {
        "[d",
        "<cmd>Lspsaga diagnostic_jump_prev<cr>",
        desc = "Jump to prev diagnostic",
      },
      {
        "]D",
        function()
          require("lspsaga.diagnostic"):goto_next({
            severity = vim.diagnostic.severity.ERROR,
          })
        end,
        desc = "Jump to next error diagnostic",
      },
      {
        "[D",
        function()
          require("lspsaga.diagnostic"):goto_prev({
            severity = vim.diagnostic.severity.ERROR,
          })
        end,
        desc = "Jump to prev error diagnostic",
      },
      {
        "K",
        "<cmd>Lspsaga hover_doc<cr>",
        desc = "Hover doc",
      },
      {
        "<leader>ca",
        "<cmd>Lspsaga code_action<cr>",
        desc = "Code Action",
        mode = { "n", "v" },
      },
      {
        "<leader>rn",
        "<cmd>Lspsaga rename<cr>",
        desc = "Rename symbol",
      },
      {
        "<leader>cd",
        "<cmd>Lspsaga show_line_diagnostics<cr>",
        desc = "Show line diagnostics",
      },
      {
        "<A-o>",
        "<cmd>Lspsaga outline<cr>",
        desc = "Lspsaga outline",
      },
    },
    opts = function()
      ---@module 'lspsaga'
      ---@type LspsagaConfig
      return {
        ui = {
          border = "single",
          code_action = "",
          colors = require("catppuccin.groups.integrations.lsp_saga").custom_colors(),
          kind = require("catppuccin.groups.integrations.lsp_saga").custom_kind(),
        },
        code_action = {
          show_server_name = true,
          extend_gitsigns = true,
        },
        rename = {
          in_select = false,
        },
        symbol_in_winbar = {
          enable = true,
        },
        lightbulb = {
          enable = false,
        },
      }
    end,
  },

  {
    "williamboman/mason.nvim",
    lazy = true,
    cmd = { "Mason" },
    opts = {},
  },

  {
    "j-hui/fidget.nvim",
    enabled = true,
    event = { "LspAttach" },
    opts = {},
  },

  { "b0o/schemastore.nvim", event = { "LspAttach" } },

  {
    "rachartier/tiny-inline-diagnostic.nvim",
    version = false,
    event = "LspAttach",
    priority = 1000,
    opts = {
      preset = "modern",
      options = {
        show_source = true,
        multiple_diag_under_cursor = true,
        virt_texts = {
          priority = 4096,
        },
      },
    },
  },

  {
    "chrisgrieser/nvim-lsp-endhints",
    event = "LspAttach",
    opts = {
      label = {
        padding = 1,
        marginLeft = 1,
      },
    },
    init = function()
      vim.api.nvim_create_autocmd("InsertEnter", {
        callback = function()
          vim.lsp.inlay_hint.enable(false)
        end,
      })

      vim.api.nvim_create_autocmd("InsertLeave", {
        callback = function()
          vim.lsp.inlay_hint.enable(true)
        end,
      })
    end,
  },

  {
    "Issafalcon/lsp-overloads.nvim",
    lazy = true,
    opts = {},
    init = function()
      vim.api.nvim_create_autocmd("LspAttach", {
        group = vim.api.nvim_create_augroup("lsp-overloads", { clear = true }),
        callback = function(args)
          local client = vim.lsp.get_client_by_id(args.data.client_id)
          require("lsp-overloads").setup(client, {
            ui = {
              close_events = { "CursorMoved", "BufHidden", "InsertLeave", "WinNew" },
            },
            display_automatically = false,
          })
          vim.keymap.set({ "n", "i" }, "<A-s>", "<cmd>LspOverloadsSignature<CR>")
        end,
      })
    end,
  },
}
