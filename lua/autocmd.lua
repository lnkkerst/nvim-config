---@param name string
---@param opts? vim.api.keyset.create_augroup Dict Parameters
---@return number
local function augroup(name, opts)
  opts = opts or {}
  local defaults = {
    clear = true,
  }
  opts = vim.tbl_deep_extend("force", defaults, opts or {})
  return vim.api.nvim_create_augroup(name, vim.tbl_deep_extend("force", defaults, opts))
end

-- Disable undofile for certain file types
vim.api.nvim_create_autocmd({ "BufWritePre" }, {
  group = augroup("noundofile"),
  pattern = { "/tmp/*", "COMMIT_EDITMSG", "MERGE_MSG", "*.tmp", "*.bak" },
  callback = function()
    vim.opt_local.undofile = false
  end,
})

-- Check if file changed when its window is focus, more eager than 'autoread'
vim.api.nvim_create_autocmd({ "FocusGained", "TermClose", "TermLeave" }, {
  group = augroup("checktime"),
  callback = function()
    if vim.o.buftype ~= "nofile" then
      vim.cmd("checktime")
    end
  end,
})

-- Equalize window dimensions when resizing vim window
vim.api.nvim_create_autocmd({ "VimResized" }, {
  group = augroup("equalize_windows"),
  callback = function()
    local current_tab = vim.fn.tabpagenr()
    vim.cmd("tabdo wincmd =")
    vim.cmd("tabnext " .. current_tab)
  end,
})

-- Auto create dir when saving a file, in case some intermediate directory does not exist
vim.api.nvim_create_autocmd({ "BufWritePre" }, {
  group = augroup("auto_create_dir"),
  callback = function(event)
    if event.match:match("^%w%w+:[\\/][\\/]") then
      return
    end
    local file = vim.uv.fs_realpath(event.match) or event.match
    vim.fn.mkdir(vim.fn.fnamemodify(file, ":p:h"), "p")
  end,
})

-- Go to last loc when opening a buffer
vim.api.nvim_create_autocmd("BufReadPost", {
  group = augroup("last_loc"),
  callback = function(event)
    local exclude = { "gitcommit" }
    local buf = event.buf
    if vim.tbl_contains(exclude, vim.bo[buf].filetype) or vim.b[buf].lazyvim_last_loc then
      return
    end
    vim.b[buf].lazyvim_last_loc = true
    local mark = vim.api.nvim_buf_get_mark(buf, '"')
    local lcount = vim.api.nvim_buf_line_count(buf)
    if mark[1] > 0 and mark[1] <= lcount then
      pcall(vim.api.nvim_win_set_cursor, 0, mark)
    end
  end,
})

-- Wrap and check for spell in text filetypes
vim.api.nvim_create_autocmd("FileType", {
  group = augroup("wrap_spell"),
  pattern = { "text", "plaintex", "typst", "gitcommit", "markdown" },
  callback = function()
    vim.opt_local.wrap = true
    vim.opt_local.spell = true
  end,
})

-- Close some filetypes with <q>
vim.api.nvim_create_autocmd("FileType", {
  group = augroup("close_with_q"),
  pattern = {
    "checkhealth",
    "gitsigns-blame",
    "grug-far",
    "help",
    "notify",
    "qf",
  },
  callback = function(event)
    vim.bo[event.buf].buflisted = false
    vim.schedule(function()
      vim.keymap.set("n", "q", function()
        vim.cmd("close")
        pcall(vim.api.nvim_buf_delete, event.buf, { force = true })
      end, {
        buffer = event.buf,
        silent = true,
        desc = "Quit buffer",
      })
    end)
  end,
})

-- Make it easier to close man-files when opened inline
vim.api.nvim_create_autocmd("FileType", {
  group = augroup("man_unlisted"),
  pattern = { "man" },
  callback = function(event)
    vim.bo[event.buf].buflisted = false
  end,
})

-- Enable treesitter highlighting
vim.api.nvim_create_autocmd("FileType", {
  group = augroup("treesitter_highlight"),
  callback = function(args)
    local buf, ft = args.buf, args.match
    if vim.treesitter.language.add(ft) then
      vim.treesitter.start(buf, ft)
    end
  end,
})

vim.api.nvim_create_autocmd("TextYankPost", {
  group = augroup("hl_on_yank"),
  callback = function()
    vim.hl.on_yank({ higroup = "Search", timeout = 300 })
  end,
})
