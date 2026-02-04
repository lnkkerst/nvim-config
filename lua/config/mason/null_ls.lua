local M = {}

local null_ls_to_pkg = {
  ["cmake_lint"] = "cmakelint",
  ["cmake_format"] = "cmakelang",
  ["eslint_d"] = "eslint_d",
  ["goimports_reviser"] = "goimports_reviser",
  ["phpcsfixer"] = "php-cs-fixer",
  ["verible_verilog_format"] = "verible",
  ["lua_format"] = "luaformatter",
  ["ansiblelint"] = "ansible-lint",
  ["deno_fmt"] = "deno",
  ["ruff_format"] = "ruff",
  ["xmlformat"] = "xmlformatter",

  ["fish_indent"] = false,
  ["fish"] = false,
  ["nginx_beautifier"] = false,
  ["dart_format"] = false,
}

function M.get_null_ls_pkgs()
  local _ = require("mason-core.functional")
  local builtins = require("null-ls.builtins")

  local pkgs = {}
  pkgs = vim.list_extend(pkgs, vim.tbl_keys(builtins.diagnostics))
  pkgs = vim.list_extend(pkgs, vim.tbl_keys(builtins.formatting))
  pkgs = vim.list_extend(pkgs, vim.tbl_keys(builtins.code_actions))
  pkgs = vim.list_extend(pkgs, vim.tbl_keys(builtins.completion))
  pkgs = vim.list_extend(pkgs, vim.tbl_keys(builtins.hover))
  pkgs = _.uniq_by(_.identity, pkgs)
  pkgs = vim.tbl_map(function(source)
    local mapped_name = null_ls_to_pkg[source]
    if mapped_name == false then
      return
    end
    local name = mapped_name or source:gsub("%_", "-")
    return name
  end, pkgs)
  pkgs = vim.tbl_filter(function(source)
    return source ~= nil
  end, pkgs)

  return pkgs
end

return M
