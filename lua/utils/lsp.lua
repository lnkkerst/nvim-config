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
  local path = vim.fn.fnamemodify(fname, ":h")
  local root_with_package = vim.fs.dirname(vim.fs.find("package.json", { path = path, upward = true })[1])

  if root_with_package then
    -- only add package.json if it contains field parameter
    local path_sep = M.iswin and "\\" or "/"
    for line in io.lines(root_with_package .. path_sep .. "package.json") do
      if line:find(field) then
        config_files[#config_files + 1] = "package.json"
        break
      end
    end
  end
  return config_files
end

return M
