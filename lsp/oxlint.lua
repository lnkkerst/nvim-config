return {
  cmd = { "oxc_language_server" },
  filetypes = {
    "astro",
    "javascript",
    "javascriptreact",
    "svelte",
    "typescript",
    "typescript.tsx",
    "typescriptreact",
    "vue",
  },
  root_markers = { ".oxlintrc.json" },
  single_file_support = false,

  on_attach = function()
    vim.api.nvim_buf_create_user_command(0, "OxFixAll", function()
      local client = vim.lsp.get_clients({ bufnr = 0, name = "oxlint" })[1]
      if client == nil then
        return
      end

      client:request("workspace/executeCommand", {
        command = "oxc.fixAll",
        arguments = {
          {
            uri = vim.uri_from_bufnr(0),
          },
        },
      }, nil, 0)
    end, { desc = "Apply fixes to current buffer using oxlint (--fix)" })
  end,
}
