local M = {}

function M.setup()
  local ctp = require("catppuccin.palettes").get_palette("mocha")
  return vim.tbl_extend("force", ctp, {
    primary = ctp.blue,
    secondary = ctp.green,
    tertiary = ctp.teal,
    background = ctp.base,
    foreground = ctp.text,
    error = ctp.red,
    warning = ctp.yellow,
    info = ctp.blue,
    hint = ctp.teal,
    success = ctp.green,
  })
end

return M
