local M = {}

local stl = {}

-- Icons
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

-- Mode map
local modes = {
  ["n"] = "NORMAL",
  ["no"] = "NORMAL",
  ["nov"] = "NORMAL",
  ["noV"] = "NORMAL",
  ["no\22"] = "NORMAL",
  ["niI"] = "NORMAL",
  ["niR"] = "NORMAL",
  ["niV"] = "NORMAL",
  ["nt"] = "NORMAL",
  ["v"] = "VISUAL",
  ["vs"] = "VISUAL",
  ["V"] = "VISUAL LINE",
  ["Vs"] = "VISUAL LINE",
  ["\22"] = "VISUAL BLOCK",
  ["\22s"] = "VISUAL BLOCK",
  ["s"] = "SELECT",
  ["S"] = "SELECT LINE",
  ["\19"] = "SELECT BLOCK",
  ["i"] = "INSERT",
  ["ic"] = "INSERT",
  ["ix"] = "INSERT",
  ["R"] = "REPLACE",
  ["Rc"] = "REPLACE",
  ["Rx"] = "REPLACE",
  ["Rv"] = "VISUAL REPLACE",
  ["Rvc"] = "VISUAL REPLACE",
  ["Rvx"] = "VISUAL REPLACE",
  ["c"] = "COMMAND",
  ["cv"] = "EX",
  ["r"] = "...",
  ["rm"] = "MOAR",
  ["r?"] = "CONFIRM",
  ["!"] = "SHELL",
  ["t"] = "TERMINAL",
}

-- Colors (Cache)
local colors = {}
local function update_colors()
  local ok, palette = pcall(require, "catppuccin.palettes")
  if ok then
    local ctp = palette.get_palette("mocha")
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
  else
    -- Fallback
    colors = {
      bg = "#1e1e2e",
      fg = "#cdd6f4",
      blue = "#89b4fa",
      green = "#a6e3a1",
      yellow = "#f9e2af",
      red = "#f38ba8",
      mauve = "#cba6f7",
      peach = "#fab387",
      teal = "#94e2d5",
      cyan = "#89dceb",
      gray = "#45475a",
    }
  end

  -- Setup highlights
  local function set_hl(name, opts)
    vim.api.nvim_set_hl(0, name, opts)
  end

  set_hl("StlBg", { bg = colors.bg, fg = colors.fg })

  -- Mode Highlights
  set_hl("StlModeNormal", { fg = colors.bg, bg = colors.blue, bold = true })
  set_hl("StlModeInsert", { fg = colors.bg, bg = colors.green, bold = true })
  set_hl("StlModeVisual", { fg = colors.bg, bg = colors.mauve, bold = true })
  set_hl("StlModeReplace", { fg = colors.bg, bg = colors.peach, bold = true })
  set_hl("StlModeCommand", { fg = colors.bg, bg = colors.peach, bold = true })

  set_hl("StlGitBranch", { fg = colors.blue, bg = colors.bg, bold = true })
  set_hl("StlGitAdd", { fg = colors.green, bg = colors.bg })
  set_hl("StlGitChange", { fg = colors.yellow, bg = colors.bg })
  set_hl("StlGitDelete", { fg = colors.red, bg = colors.bg })

  set_hl("StlDiagError", { fg = colors.red, bg = colors.bg })
  set_hl("StlDiagWarn", { fg = colors.yellow, bg = colors.bg })
  set_hl("StlDiagInfo", { fg = colors.blue, bg = colors.bg })
  set_hl("StlDiagHint", { fg = colors.teal, bg = colors.bg })

  set_hl("StlLsp", { fg = colors.green, bg = colors.bg, bold = true })

  set_hl("StlFile", { fg = colors.fg, bg = colors.bg })
  set_hl("StlFileIcon", { fg = colors.blue, bg = colors.bg })
  set_hl("StlFileModified", { fg = colors.green, bg = colors.bg })
  set_hl("StlFileReadonly", { fg = colors.red, bg = colors.bg })

  set_hl("StlRuler", { fg = colors.bg, bg = colors.blue, bold = true })
  set_hl("StlScrollBar", { fg = colors.green, bg = colors.bg })
end

-- Component: Mode
function stl.mode()
  local m = vim.fn.mode()
  local mode_str = modes[m] or "NORMAL"

  local hl_group = "StlModeNormal"

  if m:find("i") then
    hl_group = "StlModeInsert"
  elseif m:find("v") or m:find("V") or m:find("\22") then
    hl_group = "StlModeVisual"
  elseif m:find("R") then
    hl_group = "StlModeReplace"
  elseif m:find("c") or m:find("t") then
    hl_group = "StlModeCommand"
  end

  return string.format("%%#%s# %s %%#StlBg#", hl_group, mode_str)
end

-- Component: Git
function stl.git()
  if not vim.b.gitsigns_status_dict then
    return ""
  end
  local signs = vim.b.gitsigns_status_dict
  local head = signs.head
  if not head or head == "" then
    return ""
  end

  local branch = string.format("%%#StlGitBranch#%s %s", icons.git, head)
  local diff = ""

  local added = signs.added
  local changed = signs.changed
  local removed = signs.removed

  if (added and added > 0) or (changed and changed > 0) or (removed and removed > 0) then
    if added and added > 0 then
      diff = diff .. string.format("%%#StlGitAdd#+%s", added)
    end
    if changed and changed > 0 then
      diff = diff .. string.format("%%#StlGitChange#~%s", changed)
    end
    if removed and removed > 0 then
      diff = diff .. string.format("%%#StlGitDelete#-%s", removed)
    end
  end

  if diff ~= "" then
    return branch .. " %#StlFile#(" .. diff .. "%#StlFile#)"
  end
  return branch
