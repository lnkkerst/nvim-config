local M = {}
local api = vim.api
local devicons

-- Constants & Icons
local icons = {
  git = "",
  error = "",
  warn = "",
  info = "",
  hint = "",
  modified = "[+]",
  readonly = "[-]",
  lock = "",
}

-- Mode Map: maps mode string to { Label, HighlightGroup }
local mode_map = setmetatable({
  ["n"] = { "NORMAL", "StlModeNormal" },
  ["no"] = { "NORMAL", "StlModeNormal" },
  ["v"] = { "VISUAL", "StlModeVisual" },
  ["V"] = { "V-LINE", "StlModeVisual" },
  ["\22"] = { "V-BLOCK", "StlModeVisual" },
  ["s"] = { "SELECT", "StlModeVisual" },
  ["S"] = { "S-LINE", "StlModeVisual" },
  ["\19"] = { "S-BLOCK", "StlModeVisual" },
  ["i"] = { "INSERT", "StlModeInsert" },
  ["ic"] = { "INSERT", "StlModeInsert" },
  ["R"] = { "REPLACE", "StlModeReplace" },
  ["Rv"] = { "V-REPLACE", "StlModeReplace" },
  ["c"] = { "COMMAND", "StlModeCommand" },
  ["cv"] = { "EX", "StlModeCommand" },
  ["t"] = { "TERMINAL", "StlModeCommand" },
}, {
  __index = function(_, k)
    return { k, "StlModeNormal" }
  end,
})

-- State
local colors = {}
local icon_hl_cache = {}
local lsp_progress_text = ""

-- Updates
local function update_highlights()
  icon_hl_cache = {} -- Clear cache
  local ok, palette = pcall(require, "catppuccin.palettes")
  local ctp = ok and palette.get_palette()
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

  colors = { bg = ctp.base, fg = ctp.text }
  local hls = {
    StlBg = { bg = ctp.base, fg = ctp.text },
    StlModeNormal = { fg = ctp.base, bg = ctp.blue, bold = true },
    StlModeInsert = { fg = ctp.base, bg = ctp.green, bold = true },
    StlModeVisual = { fg = ctp.base, bg = ctp.mauve, bold = true },
    StlModeReplace = { fg = ctp.base, bg = ctp.peach, bold = true },
    StlModeCommand = { fg = ctp.base, bg = ctp.peach, bold = true },
    StlGitBranch = { fg = ctp.blue, bg = ctp.base, bold = true },
    StlGitAdd = { fg = ctp.green, bg = ctp.base },
    StlGitChange = { fg = ctp.yellow, bg = ctp.base },
    StlGitDelete = { fg = ctp.red, bg = ctp.base },
    StlDiagError = { fg = ctp.red, bg = ctp.base },
    StlDiagWarn = { fg = ctp.yellow, bg = ctp.base },
    StlLspProgress = { fg = ctp.yellow, bg = ctp.base },
    StlFileIcon = { fg = ctp.blue, bg = ctp.base },
    StlFileMod = { fg = ctp.green, bg = ctp.base },
    StlFileRo = { fg = ctp.red, bg = ctp.base },
    StlRuler = { fg = ctp.base, bg = ctp.blue, bold = true },
  }

  for k, v in pairs(hls) do
    api.nvim_set_hl(0, k, v)
  end
end

function M.update_diagnostics(bufnr)
  if not api.nvim_buf_is_valid(bufnr) then
    return
  end
  local d = vim.diagnostic.count(bufnr)
  local c = {
    error = d[vim.diagnostic.severity.ERROR] or 0,
    warn = d[vim.diagnostic.severity.WARN] or 0,
    info = d[vim.diagnostic.severity.INFO] or 0,
    hint = d[vim.diagnostic.severity.HINT] or 0,
  }

  if c.error + c.warn + c.info + c.hint == 0 then
    vim.b[bufnr].stl_diag = ""
    return
  end

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
  vim.b[bufnr].stl_diag = table.concat(parts, " ")
end

-- Components
local stl = {}

function stl.mode()
  local m = mode_map[vim.fn.mode()]
  return string.format("%%#%s# %s %%#StlBg#", m[2], m[1])
end

function stl.git()
  local s = vim.b.gitsigns_status_dict
  if not s or not s.head or s.head == "" then
    return ""
  end

  local diff = ""
  if (s.added or 0) > 0 then
    diff = diff .. string.format("%%#StlGitAdd#+%s", s.added)
  end
  if (s.changed or 0) > 0 then
    diff = diff .. string.format("%%#StlGitChange#~%s", s.changed)
  end
  if (s.removed or 0) > 0 then
    diff = diff .. string.format("%%#StlGitDelete#-%s", s.removed)
  end

  local branch = string.format("%%#StlGitBranch#%s %s", icons.git, s.head)
  return diff ~= "" and string.format("%s %%#StlFile#(%s%%#StlFile#)", branch, diff) or branch
