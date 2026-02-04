local M = {}

M.nvim_dap_to_package = {
  ["python"] = "debugpy",
  ["cppdbg"] = "cpptools",
  ["delve"] = "delve",
  ["node2"] = "node-debug2-adapter",
  ["chrome"] = "chrome-debug-adapter",
  ["firefox"] = "firefox-debug-adapter",
  ["php"] = "php-debug-adapter",
  ["coreclr"] = "netcoredbg",
  ["js"] = "js-debug-adapter",
  ["codelldb"] = "codelldb",
  ["bash"] = "bash-debug-adapter",
  ["javadbg"] = "java-debug-adapter",
  ["javatest"] = "java-test",
  ["mock"] = "mockdebug",
  ["puppet"] = "puppet-editor-services",
  ["elixir"] = "elixir-ls",
  ["kotlin"] = "kotlin-debug-adapter",
  ["dart"] = "dart-debug-adapter",
  ["haskell"] = "haskell-debug-adapter",
  ["erlang"] = "erlang-debugger",

  ["go"] = false,
  ["gdb"] = false,
  ["lldb"] = false,
}

function M.get_dap_pkgs()
  local pkgs = vim.tbl_keys(require("dap").adapters)
  pkgs = vim.tbl_map(function(pkg)
    local mapped_name = M.nvim_dap_to_package[pkg]
    if mapped_name == false then
      return nil
    end
    return M.nvim_dap_to_package[pkg] or pkg
  end, pkgs)
  pkgs = vim.tbl_filter(function(pkg)
    return pkg ~= nil
  end, pkgs)
  return pkgs
end

return M
