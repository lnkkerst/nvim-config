local function make_vi_mode()
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

local function make_hydra_mode()
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

local function make_ruler()
  local Ruler = {
    -- %l = current line number
    -- %L = number of lines in the buffer
    -- %c = column number
    -- %P = percentage through file of displayed window
    provider = "%l/%L:%c %P",
  }

  return Ruler
end

local function make_scrollbar()
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

local function make_file_flags()
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

local function make_file_icon()
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
local function make_filename(opts)
  local utils = require("heirline.utils")
  local conditions = require("heirline.conditions")

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

  local FileIcon = make_file_icon()

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

  local FileFlags = make_file_flags()

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

local function make_lsp()
  local conditions = require("heirline.conditions")
  local LSPActive = {
    condition = conditions.lsp_attached,
    update = { "LspAttach", "LspDetach", "VimResized" },

    -- You can keep it simple,
    -- provider = " [LSP]",

    -- Or complicate things a bit and get the servers names
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

local function make_filetype()
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

local make_file_encoding = function()
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

local function make_file_format()
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

local function make_filesize()
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

local function make_file_last_modified()
  local FileLastModified = {
    provider = function()
      local ftime = vim.fn.getftime(vim.api.nvim_buf_get_name(0))
      return (ftime > 0) and os.date("%c", ftime)
    end,
  }
  return FileLastModified
end

local function make_lspsaga_breadcrumbs()
  local conditions = require("heirline.conditions")
  local Breadcrumbs = {
    condition = function(self)
      if not conditions.lsp_attached() then
        return false
      end
      local breadcrumbs = require("lspsaga.symbol.winbar").get_bar()
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

local function make_diagnostics()
  local conditions = require("heirline.conditions")

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

local function make_git()
  local conditions = require("heirline.conditions")
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
    -- You could handle delimiters, icons and counts similar to Diagnostics
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

local function make_terminal_name()
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

local function make_search_count()
  local SearchCount = {
    condition = function()
      return vim.v.hlsearch ~= 0 and vim.o.cmdheight == 0
    end,
    init = function(self)
      local ok, search = pcall(vim.fn.searchcount)
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

local function make_macro_rec()
  local utils = require("heirline.utils")

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

local function make_showcmd()
  local ShowCmd = {
    condition = function()
      return vim.o.cmdheight == 0
    end,
    provider = ":%3.5(%S%)",
  }
  return ShowCmd
end

---@param length number?
local function make_space(length)
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
local function linked_surround(delimiters, color, component)
  local utils = require("heirline.utils")
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

local function make_bufferline()
  local utils = require("heirline.utils")

  local TablineBufnr = {
    provider = function(self)
      return tostring(self.bufnr) .. ". "
    end,
    hl = "Comment",
  }

  -- we redefine the filename component, as we probably only want the tail and not the relative path
  local TablineFileName = {
    provider = function(self)
      -- self.filename will be defined later, just keep looking at the example!
      local filename = self.filename

      if filename == "" then
        return "[No Name]"
      end

      local tfilename = vim.fn.fnamemodify(filename, ":t")

      local buffers = vim.api.nvim_list_bufs()

      local count = 0
      for _, bufnr in ipairs(buffers) do
        if vim.api.nvim_buf_is_loaded(bufnr) and vim.api.nvim_buf_get_name(bufnr) ~= "" then
          local fullpath = vim.api.nvim_buf_get_name(bufnr)
          local cur_filename = vim.fn.fnamemodify(fullpath, ":t")
          if cur_filename == tfilename then
            count = count + 1
          end
        end
      end

      if count > 1 then
        local parent = vim.fn.fnamemodify(filename, ":p:h:t")
        return parent .. "/" .. tfilename
      else
        return tfilename
      end
    end,
    hl = function(self)
      return { bold = self.is_active or self.is_visible, italic = true }
    end,
  }

  -- this looks exactly like the FileFlags component that we saw in
  -- #crash-course-part-ii-filename-and-friends, but we are indexing the bufnr explicitly
  -- also, we are adding a nice icon for terminal buffers.
  local TablineFileFlags = {
    {
      condition = function(self)
        return vim.api.nvim_get_option_value("modified", { buf = self.bufnr })
      end,
      provider = "[+]",
      hl = { fg = "green" },
    },
    {
      condition = function(self)
        return not vim.api.nvim_get_option_value("modifiable", { buf = self.bufnr })
          or vim.api.nvim_get_option_value("readonly", { buf = self.bufnr })
      end,
      provider = function(self)
        if vim.api.nvim_get_option_value("buftype", { buf = self.bufnr }) == "terminal" then
          return "  "
        else
          return "[-]"
        end
      end,
      hl = { fg = "orange" },
    },
  }

  -- Here the filename block finally comes together
  local TablineFileNameBlock = {
    init = function(self)
      self.filename = vim.api.nvim_buf_get_name(self.bufnr)
    end,
    hl = function(self)
      if self.is_active then
        return "TabLineSel"
        -- why not?
        -- elseif not vim.api.nvim_buf_is_loaded(self.bufnr) then
        --     return { fg = "gray" }
      else
        return "TabLine"
      end
    end,
    on_click = {
      callback = function(_, minwid, _, button)
        if button == "m" then -- close on mouse middle click
          vim.schedule(function()
            vim.api.nvim_buf_delete(minwid, { force = false })
          end)
        else
          vim.api.nvim_win_set_buf(0, minwid)
        end
      end,
      minwid = function(self)
        return self.bufnr
      end,
      name = "heirline_tabline_buffer_callback",
    },
    TablineBufnr,
    make_file_icon(), -- turns out the version defined in #crash-course-part-ii-filename-and-friends can be reutilized as is here!
    TablineFileName,
    linked_surround({ " ", "" }, nil, TablineFileFlags),
  }

  -- a nice "x" button to close the buffer
  local TablineCloseButton = {
    condition = function(self)
      return not vim.api.nvim_get_option_value("modified", { buf = self.bufnr })
    end,
    { provider = " " },
    {
      provider = "",
      hl = { fg = "gray" },
      on_click = {
        callback = function(_, minwid)
          vim.schedule(function()
            vim.api.nvim_buf_delete(minwid, { force = false })
            vim.cmd.redrawtabline()
          end)
        end,
        minwid = function(self)
          return self.bufnr
        end,
        name = "heirline_tabline_close_buffer_callback",
      },
    },
  }

  -- The final touch!
  local TablineBufferBlock = utils.surround({ "", "" }, function(self)
    if self.is_active then
      return utils.get_highlight("TabLineSel").bg
    else
      return utils.get_highlight("TabLine").bg
    end
  end, { make_space(), TablineFileNameBlock, TablineCloseButton, make_space() })

  -- and here we go
  local BufferLine = utils.make_buflist(
    TablineBufferBlock,
    { provider = "", hl = { fg = "gray" } }, -- left truncation, optional (defaults to "<")
    { provider = "", hl = { fg = "gray" } } -- right trunctation, also optional (defaults to ...... yep, ">")
    -- by the way, open a lot of buffers and try clicking them ;)
  )
  return BufferLine
end

---@type LazySpec
return {
  {
    "rebelot/heirline.nvim",
    enabled = true,
    version = false,
    event = { "VeryLazy" },
    keys = {
      { "<M-p>", "<cmd>bp<cr>", desc = "Previous buffer" },
      { "<M-n>", "<cmd>bn<cr>", desc = "Next buffer" },
    },
    opts = function()
      local utils = require("heirline.utils")
      local conditions = require("heirline.conditions")

      local ctp = require("catppuccin.palettes").get_palette("mocha")
      local colors = vim.tbl_extend("force", ctp, {
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

      local Align = { provider = "%=" }
      local Space = make_space(1)

      local ViMode = make_vi_mode()
      local HydraMode = make_hydra_mode()
      local Ruler = make_ruler()
      local ScrollBar = make_scrollbar()
      local FileFlags = make_file_flags()
      local FileName = make_filename()
      local LspActive = make_lsp()
      local Breadcrumbs = make_lspsaga_breadcrumbs()
      local Diagnostics = make_diagnostics()
      local Git = make_git()
      local ShowCmd = make_showcmd()
      local FileType = make_filetype()
      local FileEncoding = make_file_encoding()
      local FileFormat = make_file_format()

      local BreadcrumbsOrFileName = {
        fallthrough = false,
        Breadcrumbs,
        {
          make_filename({
            with_flags = false,
          }),
          hl = "SagaFilename",
        },
      }

      local Mode = {
        ViMode,
        linked_surround({ "(", ")" }, nil, HydraMode),
      }

      ---@param component table
      local function invert_surround(component)
        return utils.surround({ "", "" }, function(self)
          return self:mode_color()
        end, { Space, { component, hl = { fg = "bg", bold = true, force = true } }, Space })
      end

      local DefaultStatusline = {
        Space,
        invert_surround(Mode),
        linked_surround({ "  ", " " }, nil, Git),
        linked_surround({ " ", " " }, nil, Diagnostics),
        linked_surround({ " ", " " }, nil, LspActive),
        Align,
        linked_surround({ "", " " }, nil, { provider = "%S" }),
        linked_surround({ "", " " }, nil, FileFlags),
        linked_surround({ "", " " }, nil, FileType),
        linked_surround({ "", " " }, nil, FileEncoding),
        linked_surround({ "", " " }, nil, FileFormat),
        invert_surround(Ruler),
        Space,
        { ScrollBar, hl = { fg = "secondary", force = true } },
      }

      local InactiveStatusline = {
        condition = conditions.is_not_active,
        FileType,
        Space,
        FileName,
        Align,
      }

      local OilStatusline = {
        condition = function()
          return vim.opt_local.filetype:get() == "oil"
        end,
        Space,
        invert_surround({
          provider = function()
            local ok, oil = pcall(require, "oil")
            if ok then
              return vim.fn.fnamemodify(oil.get_current_dir(), ":~")
            else
              return ""
            end
          end,
        }),
      }

      local QuickfixStatusline = {
        condition = function()
          return conditions.buffer_matches({
            filetype = { "qf" },
          })
        end,
        static = {
          is_loclist = function()
            return vim.fn.getloclist(0, { filewinid = 1 }).filewinid ~= 0
          end,
        },
        Space,
        invert_surround({
          provider = function(self)
            return self.is_loclist() and "Location List" or "Quickfix List"
          end,
        }),
        Space,
        {
          provider = function(self)
            if self.is_loclist() then
              return vim.fn.getloclist(0, { title = 0 }).title
            end
            return vim.fn.getqflist({ title = 0 }).title
          end,
        },
        Align,
        invert_surround(Ruler),
        Space,
      }

      local Statusline = {
        static = {
          mode_colors_map = {
            n = "primary",
            i = "secondary",
            v = "tertiary",
            V = "tertiary",
            ["\22"] = "cyan",
            c = "peach",
            s = "mavue",
            S = "mavue",
            ["\19"] = "mavue",
            R = "peach",
            r = "peach",
            ["!"] = "red",
            t = "red",
          },

          mode_color = function(self)
            local mode = conditions.is_active() and vim.fn.mode() or "n"
            return self.mode_colors_map[mode]
          end,
        },
        fallthrough = false,
        InactiveStatusline,
        OilStatusline,
        QuickfixStatusline,
        DefaultStatusline,
      }

      return {
        statusline = Statusline,
        -- winbar = { BreadcrumbsOrFileName },
        tabline = { make_bufferline() },
        opts = {
          colors = colors,
          disable_winbar_cb = function(args)
            return conditions.buffer_matches({
              buftype = { "nofile", "prompt", "help", "quickfix", "terminal" },
              filetype = { "^git.*", "fugitive", "Trouble", "dashboard" },
            }, args.buf)
          end,
        },
      }
    end,
    init = function()
      vim.opt.showtabline = 2

      vim.api.nvim_create_autocmd("FileType", {
        pattern = { "snacks_dashboard" },
        callback = function()
          vim.opt.showtabline = 0
        end,
      })

      vim.api.nvim_create_autocmd("BufWinLeave", {
        pattern = "*",
        callback = function()
          vim.opt.showtabline = 2
        end,
      })
    end,
    config = function(_, opts)
      vim.api.nvim_set_hl(0, "StatusLine", {})

      require("heirline").setup(opts)
    end,
  },
}
