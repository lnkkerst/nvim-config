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

return M