end

-- Component: Diagnostics
function stl.diagnostics()
  local count = {
    error = #vim.diagnostic.get(0, { severity = vim.diagnostic.severity.ERROR }),
    warn = #vim.diagnostic.get(0, { severity = vim.diagnostic.severity.WARN }),
    info = #vim.diagnostic.get(0, { severity = vim.diagnostic.severity.INFO }),
    hint = #vim.diagnostic.get(0, { severity = vim.diagnostic.severity.HINT }),
  }

  local parts = {}
  if count.error > 0 then
    table.insert(parts, string.format("%%#StlDiagError#%s%d", icons.error, count.error))
  end
  if count.warn > 0 then
    table.insert(parts, string.format("%%#StlDiagWarn#%s%d", icons.warn, count.warn))
  end
  if count.info > 0 then
    table.insert(parts, string.format("%%#StlDiagInfo#%s%d", icons.info, count.info))
  end
  if count.hint > 0 then
    table.insert(parts, string.format("%%#StlDiagHint#%s%d", icons.hint, count.hint))
  end

  if #parts > 0 then
    return table.concat(parts, " ")
  end
  return ""
end

-- Component: LSP
function stl.lsp()
  local clients = vim.lsp.get_clients({ bufnr = 0 })
  if #clients == 0 then
    return ""
  end

  local names = {}
  for _, client in ipairs(clients) do
    table.insert(names, client.name)
  end
  local names_str = table.concat(names, " ")
  local text = string.format("%s [%s]", icons.lsp, names_str)

  -- Truncate if too long (simple heuristic)
  if #text > 40 then
    text = string.format("%s [LSP]", icons.lsp)
  end

  return "%#StlLsp#" .. text
end

-- Component: File
function stl.file()
  local fname = vim.fn.expand("%:t")
  if fname == "" then
    return "[No Name]"
  end

  local ficon = ""

  local ok, devicons = pcall(require, "nvim-web-devicons")
  if ok then
    local ext = vim.fn.expand("%:e")
    local icon, color = devicons.get_icon_color(fname, ext, { default = true })
    if icon then
      vim.api.nvim_set_hl(0, "StlFileIconDynamic", { fg = color, bg = colors.bg })
      ficon = string.format("%%#StlFileIconDynamic#%s ", icon)
    end
  end

  local modified = vim.bo.modified and string.format("%%#StlFileModified#%s", icons.modified) or ""
  local readonly = (not vim.bo.modifiable or vim.bo.readonly) and string.format("%%#StlFileReadonly#%s", icons.readonly)
    or ""

  return string.format("%s%%#StlFile#%s %s%s", ficon, fname, modified, readonly)
end

-- Component: File Info (Type, Encoding, Format)
function stl.file_info()
  local ft = vim.bo.filetype
  if ft == "" then
    return ""
  end
  local enc = vim.bo.fenc ~= "" and vim.bo.fenc or vim.o.enc
  local fmt = vim.bo.fileformat
  return string.format("%%#StlFile#%s %s %s", ft, enc, fmt)
end

-- Component: Ruler
function stl.ruler()
  -- %l = line, %L = total lines, %c = column, %P = percent
  local ruler_text = "%l/%L:%c %P"
  local hl_group = "StlRuler"
  return string.format("%%#%s# %s %%#StlBg#", hl_group, ruler_text)
end

-- Build Active Statusline
function M.render_active()
  local left = {}
  table.insert(left, stl.mode())
  local git = stl.git()
  if git ~= "" then
    table.insert(left, "  " .. git)
  end
  local diag = stl.diagnostics()
  if diag ~= "" then
    table.insert(left, " " .. diag)
  end
  local lsp = stl.lsp()
  if lsp ~= "" then
    table.insert(left, " " .. lsp)
  end

  local right = {}
  -- ShowCmd (%S) usually has its own spacing or is empty
  table.insert(right, "%S")
  table.insert(right, stl.file())
  local info = stl.file_info()
  if info ~= "" then
    table.insert(right, "  " .. info)
  end
  table.insert(right, "  " .. stl.ruler())

  return string.format("%s%%=%s", table.concat(left, ""), table.concat(right, ""))
end

-- Build Inactive Statusline
function M.render_inactive()
  return "%#StlBg# %t %m %r %= %y "
end

function M.setup()
  update_colors()

  -- Update colors on theme change
  vim.api.nvim_create_autocmd("ColorScheme", {
    callback = update_colors,
  })

  vim.api.nvim_create_autocmd({ "WinEnter", "BufEnter" }, {
    callback = function()
      vim.opt_local.statusline = "%!v:lua.require'statusline'.render_active()"
    end,
  })

  vim.api.nvim_create_autocmd({ "WinLeave", "BufLeave" }, {
    callback = function()
      vim.opt_local.statusline = "%!v:lua.require'statusline'.render_inactive()"
    end,
  })

  -- Set global default
  vim.opt.statusline = "%!v:lua.require'statusline'.render_active()"
end

return M
