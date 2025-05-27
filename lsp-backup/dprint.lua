local filetypes = {
  "javascript",
  "javascriptreact",
  "typescript",
  "typescriptreact",
  "json",
  "jsonc",
  "markdown",
  "python",
  "toml",
  "rust",
  "roslyn",
  "graphql",
}
local prettier_filetypes = {
  "javascript",
  "javascriptreact",
  "typescript",
  "typescriptreact",
  "vue",
  "css",
  "scss",
  "less",
  "html",
  "json",
  "jsonc",
  "yaml",
  "markdown",
  "markdown.mdx",
  "graphql",
  "handlebars",
}

return {
  cmd = { "dprint", "lsp" },
  filetypes = require("utils").merge_sets(filetypes, prettier_filetypes),
  root_markers = { "dprint.json", ".dprint.json", "dprint.jsonc", ".dprint.jsonc" },
  settings = {},
}
