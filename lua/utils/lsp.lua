local M = {}

function M.init() end

M.nvim_eleven = vim.fn.has("nvim-0.11") == 1
M.iswin = vim.uv.os_uname().version:match("Windows")

function M.validate_bufnr(bufnr)
  if M.nvim_eleven then
    vim.validate("bufnr", bufnr, "number")
  end
  return bufnr == 0 and vim.api.nvim_get_current_buf() or bufnr
end

function M.insert_package_json(config_files, field, fname)
  local conditions = require("utils.conditions")
  if conditions.package_json_has_field(field, fname) then
    config_files[#config_files + 1] = "package.json"
  end
  return config_files
end

return M
