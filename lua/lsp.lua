local M = {}

local lsp_setup = false

---@class ServerConfig
---@field enabled? boolean
---@field format? boolean
---@field mason_install? boolean
---@field override? vim.lsp.Config | fun(): vim.lsp.Config

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
  ["systemd_ls"] = { format = true },
  ["neocmake"] = {},
  ["cmake"] = { enabled = false },
  ["dockerls"] = {},
  ["lemminx"] = { format = true },
  ["hyprls"] = { format = true },
  ["mesonlsp"] = { format = true },
  ["nginx_language_server"] = {},
  ["vale_ls"] = {},
  ["cspell_ls"] = {},

  -- Other lang
  ["lua_ls"] = { format = false },
  ["clangd"] = { format = false },
  ["gopls"] = { format = true },
  ["jdtls"] = { format = true },
  ["kotlin_language_server"] = { format = true },
  ["zls"] = { format = true },
  ["bashls"] = {},
  ["rust_analyzer"] = { format = true },

  -- Generic
  ["null-ls"] = { enabled = false, format = true, mason_install = false },
  ["copilot"] = {},
}

M.server_lists = {
  enabled_servers = vim.tbl_filter(function(server)
    return M.servers[server].enabled ~= false
  end, vim.tbl_keys(M.servers)),

  -- Auto install with mason.nvim
  servers_with_mason = vim.tbl_filter(function(server)
    return M.servers[server].mason_install ~= false and M.servers[server].enabled ~= false
  end, vim.tbl_keys(M.servers)),

  -- LSP format on save
  servers_with_format = vim.tbl_filter(function(server)
    return M.servers[server].format == true
  end, vim.tbl_keys(M.servers)),
}

M.setup = function()
  if lsp_setup then
    vim.notify("LSP already setup", vim.log.levels.WARN)
    return
  end

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
    underline = false,
    severity_sort = true,
    float = false,
  })

  -- User LSP attach config
  vim.api.nvim_create_autocmd("LspAttach", {
    group = vim.api.nvim_create_augroup("user_lsp_attach", {}),
    callback = function(ev)
      -- Disable semantic tokens
      local client = vim.lsp.get_client_by_id(ev.data.client_id)
      client.server_capabilities.semanticTokensProvider = nil
    end,
  })

  -- Default LSP config
  vim.lsp.config("*", {
    capabilities = vim.lsp.protocol.make_client_capabilities(),
  })

  for server, config in pairs(M.servers) do
    local override = config.override
    if override ~= nil then
      if type(override) == "function" then
        override = override()
      end
      vim.lsp.config(server, override)
    end
  end

  vim.lsp.enable(M.server_lists.enabled_servers)

  local format_enabled = true

  local function lsp_format()
    vim.lsp.buf.format({
      filter = function(client)
        return vim.tbl_contains(M.server_lists.servers_with_format, client.name)
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
    if args.fargs[1] == nil then
      lsp_format()
      return
    end

    if args.fargs[1] == "enable" then
      format_enabled = true
    elseif args.fargs[1] == "disable" then
      format_enabled = false
    elseif args.fargs[1] == "toggle" then
      format_enabled = not format_enabled
    else
      vim.notify("Invalid argument: " .. args.fargs[1], vim.log.levels.ERROR)
      return
    end

    if format_enabled then
      vim.notify("LSP format enabled")
    else
      vim.notify("LSP format disabled")
    end
  end, {
    desc = "Toggle LSP formatting",
    nargs = "?",
    complete = function(arg)
      local list = { "toggle", "enable", "disable" }
      return vim.tbl_filter(function(s)
        return string.match(s, "^" .. arg)
      end, list)
    end,
  })

  if vim.fn.has("nvim-0.12") == 1 then
    vim.lsp.inline_completion.enable(true)
  end

  lsp_setup = true
end

return M
