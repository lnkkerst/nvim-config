local inlayHints = {
  includeInlayParameterNameHints = "all",
  includeInlayParameterNameHintsWhenArgumentMatchesName = false,
  includeInlayFunctionParameterTypeHints = true,
  includeInlayVariableTypeHints = true,
  includeInlayVariableTypeHintsWhenTypeMatchesName = false,
  includeInlayPropertyDeclarationTypeHints = true,
  includeInlayFunctionLikeReturnTypeHints = true,
  includeInlayEnumMemberValueHints = true,
}

local language_common_settings = {
  inlayHints = inlayHints,
  implementationsCodeLens = {
    enabled = true,
  },
  referencesCodeLens = {
    enabled = true,
  },
  implicitProjectConfiguration = {
    checkJs = true,
  },
}

---@type vim.lsp.Config
return {
  filetypes = {
    "javascript",
    "javascriptreact",
    "javascript.jsx",
    "typescript",
    "typescriptreact",
    "typescript.tsx",
    "vue",
  },
  root_markers = { "tsconfig.json", "jsconfig.json", "package.json", ".git", "pnpm-workspace.yaml" },
  init_options = {
    hostInfo = "neovim",
    plugins = {
      {
        name = "@vue/typescript-plugin",
        location = "/usr/lib/node_modules/@vue/typescript-plugin",
        languages = {
          "vue",
        },
        configNamespace = "typescript",
      },
    },
    tsserver = {
      path = "/usr/lib/node_modules/typescript/lib/tsserver.js",
    },
  },
  settings = {
    typescript = language_common_settings,
    javascript = language_common_settings,
  },
}
