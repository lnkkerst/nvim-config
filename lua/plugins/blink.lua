---@type LazySpec
return {
  {
    "saghen/blink.cmp",
    version = "*",
    event = { "InsertEnter", "CmdlineEnter" },
    dependencies = {
      "rafamadriz/friendly-snippets",
      {
        "xzbdmw/colorful-menu.nvim",
        opts = {},
        config = function(_, opts)
          vim.api.nvim_set_hl(0, "BlinkCmpLabelMatch", { bold = true })
          require("colorful-menu").setup(opts)
        end,
      },
    },
    ---@module 'blink.cmp'
    ---@type blink.cmp.Config
    opts = {
      enabled = function()
        if vim.tbl_contains({ "prompt" }, vim.bo.buftype) then
          return false
        end
        return true
      end,

      appearance = {
        nerd_font_variant = "normal",
      },

      sources = {
        default = { "lsp", "path", "snippets", "buffer", "cmdline", "lazydev" },
        providers = {
          lazydev = {
            name = "LazyDev",
            module = "lazydev.integrations.blink",
            score_offset = 100,
          },
          buffer = {
            opts = {
              get_bufnrs = function()
                return vim.tbl_filter(function(bufnr)
                  return vim.bo[bufnr].buftype == ""
                end, vim.api.nvim_list_bufs())
              end,
            },
          },
        },
      },

      keymap = {
        preset = "none",
        ["<C-space>"] = { "show", "show_documentation", "hide_documentation" },
        ["<C-y>"] = { "accept", "fallback" },
        ["<C-j>"] = { "select_next", "fallback" },
        ["<C-k>"] = { "select_prev", "fallback" },
        ["<C-p>"] = { "select_prev", "fallback_to_mappings" },
        ["<C-n>"] = { "select_next", "fallback_to_mappings" },
        ["<C-u>"] = { "scroll_documentation_up", "fallback" },
        ["<C-d>"] = { "scroll_documentation_down", "fallback" },
      },

      completion = {
        keyword = {
          range = "full",
        },

        trigger = {
          show_in_snippet = true,
          prefetch_on_insert = false,
        },

        list = {
          selection = {
            preselect = false,
            auto_insert = true,
          },
        },

        accept = {
          auto_brackets = {
            enabled = false,
          },
        },

        menu = {
          auto_show = true,
          auto_show_delay_ms = 100,
          draw = {
            -- We don't need label_description now because label and label_description are already
            -- combined together in label by colorful-menu.nvim.
            columns = {
              { "label", gap = 1 },
              { "kind", "source_name", gap = 1 },
            },
            components = {
              label = {
                text = function(ctx)
                  return require("colorful-menu").blink_components_text(ctx)
                end,
                highlight = function(ctx)
                  return require("colorful-menu").blink_components_highlight(ctx)
                end,
              },
            },
          },
        },

        documentation = {
          auto_show = true,
          auto_show_delay_ms = 500,
        },

        ghost_text = {
          enabled = false,
        },
      },

      signature = {
        enabled = true,
      },

      cmdline = {
        enabled = true,
        keymap = {
          ["<C-j>"] = { "select_next" },
          ["<C-k>"] = { "select_prev" },
        },
        completion = {
          menu = {
            auto_show = true,
          },
          list = {
            selection = {
              preselect = false,
              auto_insert = true,
            },
          },
        },
      },
    },
  },

  {
    "chrisgrieser/nvim-scissors",
    cmd = {
      "ScissorsEditSnippet",
      "ScissorsAddNewSnippet",
      "ScissorsCreateSnippetsForSnippetVars",
    },
    opts = {},
  },
}
