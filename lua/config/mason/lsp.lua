local utils = require("utils")
local M = {}

M.get_mason_map = utils.memo(function()
  ---@type table<string, string>
  local pkg2lsp = {}
  ---@type table<string, string>
  local lsp2pkg = {}

  local mason_specs = require("mason-registry").get_all_package_specs()

  for _, pkg_spec in ipairs(mason_specs) do
    local lspconfig = vim.tbl_get(pkg_spec, "neovim", "lspconfig")
    if lspconfig then
      pkg2lsp[pkg_spec.name] = lspconfig
      lsp2pkg[lspconfig] = pkg_spec.name
    end
  end

  return {
    pkg2lsp = pkg2lsp,
    lsp2pkg = lsp2pkg,
  }
end)

function M.get_lsp_name(pkg_name)
  local map = M.get_mason_map()
  return map.pkg2lsp[pkg_name]
end

function M.get_pkg_name(lsp_name)
  local map = M.get_mason_map()
  return map.lsp2pkg[lsp_name]
end

function M.get_lsp_pkgs()
  local pkgs = {}
  for server, config in pairs(require("lsp").servers) do
    if
      config.enabled ~= false
      and config.mason_install ~= false
      and vim.tbl_get(config, "mason", "install") ~= false
    then
      local pkg_name = M.get_pkg_name(server) or server
      table.insert(pkgs, pkg_name)
    end
  end
  return pkgs
end

return M
