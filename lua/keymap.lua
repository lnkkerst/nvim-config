local mk = require("mini.keymap")

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
mk.map_combo(vim.split("nixsotc", ""), "<Esc>", function()
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

-- Save file
--[[ Not good maybe
map(
  { "i", "x", "n", "s" },
  "<C-s>",
  "<cmd>w<cr><esc>",
  { desc = "Save File" }
)
]]
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
mk.map_combo({ "i", "c", "x", "s", "t" }, "jk", "<BS><BS><Esc>")
-- mk.map_combo({ "i", "c", "x", "s", "t" }, "jj", "<BS><BS><Esc>")

-- Tab
mk.map_multistep({ "i" }, "<Tab>", {
  "blink_accept",
  {
    condition = function()
      local copilot = require("copilot.suggestion")
      return copilot.is_visible()
    end,
    action = function()
      local copilot = require("copilot.suggestion")
      copilot.accept()
    end,
  },
  "vimsnippet_next",
  "increase_indent",
  "jump_after_close",
  "jump_after_tsnode",
}, {})

mk.map_multistep({ "i" }, "<S-Tab>", {
  "vimsnippet_prev",
  "decrease_indent",
  "jump_before_open",
  "jump_before_tsnode",
})

-- CR & BS
mk.map_multistep({ "i" }, "<CR>", {
  "blink_accept",
  "nvimautopairs_cr",
})

mk.map_multistep({ "i" }, "<BS>", { "nvimautopairs_bs" })

-- No hlsearch
mk.map_combo({ "n", "i", "x", "c" }, "<Esc><Esc>", function()
  vim.cmd("nohlsearch")
end)

-- Cancel completion
map({ "i", "c" }, "<C-e>", function()
  local copilot = require("copilot.suggestion")
  if copilot.is_visible() then
    copilot.dismiss()
  end

  local cmp = require("blink.cmp")
  if cmp.is_visible() then
    cmp.cancel()
  end
end, { desc = "Cancel completion" })

hydra({ "n" }, "<C-w><space>", "<C-w>", {
  name = "Win",
})
