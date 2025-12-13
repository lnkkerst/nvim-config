local map_combo = require("mini.keymap").map_combo
local map_multistep = require("mini.keymap").map_multistep

---@param mode string|string[] Mode "short-name" (see |nvim_set_keymap()|), or a list thereof.
---@param lhs string           Left-hand side |{lhs}| of the mapping.
---@param rhs string|function  Right-hand side |{rhs}| of the mapping, can be a Lua function.
---@param opts? vim.keymap.set.Opts
local function map(mode, lhs, rhs, opts)
  opts = vim.tbl_extend("force", {
    noremap = true,
    silent = true,
    expr = false,
  }, opts or {})
  vim.keymap.set(mode, lhs, rhs, opts)
end

---@class HydraOpts
---@field map_opts? vim.keymap.set.Opts
---@field wk_opts? wk.Filter|string
---@field name? string

---@param mode string|string[] Mode "short-name" (see |nvim_set_keymap()|), or a list thereof.
---@param lhs string           Left-hand side |{lhs}| of the mapping.
---@param keys string
---@param opts? HydraOpts
local function hydra(mode, lhs, keys, opts)
  opts = opts or {}
  local wk_opts = vim.tbl_extend("force", {
    keys = keys,
    delay = 120 * 1000,
    loop = true,
    mode = "n",
  }, opts.wk_opts or {})
  map(mode, lhs, function()
    vim.g.hydra_active = true
    vim.g.hydra_name = opts.name or "Hydra"
    vim.api.nvim_exec_autocmds("User", {
      pattern = "HydraEnter",
      data = {
        name = vim.g.hydra_name,
      },
    })
    require("which-key").show(wk_opts)
  end, opts.map_opts or {})
end
-- Exit hydra mode
map_combo(vim.split("nixsotc", ""), "<Esc>", function()
  if vim.g.hydra_active then
    vim.g.hydra_active = false
    vim.api.nvim_exec_autocmds("User", {
      pattern = "HydraExit",
      data = {
        vim.g.hydra_name,
      },
    })
  end
end)
-- Redraw statusline when hydra mode toggles
vim.api.nvim_create_autocmd("User", {
  pattern = { "HydraEnter", "HydraExit" },
  callback = function()
    vim.cmd("redrawstatus")
  end,
})

map("n", "<leader>w", "<cmd>w<cr>")

-- Move in line
map({ "n", "v" }, "H", "^", { desc = "Move to the first non-blank character" })
map({ "n", "v" }, "L", "g_", { desc = "Move to the latest non-blank character" })

-- Delete char without yank
map({ "n", "v" }, "x", '"_x', { desc = "Delete current char without yank" })
map({ "n", "v" }, "X", '"_X', { desc = "Delete prev char without yank" })

-- Visual paste without yank
map({ "v" }, "p", '"_dP', { desc = "Visual paste without yank" })

-- Quickfix
map("n", "<leader>qo", ":copen<cr>", { desc = "Open quickfix" })
map("n", "<leader>qc", ":cclose<cr>", { desc = "Close quickfix" })
map("n", "<leader>qn", ":cnext<cr>", { desc = "Next quickfix item" })
map("n", "<leader>qp", ":cprevious<cr>", { desc = "Previous quickfix item" })

map({ "", "!" }, "<C-c>", "<Esc>")

-- Copy and comment
map("n", "<leader>C", "yygccp", { desc = "Copy to a comment above", remap = true })
map("v", "<leader>C", "ygvgc`>p", { remap = true, desc = "Copy to a comment above" })

-- map("i", "<S-cr>", "<esc>o")

-- Move in insert mode
map("i", "<C-h>", "<left>")
map("i", "<C-j>", "<down>")
map("i", "<C-k>", "<up>")
map("i", "<C-l>", "<right>")

--[[ Rarely used
-- Move line
map("n", "<M-j>", "<cmd>move+1<cr>==")
map("n", "<M-k>", "<cmd>move-2<cr>==")
map("i", "<M-j>", "<esc><cmd>move+1<cr>==gi")
map("i", "<M-k>", "<esc><cmd>move-2<cr>==gi")
map("v", "<M-j>", "<esc><cmd>'<,'>move'>+1<cr>gv=gv")
map("v", "<M-k>", "<esc><cmd>'<,'>move'<-2<cr>gv=gv")
]]

