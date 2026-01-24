local M = {}

local utils = require("heirline.utils")
local components = require("config.heirline.components")

function M.make_bufferline()
  local TablineBufnr = {
    provider = function(self)
      return tostring(self.bufnr) .. ". "
    end,
    hl = "Comment",
  }

  local TablineFileName = {
    provider = function(self)
      local filename = self.filename
      if filename == "" then
        return "[No Name]"
      end

      local tfilename = vim.fn.fnamemodify(filename, ":t")
      local count = 0

      for _, bufnr in ipairs(vim.api.nvim_list_bufs()) do
        if vim.api.nvim_buf_is_loaded(bufnr) then
          local bname = vim.api.nvim_buf_get_name(bufnr)
          if bname ~= "" and vim.fn.fnamemodify(bname, ":t") == tfilename then
            count = count + 1
            if count > 1 then
              break
            end
          end
        end
      end

      if count > 1 then
        local parent = vim.fn.fnamemodify(filename, ":p:h:t")
        return parent .. "/" .. tfilename
      end
      return tfilename
    end,
    hl = function(self)
      return { bold = self.is_active or self.is_visible, italic = true }
    end,
  }

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

  local TablineFileNameBlock = {
    init = function(self)
      self.filename = vim.api.nvim_buf_get_name(self.bufnr)
    end,
    hl = function(self)
      if self.is_active then
        return "TabLineSel"
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
    components.make_file_icon(),
    TablineFileName,
    components.linked_surround({ " ", "" }, nil, TablineFileFlags),
  }

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

  local TablineBufferBlock = utils.surround({ "", "" }, function(self)
    if self.is_active then
      return utils.get_highlight("TabLineSel").bg
    else
      return utils.get_highlight("TabLine").bg
    end
  end, { components.make_space(), TablineFileNameBlock, TablineCloseButton, components.make_space() })

  return utils.make_buflist(
    TablineBufferBlock,
    { provider = "", hl = { fg = "gray" } },
    { provider = "", hl = { fg = "gray" } }
  )
end

return M
