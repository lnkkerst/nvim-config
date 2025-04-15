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
  update_in_insert = false,
  underline = false,
  severity_sort = true,
  float = false,
  --[[
  virtual_text = {
    current_line = true,
    source = true,
    spacing = 6,
    prefix = " ",
    suffix = " ",
  },
  ]]
  --[[
  virtual_lines = {
    current_line = true,
  },
  ]]
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

-- Servers
local servers = {
  ["lua_ls"] = {
    format = false,
  },
  ["clangd"] = {},
  ["dprint"] = {
    format = true,
  },
  ["gopls"] = {
    format = true,
  },
  ["jsonls"] = {},
  ["oxlint"] = {},
  ["pyright"] = {},
  ["systemd_ls"] = {
    format = true,
  },
  ["ts_ls"] = {},
  ["volar"] = {},
  ["yamlls"] = {},
  ["eslint"] = {
    format = true,
  },
  ["html"] = {},
  ["cssls"] = {},
  ["cmake"] = {},
  ["dockerls"] = {},
  ["jdtls"] = {},
  ["tailwindcss"] = {},
  ["ruff"] = {
    format = true,
  },
  ["taplo"] = {
    format = true,
  },
  ["prismals"] = {
    format = true,
  },
  ["null-ls"] = {
    format = true,
  },
}

local enabled_servers = vim.tbl_filter(function(server)
  return servers[server].enabled ~= false
end, vim.tbl_keys(servers))

vim.lsp.enable(enabled_servers)

-- LSP format on save
local servers_with_format = vim.tbl_filter(function(server)
  return servers[server].format == true
end, vim.tbl_keys(servers))

local format_enabled = true

local function lsp_format()
  vim.lsp.buf.format({
    filter = function(client)
      return vim.tbl_contains(servers_with_format, client.name)
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