-- Cmdline shortcuts
map("c", "<C-a>", "<Home>")
map("c", "<C-e>", "<End>")

-- Fold by search results
map("n", "zpr", function()
  vim.cmd([[
    setlocal foldexpr=(getline(v:lnum)=~@/)?0:(getline(v:lnum-1)=~@/)|| (getline(v:lnum+1)=~@/)?1:2
    setlocal foldmethod=expr
    setlocal foldlevel=0
    setlocal foldcolumn=2
    set foldmethod=manual
  ]])
end, { noremap = true, desc = "Fold by search results" })

-- Escape
map_combo({ "i", "c", "s" }, "jk", "<BS><BS><Esc>")
map_combo({ "t" }, "jk", function()
  local keys = vim.api.nvim_replace_termcodes("<BS><BS><C-\\><C-n>", true, false, true)
  vim.api.nvim_feedkeys(keys, "in", true)
end)

-- <C-y> for completion confirmation
map_multistep({ "i" }, "<C-y>", {
  "blink_accept",
  -- Native inline completion
  {
    condition = function()
      if vim.fn.has("nvim-0.12") == 0 then
        return false
      end
      return vim.lsp.inline_completion.get()
    end,
    action = function() end,
  },
  -- Minuet inline completion
  {
    condition = function()
      local ok, minuet = pcall(require, "minuet.virtualtext")
      return ok and minuet.action.is_visible()
    end,
    action = function()
      local action = require("minuet.virtualtext").action
      return action.accept()
    end,
  },
  -- llm-ls
  {
    condition = function()
      local ok, completion = pcall(require, "llm.completion")
      return ok and completion.suggestion
    end,
    action = function()
      vim.schedule(require("llm.completion").complete)
    end,
  },
})

-- Tab
map_multistep({ "i" }, "<Tab>", {
  "vimsnippet_next",
  "increase_indent",
  "jump_after_close",
  "jump_after_tsnode",
  {
    condition = function()
      return true
    end,
    action = function()
      return "<Tab>"
    end,
  },
}, {})

-- NES
map_multistep({ "n" }, "<C-y>", {
  -- Sidekick NES
  {
    condition = function()
      local ok, sidekick = pcall(require, "sidekick")
      return ok and sidekick.nes_jump_or_apply()
    end,
    action = function() end,
  },
})

map_multistep({ "i" }, "<S-Tab>", {
  "vimsnippet_prev",
  "decrease_indent",
  "jump_before_open",
  "jump_before_tsnode",
})

-- CR & BS
map_multistep({ "i" }, "<CR>", {
  "blink_accept",
  "nvimautopairs_cr",
})

map_multistep({ "i" }, "<BS>", { "nvimautopairs_bs" })

-- No hlsearch
map_combo({ "n", "i", "x", "c" }, "<Esc><Esc>", function()
  vim.cmd("nohlsearch")
end)
map({ "n" }, "<leader>l", "<cmd>nohl<cr>")

-- Cancel completion
map({ "i", "c" }, "<C-e>", function()
  local ok, minuet = pcall(require, "minuet.virtualtext")
  if ok and minuet.action.is_visible() then
    minuet.action.dismiss()
  end

  local cmp = require("blink.cmp")
  if cmp.is_visible() then
    cmp.cancel()
  end
end, { desc = "Cancel completion" })

hydra({ "n" }, "<C-w><space>", "<C-w>", {
  name = "Win",
})

map({ "n" }, "<C-h>", "<C-w>h", { desc = "Move to left window" })
map({ "n" }, "<C-j>", "<C-w>j", { desc = "Move to bottom window" })
map({ "n" }, "<C-k>", "<C-w>k", { desc = "Move to top window" })
map({ "n" }, "<C-l>", "<C-w>l", { desc = "Move to right window" })

map({ "t" }, "<C-h>", "<C-\\><C-N><C-w>h", { desc = "Move to left window" })
map({ "t" }, "<C-j>", "<C-\\><C-N><C-w>j", { desc = "Move to bottom window" })
map({ "t" }, "<C-k>", "<C-\\><C-N><C-w>k", { desc = "Move to top window" })
map({ "t" }, "<C-l>", "<C-\\><C-N><C-w>l", { desc = "Move to right window" })
