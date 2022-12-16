local null_ls = require("null-ls")

null_ls.setup({
  sources = {
    null_ls.builtins.formatting.stylua,
    null_ls.builtins.formatting.shfmt,
    null_ls.builtins.formatting.prettierd,
    null_ls.builtins.formatting.rustfmt,
    null_ls.builtins.formatting.taplo,
    -- null_ls.builtins.formatting.autopep8,
    null_ls.builtins.formatting.black,
    null_ls.builtins.formatting.fish_indent,
    null_ls.builtins.formatting.eslint_d,
    null_ls.builtins.formatting.markdownlint,
    null_ls.builtins.formatting.markdown_toc,
    null_ls.builtins.formatting.nginx_beautifier,
    null_ls.builtins.formatting.zigfmt,
    null_ls.builtins.diagnostics.fish,
    -- null_ls.builtins.diagnostics.markdownlint,
    null_ls.builtins.diagnostics.tidy,
    -- null_ls.builtins.diagnostics.stylelint,
    null_ls.builtins.diagnostics.checkmake,
    null_ls.builtins.diagnostics.commitlint,
  },
  on_attach = require("lsp-format").on_attach,
})
