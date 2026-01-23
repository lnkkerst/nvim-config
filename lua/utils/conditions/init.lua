local M = {}

M.has_prettier = function()
  local utils = require("null-ls.utils").make_conditional_utils()
  return utils.root_has_file_matches(".*prettierrc.*")
end

M.has_biome = function()
  local utils = require("null-ls.utils").make_conditional_utils()
  return utils.root_has_file_matches("biome.json")
end

M.has_commitlint = function()
  local utils = require("null-ls.utils").make_conditional_utils()
  return utils.root_has_file_matches("\\.?commitlint.*")
end

---@param field string
---@param fname string?
M.package_json_has_field = function(field, fname)
  local buf_name = fname or vim.api.nvim_buf_get_name(0)
  local path = vim.fn.fnamemodify(buf_name, ":h")
  local package_json = vim.fs.find("package.json", { path = path, upward = true })[1]
  if not package_json then
    return false
  end

  for line in io.lines(package_json) do
    if line:find(field, 1, true) then
      return true
    end
  end
  return false
end

M.is_ssh_session = function()
  return vim.env.SSH_CLIENT ~= nil or vim.env.SSH_TTY ~= nil
end

return M
