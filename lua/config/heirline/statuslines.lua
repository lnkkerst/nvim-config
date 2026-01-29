local M = {}

local conditions = require("heirline.conditions")
local components = require("config.heirline.components")

local Align = { provider = "%=" }
local Space = components.make_space(1)

local ViMode = components.make_vi_mode()
local HydraMode = components.make_hydra_mode()
local Git = components.make_git()
local Diagnostics = components.make_diagnostics()
local LspActive = components.make_lsp()
local FileFlags = components.make_file_flags()
local FileType = components.make_filetype()
local FileEncoding = components.make_file_encoding()
local FileFormat = components.make_file_format()
local Ruler = components.make_ruler()
local ScrollBar = components.make_scrollbar()
local FileName = components.make_filename()

local Mode = {
  ViMode,
  components.linked_surround({ "(", ")" }, nil, HydraMode),
}

local DefaultStatusline = {
  Space,
  components.invert_surround(Mode),
  components.linked_surround({ "  ", " " }, nil, Git),
  components.linked_surround({ " ", " " }, nil, Diagnostics),
  components.linked_surround({ " ", " " }, nil, LspActive),
  Align,
  components.linked_surround({ "", " " }, nil, { provider = "%S" }),
  components.linked_surround({ "", " " }, nil, FileFlags),
  components.linked_surround({ "", " " }, nil, FileType),
  components.linked_surround({ "", " " }, nil, FileEncoding),
  components.linked_surround({ "", " " }, nil, FileFormat),
  components.invert_surround(Ruler),
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
  components.invert_surround({
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
  components.invert_surround({
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
  components.invert_surround(Ruler),
  Space,
}

M.Statusline = {
  static = {
    mode_colors_map = {
      n = "primary",
      i = "secondary",
      v = "tertiary",
      V = "tertiary",
      ["\22"] = "cyan",
      c = "peach",
      s = "mauve",
      S = "mauve",
      ["\19"] = "mauve",
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

return M
