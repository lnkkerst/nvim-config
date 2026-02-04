local M = {}

function M.get_all_pkgs()
  local pkgs = {}
  pkgs = vim.list_extend(pkgs, require("config.mason.lsp").get_lsp_pkgs())
  pkgs = vim.list_extend(pkgs, require("config.mason.null_ls").get_null_ls_pkgs())
  pkgs = vim.list_extend(pkgs, require("config.mason.dap").get_dap_pkgs())
  return pkgs
end

function M.init()
  vim.api.nvim_create_user_command("MasonInstallAll", function()
    local pkgs = M.get_all_pkgs()
    for _, pkg_name in ipairs(pkgs) do
      local ok, pkg = pcall(require("mason-registry").get_package, pkg_name)
      if not ok then
        vim.notify("Failed to get package: " .. pkg_name, vim.log.levels.WARN)
      else
        if not pkg:is_installed() and not pkg:is_installing() then
          pkg:install()
        end
      end
    end
  end, {})
end

return M
