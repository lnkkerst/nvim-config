local M = {}
local api = vim.api

-- Configuration & Icons
local icons = {
  git = "",
  lsp = "",
  error = "",
  warn = "",
  info = "",
  hint = "",
  modified = "[+]",
  readonly = "[-]",
  lock = "",
}

local modes = setmetatable({
  ["n"] = "NORMAL",
  ["no"] = "NORMAL",
  ["v"] = "VISUAL",
  ["V"] = "V-LINE",
  ["\22"] = "V-BLOCK",
  ["s"] = "SELECT",
  ["S"] = "S-LINE",
  ["\19"] = "S-BLOCK",
  ["i"] = "INSERT",
  ["ic"] = "INSERT",
  ["R"] = "REPLACE",
  ["Rv"] = "V-REPLACE",
  ["c"] = "COMMAND",
  ["cv"] = "EX",
  ["r"] = "...",
  ["rm"] = "MOAR",
  ["t"] = "TERMINAL",
  ["!"] = "SHELL",
}, {
  __index = function(_, k)
    return k:match("^[niRv]") and "NORMAL" or k
  end,
})

-- Highlight Group Management
local colors = {}
local function update_highlights()
  local ok, palette = pcall(require, "catppuccin.palettes")
  local ctp = ok and palette.get_palette("mocha")
    or {
      base = "#1e1e2e",
      text = "#cdd6f4",
      blue = "#89b4fa",
      green = "#a6e3a1",
      yellow = "#f9e2af",
      red = "#f38ba8",
      mauve = "#cba6f7",
      peach = "#fab387",
      teal = "#94e2d5",
      sky = "#89dceb",
      surface1 = "#45475a",
    }

  colors = {
    bg = ctp.base,
    fg = ctp.text,
    blue = ctp.blue,
    green = ctp.green,
    yellow = ctp.yellow,
    red = ctp.red,
    mauve = ctp.mauve,
    peach = ctp.peach,
    teal = ctp.teal,
    cyan = ctp.sky,
    gray = ctp.surface1,
  }

  local hls = {
    StlBg = { bg = colors.bg, fg = colors.fg },
    StlModeNormal = { fg = colors.bg, bg = colors.blue, bold = true },
    StlModeInsert = { fg = colors.bg, bg = colors.green, bold = true },
    StlModeVisual = { fg = colors.bg, bg = colors.mauve, bold = true },
    StlModeReplace = { fg = colors.bg, bg = colors.peach, bold = true },
    StlModeCommand = { fg = colors.bg, bg = colors.peach, bold = true },
    StlGitBranch = { fg = colors.blue, bg = colors.bg, bold = true },
    StlGitAdd = { fg = colors.green, bg = colors.bg },
    StlGitChange = { fg = colors.yellow, bg = colors.bg },
    StlGitDelete = { fg = colors.red, bg = colors.bg },
    StlDiagError = { fg = colors.red, bg = colors.bg },
    StlDiagWarn = { fg = colors.yellow, bg = colors.bg },
    StlDiagInfo = { fg = colors.blue, bg = colors.bg },
    StlDiagHint = { fg = colors.teal, bg = colors.bg },
    StlLsp = { fg = colors.green, bg = colors.bg, bold = true },
    StlFile = { fg = colors.fg, bg = colors.bg },
    StlFileIcon = { fg = colors.blue, bg = colors.bg },
    StlFileMod = { fg = colors.green, bg = colors.bg },
    StlFileRo = { fg = colors.red, bg = colors.bg },
    StlRuler = { fg = colors.bg, bg = colors.blue, bold = true },
  }

  for k, v in pairs(hls) do
    api.nvim_set_hl(0, k, v)
  end
end

-- Components
local stl = {}

function stl.mode()
  local m = vim.fn.mode()
  local label = modes[m]
  local hl = "StlModeNormal"

  if m:find("i") then
    hl = "StlModeInsert"
  elseif m:find("[vV\22]") then
    hl = "StlModeVisual"
  elseif m:find("R") then
    hl = "StlModeReplace"
  elseif m:find("[ct]") then
    hl = "StlModeCommand"
  end

  return string.format("%%#%s# %s %%#StlBg#", hl, label)
end

function stl.git()
  local signs = vim.b.gitsigns_status_dict
  if not signs or not signs.head or signs.head == "" then
    return ""
  end

  local branch = string.format("%%#StlGitBranch#%s %s", icons.git, signs.head)
  local diff = {}

  if (signs.added or 0) > 0 then
    table.insert(diff, string.format("%%#StlGitAdd#+%s", signs.added))
  end
  if (signs.changed or 0) > 0 then
    table.insert(diff, string.format("%%#StlGitChange#~%s", signs.changed))
  end
  if (signs.removed or 0) > 0 then
    table.insert(diff, string.format("%%#StlGitDelete#-%s", signs.removed))
  end

  return #diff > 0 and string.format("%s %%#StlFile#(%s%%#StlFile#)", branch, table.concat(diff, "")) or branch
