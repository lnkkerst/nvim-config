local M = {}

local utils = require("heirline.utils")
local conditions = require("heirline.conditions")

function M.make_vi_mode()
  local ViMode = {
    static = {
      mode_names = {
        n = "N",
        no = "N?",
        nov = "N?",
        noV = "N?",
        ["no\22"] = "N?",
        niI = "Ni",
        niR = "Nr",
        niV = "Nv",
        nt = "Nt",
        v = "V",
        vs = "Vs",
        V = "V_",
        Vs = "Vs",
        ["\22"] = "^V",
        ["\22s"] = "^V",
        s = "S",
        S = "S_",
        ["\19"] = "^S",
        i = "I",
        ic = "Ic",
        ix = "Ix",
        R = "R",
        Rc = "Rc",
        Rx = "Rx",
        Rv = "Rv",
        Rvc = "Rv",
        Rvx = "Rv",
        c = "C",
        cv = "Ex",
        r = "...",
        rm = "M",
        ["r?"] = "?",
        ["!"] = "!",
        t = "T",
      },
    },

    init = function(self)
      self.mode = vim.fn.mode(1)
    end,
    update = {
      "ModeChanged",
      pattern = "*:*",
      callback = vim.schedule_wrap(function()
        vim.cmd("redrawstatus")
      end),
    },
    provider = function(self)
      return "" .. self.mode_names[self.mode]
    end,
  }
  return ViMode
end

function M.make_hydra_mode()
  local HydraMode = {
    condition = function()
      return vim.g.hydra_active
    end,
    provider = function()
      return vim.g.hydra_name
    end,
    update = {
      "User",
      pattern = { "HydraEnter", "HydraExit" },
    },
  }
  return HydraMode
end

function M.make_ruler()
  return {
    -- %l = current line number
    -- %L = number of lines in the buffer
    -- %c = column number
    -- %P = percentage through file of displayed window
    provider = "%l/%L:%c %P",
  }
end

