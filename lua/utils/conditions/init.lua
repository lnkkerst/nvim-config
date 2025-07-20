local M = {}

M.use_prettier = function()
  local utils = require("null-ls.utils").make_conditional_utils()
  return utils.root_has_file_matches(".*prettierrc.*") or not M.use_biome()
end

M.use_biome = function()
  local utils = require("null-ls.utils").make_conditional_utils()
  return utils.root_has_file_matches("biome.json")
end

M.use_commitlint = function()
  local utils = require("null-ls.utils").make_conditional_utils()
  return utils.root_has_file_matches("\\.?commitlint.*")
end

---@param field string
---@param fname string?
M.package_json_has_field = function(field, fname)
  local path = vim.fn.fnamemodify(fname or vim.api.nvim_buf_get_name(0), ":h")
  local root_with_package = vim.fs.dirname(vim.fs.find("package.json", { path = path, upward = true })[1])

  if root_with_package then
    local path_sep = M.iswin and "\\" or "/"
    for line in io.lines(root_with_package .. path_sep .. "package.json") do
      if line:find(field) then
        return true
      end
    end
  end
  return false
end

M.is_ssh_session = function()
  return vim.env.SSH_CLIENT ~= nil or vim.env.SSH_TTY ~= nil
end

return M
