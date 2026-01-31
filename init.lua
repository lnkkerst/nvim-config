-- vim.g.open_command = "xdg-open"
vim.g.mapleader = " "
vim.g.maplocalleader = "\\"

require("options")
require("neovide")
require("filetypes")

local lazypath = vim.fn.stdpath("data") .. "/lazy/lazy.nvim"
if not (vim.uv or vim.loop).fs_stat(lazypath) then
  local lazyrepo = "https://github.com/folke/lazy.nvim.git"
  local out = vim.fn.system({
    "git",
    "clone",
    "--filter=blob:none",
    "--branch=stable",
    lazyrepo,
    lazypath,
  })
  if vim.v.shell_error ~= 0 then
    vim.api.nvim_echo({
      { "Failed to clone lazy.nvim:\n", "ErrorMsg" },
      { out, "WarningMsg" },
      { "\nPress any key to exit..." },
    }, true, {})
    vim.fn.getchar()
    os.exit(1)
  end
end
vim.opt.rtp:prepend(lazypath)

require("utils").lazy_file()

---@type LazyConfig
require("lazy").setup({
  spec = {
    { import = "plugins" },
    { import = "overlay.plugins" },
  },
  defaults = {
    cond = function(plugin)
      if vim.g.vscode then
        return not not plugin.vscode
      end
      return true
    end,
    version = "*",
  },
  performance = {
    rtp = {
      disabled_plugins = {
        "netrw",
        "netrwPlugin",
        "netrwSettings",
        "netrwFileHandlers",
        "matchit",
        "gzip",
        "tutor",
        "zip",
        "zipPlugin",
        "tar",
        "tarPlugin",
        "getscript",
        "getscriptPlugin",
        "vimball",
        "vimballPlugin",
        "2html_plugin",
        "logipat",
        "rrhelper",
        "spellfile_plugin",
      },
    },
  },
  rocks = {
    hererocks = true,
  },
  dev = {
    path = "~/projects/nvim-plugins",
  },
})

require("keymap")
require("lsp").setup()
require("autocmd")
require("commands")

pcall(require, "overlay")