end

function stl.diagnostics()
  return vim.b.stl_diag or ""
end

function stl.lsp_progress()
  if lsp_progress_text == "" then
    return ""
  end
  return string.format("%%#StlLspProgress#%s", lsp_progress_text)
end

function stl.file()
  local fname = vim.fn.expand("%:t")
  if fname == "" then
    return "[No Name]"
  end

  local ficon, hl = "", "StlFileIcon"

  -- Lazy load devicons
  if not devicons then
    local ok, mod = pcall(require, "nvim-web-devicons")
    if ok then
      devicons = mod
    end
  end

  if devicons then
    local icon, color = devicons.get_icon_color(fname, vim.fn.expand("%:e"), { default = true })
    if icon then
      local hl_name = "StlFileIcon_" .. color:gsub("#", "")
      if not icon_hl_cache[hl_name] then
        api.nvim_set_hl(0, hl_name, { fg = color, bg = colors.bg })
        icon_hl_cache[hl_name] = true
      end
      ficon, hl = icon .. " ", hl_name
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
  return string.format("%%#StlFile#%s %s", vim.bo.filetype, (vim.bo.fenc ~= "" and vim.bo.fenc or vim.o.enc))
end

function stl.ruler()
  return " %#StlRuler# %l/%L:%c %P "
end

-- Renderers
function M.render_active()
  if vim.bo.filetype == "oil" then
    local dir = vim.fn.expand("%:p"):gsub("^oil://", "")
    return string.format("%s %%#StlFile#  %s", stl.mode(), vim.fn.fnamemodify(dir, ":~"))
  end

  if vim.bo.filetype == "qf" then
    local is_loc = vim.fn.getloclist(0, { filewinid = 0 }).filewinid ~= 0
    local type = is_loc and "Location List" or "Quickfix List"
    local title = vim.w.quickfix_title or ""
    return string.format("%s %%#StlFile# %s: %s", stl.mode(), type, title)
  end

  return table.concat({
    stl.mode(),
    " ",
    stl.git(),
    " ",
    stl.diagnostics(),
    " ",
    stl.lsp_progress(),
    "%=",
    "%S ",
    stl.file(),
    " ",
    stl.info(),
    stl.ruler(),
  })
end

function M.render_inactive()
  return "%#StlBg# %t %m %r %= %y "
end

function M.setup()
  update_highlights()
  api.nvim_create_autocmd("ColorScheme", { callback = update_highlights })

  local grp = api.nvim_create_augroup("StatusLine", { clear = true })

  -- Event-driven updates
  api.nvim_create_autocmd("DiagnosticChanged", {
    group = grp,
    callback = function(a)
      M.update_diagnostics(a.buf)
    end,
  })

  ---@type uv.uv_timer_t?
  local lsp_timer = nil
  api.nvim_create_autocmd("LspProgress", {
    group = grp,
    callback = function(ev)
      if lsp_timer and lsp_timer:is_active() then
        lsp_timer:stop()
        lsp_timer:close()
        lsp_timer = nil
      end
      local spinner = { "⠋", "⠙", "⠹", "⠸", "⠼", "⠴", "⠦", "⠧", "⠇", "⠏" }
      local done = ev.data.params.value.kind == "end"
      local icon = done and " " or spinner[math.floor(vim.uv.hrtime() / (1e6 * 80)) % #spinner + 1]
      local text = done and "Done" or vim.lsp.status()
      if #text > 39 then
        text = text:sub(1, 36) .. "..."
      end
      lsp_progress_text = icon .. text
      vim.cmd.redrawstatus()

      if done then
        lsp_timer = vim.defer_fn(function()
          lsp_progress_text = ""
          vim.cmd.redrawstatus()
        end, 3000)
      end
    end,
  })

  -- Statusline switching
  local set_active = "setlocal statusline=%!v:lua.require'statusline'.render_active()"
  local set_inactive = "setlocal statusline=%!v:lua.require'statusline'.render_inactive()"

  api.nvim_create_autocmd({ "WinEnter", "BufEnter" }, { group = grp, command = set_active })
  api.nvim_create_autocmd({ "WinLeave", "BufLeave" }, { group = grp, command = set_inactive })

  -- Initial state
  vim.opt.statusline = "%!v:lua.require'statusline'.render_active()"
end

return M
