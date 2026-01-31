---@type LazySpec
return {

  { "b0o/schemastore.nvim", lazy = true, event = { "LspAttach" } },

  {
    "rachartier/tiny-inline-diagnostic.nvim",
    version = false,
    event = { "LspAttach", "LazyFile" },
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
      -- disable inlay hints in insert mode
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
}