end

local function get_diag_counts()
  if vim.diagnostic.count then
    local d = vim.diagnostic.count(0)

    return {
      error = d[vim.diagnostic.severity.ERROR] or 0,
      warn = d[vim.diagnostic.severity.WARN] or 0,
      info = d[vim.diagnostic.severity.INFO] or 0,
      hint = d[vim.diagnostic.severity.HINT] or 0,
    }
  end

  local c = { error = 0, warn = 0, info = 0, hint = 0 }

  for _, d in ipairs(vim.diagnostic.get(0)) do
    if d.severity == vim.diagnostic.severity.ERROR then
      c.error = c.error + 1
    elseif d.severity == vim.diagnostic.severity.WARN then
      c.warn = c.warn + 1
    elseif d.severity == vim.diagnostic.severity.INFO then
      c.info = c.info + 1
    elseif d.severity == vim.diagnostic.severity.HINT then
      c.hint = c.hint + 1
    end
  end

  return c
end

function stl.diagnostics()
  local c = get_diag_counts()

  local parts = {}

  if c.error > 0 then
    table.insert(parts, string.format("%%#StlDiagError#%s%d", icons.error, c.error))
  end
  if c.warn > 0 then
    table.insert(parts, string.format("%%#StlDiagWarn#%s%d", icons.warn, c.warn))
  end
  if c.info > 0 then
    table.insert(parts, string.format("%%#StlDiagInfo#%s%d", icons.info, c.info))
  end
  if c.hint > 0 then
    table.insert(parts, string.format("%%#StlDiagHint#%s%d", icons.hint, c.hint))
  end
  return table.concat(parts, " ")
end

function stl.lsp()
  local clients = vim.lsp.get_clients({ bufnr = 0 })
  if #clients == 0 then
    return ""
  end

  local names = {}
  for _, c in ipairs(clients) do
    table.insert(names, c.name)
  end
  local text = string.format("%s [%s]", icons.lsp, table.concat(names, " "))

  return string.format("%%#StlLsp#%s", #text > 40 and (icons.lsp .. " [LSP]") or text)
end

function stl.file()
  local fname = vim.fn.expand("%:t")
  if fname == "" then
    return "[No Name]"
  end

  local ficon, hl = "", "StlFileIcon"
  local ok, devicons = pcall(require, "nvim-web-devicons")
  if ok then
    local icon, color = devicons.get_icon_color(fname, vim.fn.expand("%:e"), { default = true })
    if icon then
      hl = "StlFileIconDynamic"
      api.nvim_set_hl(0, hl, { fg = color, bg = colors.bg })
      ficon = icon .. " "
    end
  end

  local mod = vim.bo.modified and string.format("%%#StlFileMod#%s", icons.modified) or ""
  local ro = (not vim.bo.modifiable or vim.bo.readonly) and string.format("%%#StlFileRo#%s", icons.readonly) or ""

  return string.format("%%#%s#%s%%#StlFile#%s%s%s", hl, ficon, fname, mod, ro)
end

function stl.info()
  if vim.bo.filetype == "" then
    return ""
  end
  return string.format(
    "%%#StlFile#%s %s %s",
    vim.bo.filetype,
    vim.bo.fenc ~= "" and vim.bo.fenc or vim.o.enc,
    vim.bo.fileformat
  )
end

function stl.ruler()
  return string.format("%%#StlRuler# %s %%#StlBg#", "%l/%L:%c %P")
end

-- Renderers
function M.render_active()
  local left = { stl.mode() }
  local git, diag, lsp = stl.git(), stl.diagnostics(), stl.lsp()

  if git ~= "" then
    table.insert(left, " " .. git)
  end
  if diag ~= "" then
    table.insert(left, " " .. diag)
  end
  if lsp ~= "" then
    table.insert(left, " " .. lsp)
  end

  local right = { "%S ", stl.file() } -- ShowCmd
  local info = stl.info()
  if info ~= "" then
    table.insert(right, " " .. info)
  end
  table.insert(right, " " .. stl.ruler())

  return table.concat(left, "") .. "%=" .. table.concat(right, "")
end

function M.render_inactive()
  return "%#StlBg# %t %m %r %= %y "
end

function M.setup()
  update_highlights()
  api.nvim_create_autocmd("ColorScheme", { callback = update_highlights })

  local grp = api.nvim_create_augroup("StatusLine", { clear = true })
  api.nvim_create_autocmd({ "WinEnter", "BufEnter" }, {
    group = grp,
    callback = function()
      vim.opt_local.statusline = "%!v:lua.require'statusline'.render_active()"
    end,
  })
  api.nvim_create_autocmd({ "WinLeave", "BufLeave" }, {
    group = grp,
    callback = function()
      vim.opt_local.statusline = "%!v:lua.require'statusline'.render_inactive()"
    end,
  })

  vim.opt.statusline = "%!v:lua.require'statusline'.render_active()"
end

return M