function M.make_scrollbar()
  -- I take no credits for this! 🦁
  local ScrollBar = {
    static = {
      -- sbar = { "▁", "▂", "▃", "▄", "▅", "▆", "▇", "█" },
      -- Another variant, because the more choice the better.
      sbar = { "🭶", "🭷", "🭸", "🭹", "🭺", "🭻" },
    },
    provider = function(self)
      local curr_line = vim.api.nvim_win_get_cursor(0)[1]
      local lines = vim.api.nvim_buf_line_count(0)
      local i = math.floor((curr_line - 1) / lines * #self.sbar) + 1
      return string.rep(self.sbar[i], 2)
    end,
    hl = { fg = "primary" },
  }

  return ScrollBar
end

function M.make_file_flags()
  local FileFlags = {
    {
      condition = function()
        return vim.opt_local.modified:get()
      end,
      provider = "[+]",
      hl = { fg = "green" },
    },
    {
      condition = function()
        return (not vim.opt_local.modifiable:get()) or vim.opt_local.readonly:get()
      end,
      provider = "[-]",
      hl = { fg = "red" },
    },
  }
  return FileFlags
end

function M.make_file_icon()
  local FileIcon = {
    init = function(self)
      local filename = self.filename or vim.fn.expand("%:t")
      local extension = self.extension or vim.fn.fnamemodify(filename, ":e")
      self.icon, self.icon_color = require("nvim-web-devicons").get_icon_color(filename, extension, { default = true })
    end,
    provider = function(self)
      return self.icon and (self.icon .. " ")
    end,
    hl = function(self)
      return { fg = self.icon_color }
    end,
  }
  return FileIcon
end

---@class MakeFilenameOptions
---@field with_icon boolean?
---@field with_flags boolean?
---@field with_filename boolean?

---@param opts MakeFilenameOptions?
function M.make_filename(opts)
  opts = opts or {}
  local with_icon = opts.with_icon ~= false
  local with_flags = opts.with_flags ~= false
  local with_filename = opts.with_filename ~= false

  local FileNameBlock = {
    init = function(self)
      self.filename = vim.fn.expand("%:t")
      self.extension = vim.fn.expand("%:e")
      self.filetype = vim.opt_local.filetype:get()
    end,
  }

  local FileIcon = M.make_file_icon()

  local FileName = {
    provider = function(self)
      local filename = vim.fn.fnamemodify(self.filename, ":~:.")
      if filename == "" then
        return "[No Name]"
      end
      if not conditions.width_percent_below(#filename, 0.25) then
        filename = vim.fn.pathshorten(filename)
      end
      return filename
    end,
  }

  local FileFlags = M.make_file_flags()

  if with_icon then
    FileNameBlock = utils.insert(FileNameBlock, FileIcon)
  end

  if with_filename then
    FileNameBlock = utils.insert(FileNameBlock, FileName)
  end

  if with_flags then
    FileNameBlock = utils.insert(FileNameBlock, FileFlags)
  end

  FileNameBlock = utils.insert(FileNameBlock, {
    provider = "%<",
  })

  return FileNameBlock
end

function M.make_lsp()
  local LSPActive = {
    condition = conditions.lsp_attached,
    update = { "LspAttach", "LspDetach", "VimResized" },

    provider = function()
      local names = {}
      for _, server in pairs(vim.lsp.get_clients({ bufnr = 0 })) do
        table.insert(names, server.name)
      end

      local text = " [" .. table.concat(names, " ") .. "]"

      if not conditions.width_percent_below(#text, 0.39) then
        return " [LSP]"
      end

      return text
    end,
  }
  return LSPActive
end

function M.make_filetype()
  local FileType = {
    init = function(self)
      self.filetype = vim.bo.filetype
      self.icon, self.icon_color =
        require("nvim-web-devicons").get_icon_color_by_filetype(self.filetype, { default = true })
    end,
    {
      condition = function(self)
        return self.icon
      end,
      provider = function(self)
        return self.icon .. " "
      end,
      hl = function(self)
        return { fg = self.icon_color }
      end,
    },
    {
      provider = function(self)
        return self.filetype
      end,
    },
  }
  return FileType
end

function M.make_file_encoding()
  local FileEncoding = {
    condition = function(self)
      local enc = (vim.bo.fenc ~= "" and vim.bo.fenc) or vim.o.enc -- :h 'enc'
      self.enc = enc
      return enc ~= "utf-8"
    end,
    provider = function(self)
      return self.enc
    end,
  }
  return FileEncoding
end

function M.make_file_format()
  local FileFormat = {
    condition = function(self)
      local fileformat = vim.bo.fileformat
      self.fileformat = fileformat
      return fileformat ~= "unix"
    end,
    provider = function(self)
      return self.fileformat
    end,
  }
  return FileFormat
end

function M.make_filesize()
  local FileSize = {
    provider = function()
      -- stackoverflow, compute human readable file size
      local suffix = { "b", "k", "M", "G", "T", "P", "E" }
      local fsize = vim.fn.getfsize(vim.api.nvim_buf_get_name(0))
      fsize = (fsize < 0 and 0) or fsize
      if fsize < 1024 then
        return fsize .. suffix[1]
      end
      local i = math.floor((math.log(fsize) / math.log(1024)))
      return string.format("%.2g%s", fsize / math.pow(1024, i), suffix[i + 1])
    end,
  }
  return FileSize
end

function M.make_file_last_modified()
  local FileLastModified = {
    provider = function()
      local ftime = vim.fn.getftime(vim.api.nvim_buf_get_name(0))
      return (ftime > 0) and os.date("%c", ftime)
    end,
  }
  return FileLastModified
end

function M.make_lspsaga_breadcrumbs()
  local Breadcrumbs = {
    condition = function(self)
      if not conditions.lsp_attached() then
        return false
      end
      local ok, winbar = pcall(require, "lspsaga.symbol.winbar")
      if not ok then
        return false
      end
      local breadcrumbs = winbar.get_bar()
      if breadcrumbs == nil then
        return false
      end
      self.breadcrumbs = breadcrumbs
      return true
    end,
    provider = function(self)
      return self.breadcrumbs
    end,
    update = { "CursorMoved", "LspAttach", "LspDetach" },
  }
  return Breadcrumbs
end

function M.make_diagnostics()
  local Diagnostics = {

    condition = conditions.has_diagnostics,

    -- Fetching custom diagnostic icons
    static = {
      error_icon = vim.diagnostic.config()["signs"]["text"][vim.diagnostic.severity.ERROR],
      warn_icon = vim.diagnostic.config()["signs"]["text"][vim.diagnostic.severity.WARN],
      info_icon = vim.diagnostic.config()["signs"]["text"][vim.diagnostic.severity.INFO],
      hint_icon = vim.diagnostic.config()["signs"]["text"][vim.diagnostic.severity.HINT],
    },

    init = function(self)
      self.errors = #vim.diagnostic.get(0, { severity = vim.diagnostic.severity.ERROR })
      self.warnings = #vim.diagnostic.get(0, { severity = vim.diagnostic.severity.WARN })
      self.hints = #vim.diagnostic.get(0, { severity = vim.diagnostic.severity.HINT })
      self.info = #vim.diagnostic.get(0, { severity = vim.diagnostic.severity.INFO })
    end,

    update = { "DiagnosticChanged", "BufEnter" },

    {
      provider = function(self)
        -- 0 is just another output, we can decide to print it or not!
        return self.errors > 0 and (self.error_icon .. self.errors .. " ")
      end,
      hl = { fg = "error" },
    },
    {
      provider = function(self)
        return self.warnings > 0 and (self.warn_icon .. self.warnings .. " ")
      end,
      hl = { fg = "warning" },
    },
    {
      provider = function(self)
        return self.info > 0 and (self.info_icon .. self.info .. " ")
      end,
      hl = { fg = "info" },
    },
    {
      provider = function(self)
        return self.hints > 0 and (self.hint_icon .. self.hints)
      end,
      hl = { fg = "hint" },
    },
  }
  return Diagnostics
end

function M.make_git()
  local Git = {
    condition = conditions.is_git_repo,

    init = function(self)
      self.status_dict = vim.b.gitsigns_status_dict
      self.has_changes = self.status_dict.added ~= 0 or self.status_dict.removed ~= 0 or self.status_dict.changed ~= 0
    end,

    hl = { fg = "primary" },

    { -- git branch name
      provider = function(self)
        return " " .. self.status_dict.head
      end,
      hl = { bold = true },
    },
    {
      condition = function(self)
        return self.has_changes
      end,
      provider = "(",
    },
    {
      provider = function(self)
        local count = self.status_dict.added or 0
        return count > 0 and ("+" .. count)
      end,
      hl = { fg = "green" },
    },
    {
      provider = function(self)
        local count = self.status_dict.removed or 0
        return count > 0 and ("-" .. count)
      end,
      hl = { fg = "red" },
    },
    {
      provider = function(self)
        local count = self.status_dict.changed or 0
        return count > 0 and ("~" .. count)
      end,
      hl = { fg = "yellow" },
    },
    {
      condition = function(self)
        return self.has_changes
      end,
      provider = ")",
    },
  }
  return Git
end

function M.make_terminal_name()
  local TerminalName = {
    -- we could add a condition to check that buftype == 'terminal'
    -- or we could do that later (see #conditional-statuslines below)
    provider = function()
      local tname, _ = vim.api.nvim_buf_get_name(0):gsub(".*:", "")
      return " " .. tname
    end,
    hl = { fg = "blue", bold = true },
  }
  return TerminalName
end

function M.make_search_count()
  local SearchCount = {
    condition = function()
      return vim.v.hlsearch ~= 0 and vim.o.cmdheight == 0
    end,
    init = function(self)
      local ok, search = pcall(vim.fn.searchcount, { maxcount = 0, timeout = 500 })
      if ok and search.total then
        self.search = search
      end
    end,
    provider = function(self)
      local search = self.search
      return string.format("[%d/%d]", search.current, math.min(search.total, search.maxcount))
    end,
  }
  return SearchCount
end

function M.make_macro_rec()
  local MacroRec = {
    condition = function()
      return vim.fn.reg_recording() ~= "" and vim.o.cmdheight == 0
    end,
    provider = " ",
    hl = { fg = "orange", bold = true },
    utils.surround({ "[", "]" }, nil, {
      provider = function()
        return vim.fn.reg_recording()
      end,
      hl = { fg = "green", bold = true },
    }),
    update = {
      "RecordingEnter",
      "RecordingLeave",
    },
  }
  return MacroRec
end

function M.make_showcmd()
  local ShowCmd = {
    condition = function()
      return vim.o.cmdheight == 0
    end,
    provider = ":%3.5(%S%)",
  }
  return ShowCmd
end

---@param length number?
function M.make_space(length)
  length = length or 1
  local content = string.rep(" ", length)
  return {
    provider = content,
  }
end

---Surround component with separators and adjust coloring
---@param delimiters string[]
---@param color string|function|nil
---@param component table
---@return table
function M.linked_surround(delimiters, color, component)
  component = utils.clone(component)

  local surround_color = function(self)
    if type(color) == "function" then
      return color(self)
    else
      return color
    end
  end

  return {
    condition = function()
      if component.condition then
        return component:condition()
      end
      return true
    end,
    {
      provider = delimiters[1],
      hl = function(self)
        local s_color = surround_color(self)
        if s_color then
          return { fg = s_color }
        end
      end,
    },
    {
      hl = function(self)
        local s_color = surround_color(self)
        if s_color then
          return { bg = s_color }
        end
      end,
      component,
    },
    {
      provider = delimiters[2],
      hl = function(self)
        local s_color = surround_color(self)
        if s_color then
          return { fg = s_color }
        end
      end,
    },
  }
end

---@param component table
function M.invert_surround(component)
  local Space = M.make_space(1)
  return utils.surround({ "", "" }, function(self)
    return self:mode_color()
  end, { Space, { component, hl = { fg = "bg", bold = true, force = true } }, Space })
end

return M
