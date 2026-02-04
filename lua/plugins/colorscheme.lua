---@type LazySpec
return {
  {
    "catppuccin/nvim",
    name = "catppuccin",
    version = false,
    priority = 1000,
    opts = function()
      ---@module 'catppuccin'
      ---@type CatppuccinOptions
      return {
        flavour = "mocha",
        -- transparent_background = not vim.g.neovide,
        show_end_of_buffer = false,
        term_colors = false,
        styles = {
          comments = { "italic" },
          conditionals = { "italic" },
          loops = {},
          functions = {},
          keywords = {},
          strings = {},
          variables = {},
          numbers = {},
          booleans = {},
          properties = {},
          types = {},
          operators = {},
        },
        integrations = {
          gitsigns = true,
          treesitter = true,
          treesitter_context = true,
          mason = true,
          neogit = true,
          rainbow_delimiters = true,
          which_key = true,
          fidget = true,
          dap = true,
          native_lsp = {
            enabled = true,
            virtual_text = {
              errors = { "italic" },
              hints = { "italic" },
              warnings = { "italic" },
              information = { "italic" },
            },
            underlines = {
              errors = { "underline" },
              hints = { "underline" },
              warnings = { "underline" },
              diff = true,
              information = { "underline" },
            },
            inlay_hints = {
              background = true,
            },
          },
          overseer = true,
          colorful_winsep = {
            enabled = true,
            color = "blue",
          },
          grug_far = true,
          fzf = true,
          blink_cmp = true,
          nvim_surround = true,
          snacks = true,
          copilot_vim = true,
          mini = {
            enabled = true,
          },
          dropbar = true,
          diffview = true,
        },
      }
    end,
    config = function(_, opts)
      require("catppuccin").setup(opts)
      vim.api.nvim_command("colorscheme catppuccin")
    end,
  },
}
