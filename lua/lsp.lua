local M = {}

local lsp_setup_done = false

---@class ServerConfig
---@field enabled? boolean
---@field format? boolean
---@field mason_install? boolean
---@field override? vim.lsp.Config | fun(): vim.lsp.Config
---@field mason? ServerConfig.MasonConfig
---
---@class ServerConfig.MasonConfig
---@field name? string
---@field install? boolean

-- Servers
---@type table<string, ServerConfig>
M.servers = {
  -- Python
  ["pyright"] = { enabled = false },
  ["basedpyright"] = { enabled = true },
  ["delance"] = { enabled = false, mason_install = false },
  ["ty"] = { enabled = false },
  ["pyrefly"] = { enabled = false },
  ["ruff"] = { format = true },

  -- Web
  ["ts_ls"] = { enabled = true, mason_install = true },
  ["tsgo"] = { enabled = false },
  ["vue_ls"] = { mason_install = false },
  ["dprint"] = { enabled = false, format = true },
  ["oxlint"] = {},
  ["tailwindcss"] = {},
  ["unocss"] = {},
  ["astro"] = {},
  ["prismals"] = { format = true },
  ["eslint"] = { format = true },
  ["html"] = {},
  ["cssls"] = {},
  ["emmet_language_server"] = {},
  ["mdx_analyzer"] = {},
  ["stylelint_lsp"] = {},
  ["cssmodules_ls"] = {},

  ["jsonls"] = {},
  ["yamlls"] = {},
  ["taplo"] = { format = true },
  ["systemd_lsp"] = { format = true },
  ["neocmake"] = {},
  ["cmake"] = { enabled = false },
  ["dockerls"] = {},
  ["lemminx"] = { format = true },
  ["hyprls"] = { format = true },
  ["mesonlsp"] = { format = true },
  ["nginx_language_server"] = {},
  ["vale_ls"] = {},
  ["typos_lsp"] = {},
  ["harper_ls"] = {},

  -- Other lang
  ["lua_ls"] = { format = false },
  ["clangd"] = { format = false },
  ["gopls"] = { format = true },
  ["jdtls"] = { format = true },
  ["kotlin_language_server"] = { format = true },
  ["zls"] = { format = true },
  ["bashls"] = {},
  ["rust_analyzer"] = { format = true },
  ["qmlls"] = { format = true },

  -- Generic
  ["null-ls"] = { enabled = false, format = true, mason_install = false },
  ["ast-grep"] = {},
}

M.setup = function()
  if lsp_setup_done then
    vim.notify("LSP already setup", vim.log.levels.WARN)
    return
  end
  lsp_setup_done = true

  -- Auto set loclist
  vim.diagnostic.handlers.loclist = {
    show = function(_, _, _, opts)
      -- Generally don't want it to open on every update
      opts.loclist.open = opts.loclist.open or false
      local winid = vim.api.nvim_get_current_win()
      vim.diagnostic.setloclist(opts.loclist)
      vim.api.nvim_set_current_win(winid)
    end,
  }

  vim.diagnostic.config({
    signs = {
      text = {
        [vim.diagnostic.severity.ERROR] = " ",
        [vim.diagnostic.severity.WARN] = " ",
        [vim.diagnostic.severity.INFO] = " ",
        [vim.diagnostic.severity.HINT] = " ",
      },
    },
    update_in_insert = true,
    underline = true,
    severity_sort = true,
  })

  -- User LSP attach config
  vim.api.nvim_create_autocmd("LspAttach", {
    group = vim.api.nvim_create_augroup("user_lsp_attach", { clear = true }),
    callback = function(ev)
      -- Disable semantic tokens
      local client = vim.lsp.get_client_by_id(ev.data.client_id)
      if client ~= nil then
        client.server_capabilities.semanticTokensProvider = nil
      end
    end,
  })

  -- Default LSP config
  vim.lsp.config("*", {
    capabilities = vim.lsp.protocol.make_client_capabilities(),
  })

  -- Apply overrides
  for server, config in pairs(M.servers) do
    if config.enabled ~= false then
      if config.override then
        local override = config.override
        if type(override) == "function" then
          override = override()
        end
        vim.lsp.config(server, override)
      end

      vim.lsp.enable(server)
    end
  end

  local format_enabled = true

  local function lsp_format()
    vim.lsp.buf.format({
      filter = function(client)
        local config = M.servers[client.name]
        if config then
          return config.format == true
        end
      end,
    })
  end

  vim.api.nvim_create_autocmd("BufWritePre", {
    group = vim.api.nvim_create_augroup("lsp_format", { clear = true }),
    callback = function()
      if not format_enabled then
        return
      end
      lsp_format()
    end,
  })

  vim.api.nvim_create_user_command("LspFormat", function(args)
    local arg = args.fargs[1]
    if not arg then
      lsp_format()
      return
    end

    if arg == "enable" then
      format_enabled = true
      vim.notify("LSP format enabled")
    elseif arg == "disable" then
      format_enabled = false
      vim.notify("LSP format disabled")
    elseif arg == "toggle" then
      format_enabled = not format_enabled
      vim.notify("LSP format " .. (format_enabled and "enabled" or "disabled"))
    else
      vim.notify("Invalid argument: " .. arg, vim.log.levels.ERROR)
    end
  end, {
    desc = "Toggle or trigger LSP formatting",
    nargs = "?",
    complete = function(arg_lead)
      return vim.tbl_filter(function(s)
        return s:find("^" .. arg_lead)
      end, { "toggle", "enable", "disable" })
    end,
  })

  if vim.fn.has("nvim-0.12") == 1 then
    vim.lsp.inline_completion.enable(true)
  end
end

return M
