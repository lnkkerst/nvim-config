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

-- Accelerated j/k
local last_jk_time = 0
local jk_speed = 1
local jk_config = {
  acceleration = 0.25,
  max_acceleration = 5,
  decel_threshold = 100,
  accel_threshold = 100,
}

local function get_jk_amount(count)
  local now = vim.uv.now()
  local delta = now - last_jk_time

  if delta < jk_config.accel_threshold then
    jk_speed = math.min(jk_speed + jk_config.acceleration, jk_config.max_acceleration)
  elseif delta > jk_config.decel_threshold then
    jk_speed = 1
  end

  last_jk_time = now
  return count * math.floor(jk_speed)
end

local function accelerated_key_fn(key)
  return function()
    local count = vim.v.count1 == 0 and 1 or vim.v.count1
    local amount = get_jk_amount(count)
    vim.api.nvim_feedkeys(amount .. key, "n", false)
  end
end

map("n", "j", accelerated_key_fn("gj"))
map("n", "k", accelerated_key_fn("gk"))
map("v", "j", accelerated_key_fn("gj"))
map("v", "k", accelerated_key_fn("gk"))

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

-- Cmdline shortcuts
map("c", "<C-a>", "<Home>")
map("c", "<C-e>", "<End>")

-- Escape
map_combo({ "i", "c", "s" }, "jk", "<BS><BS><Esc>")
map_combo({ "t" }, "jk", function()
  local keys = vim.api.nvim_replace_termcodes("<BS><BS><C-\\><C-n>", true, false, true)
  vim.api.nvim_feedkeys(keys, "in", true)
end)

local inline_cmp_step = {
  condition = function()
    if vim.fn.has("nvim-0.12") == 0 then
      return false
    end
    return vim.lsp.inline_completion.get()
  end,
  action = function() end,
}
-- <C-y> for completion confirmation
map_multistep({ "i" }, "<C-y>", {
  "blink_accept",
  -- Native inline completion
  inline_cmp_step,
})

-- Tab
map_multistep({ "i" }, "<Tab>", {
  "vimsnippet_next",
  "blink_accept",
  inline_cmp_step,
  "increase_indent",
  "jump_after_tsnode",
  "jump_after_close",
}, {})

map_multistep({ "i" }, "<S-Tab>", {
  "vimsnippet_prev",
  "decrease_indent",
})

local sidekick_nes_step = {
  condition = function()
    local ok, sidekick = pcall(require, "sidekick")
    return ok and sidekick.nes_jump_or_apply()
  end,
  action = function() end,
}
-- NES
map_multistep({ "n" }, "<C-y>", {
  sidekick_nes_step,
})
map_multistep({ "n" }, "<Tab>", {
  sidekick_nes_step,
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

-- Window movement
map({ "n" }, "<C-h>", "<C-w>h", { desc = "Move to left window" })
map({ "n" }, "<C-j>", "<C-w>j", { desc = "Move to bottom window" })
map({ "n" }, "<C-k>", "<C-w>k", { desc = "Move to top window" })
map({ "n" }, "<C-l>", "<C-w>l", { desc = "Move to right window" })

map({ "t" }, "<C-h>", "<C-\\><C-N><C-w>h", { desc = "Move to left window" })
map({ "t" }, "<C-j>", "<C-\\><C-N><C-w>j", { desc = "Move to bottom window" })
map({ "t" }, "<C-k>", "<C-\\><C-N><C-w>k", { desc = "Move to top window" })
map({ "t" }, "<C-l>", "<C-\\><C-N><C-w>l", { desc = "Move to right window" })

-- Managed by barbar.nvim
-- -- Buffer movement
-- map({ "n" }, "]b", ":bnext<cr>", { desc = "Next buffer" })
-- map({ "n" }, "[b", ":bprevious<cr>", { desc = "Previous buffer" })
-- map({ "n" }, "<M-n>", ":bnext<cr>", { desc = "Next buffer" })
-- map({ "n" }, "<M-p>", ":bprevious<cr>", { desc = "Previous buffer" })
