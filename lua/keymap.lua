local mk = require("mini.keymap")

-- Save file
--[[ Not good maybe
vim.keymap.set(
  { "i", "x", "n", "s" },
  "<C-s>",
  "<cmd>w<cr><esc>",
  { desc = "Save File" }
)
]]
vim.keymap.set("n", "<leader>w", "<cmd>w<cr>")

-- Move in line
vim.keymap.set({ "n", "v" }, "H", "^", { desc = "Move to the first non-blank character" })
vim.keymap.set({ "n", "v" }, "L", "g_", { desc = "Move to the latest non-blank character" })

-- Delete char without yank
vim.keymap.set({ "n", "v" }, "x", '"_x', { desc = "Delete current char without yank" })
vim.keymap.set({ "n", "v" }, "X", '"_X', { desc = "Delete prev char without yank" })

-- Visual paste without yank
vim.keymap.set({ "v" }, "p", '"_dP', { desc = "Visual paste without yank" })

-- Quickfix
vim.keymap.set("n", "<leader>qo", ":copen<cr>", { desc = "Open quickfix" })
vim.keymap.set("n", "<leader>qc", ":cclose<cr>", { desc = "Close quickfix" })
vim.keymap.set("n", "<leader>qn", ":cnext<cr>", { desc = "Next quickfix item" })
vim.keymap.set("n", "<leader>qp", ":cprevious<cr>", { desc = "Previous quickfix item" })

vim.keymap.set({ "", "!" }, "<C-c>", "<Esc>")

-- Copy and comment
vim.keymap.set("n", "<leader>C", "yygccp", { desc = "Copy to a comment above", remap = true })
vim.keymap.set("v", "<leader>C", "ygvgc`>p", { remap = true, desc = "Copy to a comment above" })

-- vim.keymap.set("i", "<S-cr>", "<esc>o")

-- Move in insert mode
vim.keymap.set("i", "<C-h>", "<left>")
vim.keymap.set("i", "<C-j>", "<down>")
vim.keymap.set("i", "<C-k>", "<up>")
vim.keymap.set("i", "<C-l>", "<right>")

--[[ Rarely used
-- Move line
vim.keymap.set("n", "<M-j>", "<cmd>move+1<cr>==")
vim.keymap.set("n", "<M-k>", "<cmd>move-2<cr>==")
vim.keymap.set("i", "<M-j>", "<esc><cmd>move+1<cr>==gi")
vim.keymap.set("i", "<M-k>", "<esc><cmd>move-2<cr>==gi")
vim.keymap.set("v", "<M-j>", "<esc><cmd>'<,'>move'>+1<cr>gv=gv")
vim.keymap.set("v", "<M-k>", "<esc><cmd>'<,'>move'<-2<cr>gv=gv")
]]

-- Cmdline shortcuts
vim.keymap.set("c", "<C-a>", "<Home>")
vim.keymap.set("c", "<C-e>", "<End>")

-- Fold by search results
vim.keymap.set("n", "zpr", function()
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
vim.keymap.set({ "i", "c" }, "<C-e>", function()
  local copilot = require("copilot.suggestion")
  if copilot.is_visible() then
    copilot.dismiss()
  end

  local cmp = require("cmp")
  if cmp.visible() then
    cmp.close()
  end
end, { desc = "Cancel completion" })
