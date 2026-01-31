local header = [[
███████╗ ███╗   ███╗  █████╗   ██████╗ ███████╗
██╔════╝ ████╗ ████║ ██╔══██╗ ██╔════╝ ██╔════╝
█████╗   ██╔████╔██║ ███████║ ██║      ███████╗
██╔══╝   ██║╚██╔╝██║ ██╔══██║ ██║      ╚════██║
███████╗ ██║ ╚═╝ ██║ ██║  ██║ ╚██████╗ ███████║
╚══════╝ ╚═╝     ╚═╝ ╚═╝  ╚═╝  ╚═════╝ ╚══════╝]]

---@type LazySpec
return {
  "folke/snacks.nvim",
  priority = 1000,
  lazy = false,
  ---@type snacks.Config
  opts = {
    bigfile = { enabled = true },
    notifier = { enabled = true },
    quickfile = { enabled = true },
    statuscolumn = { enabled = true },
    words = { enabled = true },
    dashboard = {
      example = "compact_files",
      preset = {
        header = header,
      },
    },
    scroll = { enabled = false },
    indent = {
      enabled = true,
      animate = { enabled = false },
      indent = {},
    },
    scope = { enabled = true },
    terminal = {
      win = {
        height = 0.3,
      },
    },
    lazygit = {
      configure = true,
    },
    input = {},
    scratch = {},
    picker = {
      layout = {
        preset = "dropdown",
      },
      sources = {},
      layouts = {
        select = {
          layout = {
            border = "single",
          },
        },
        dropdown = {
          layout = {
            backdrop = false,
            row = 1,
            width = 0.6,
            min_width = 80,
            height = 0.8,
            border = "none",
            box = "vertical",
            {
              win = "preview",
              title = "{preview}",
              height = 0.6,
              border = "single",
            },
            {
              box = "vertical",
              border = "single",
              title = "{title} {live} {flags}",
              title_pos = "center",
              { win = "input", height = 1, border = "bottom" },
              { win = "list", border = "none" },
            },
          },
        },
      },
    },
    styles = {
      ["notification.history"] = {
        border = "single",
      },
      terminal = {
        border = "single",
      },
      notification = {
        border = "single",
      },
      input = {
        border = "single",
        relative = "cursor",
        row = -3,
        col = 0,
        width = 30,
      },
      scratch = {
        border = "single",
      },
    },
  },
  init = function()
    -- selene: allow(global_usage)
    _G.dd = function(...)
      require("snacks").debug.inspect(...)
    end
    -- selene: allow(global_usage)
    _G.bt = function()
      require("snacks").debug.backtrace()
    end
    -- selene: allow(global_usage)
    vim.print = _G.dd

    vim.api.nvim_create_user_command("Lazygit", function()
      ---@diagnostic disable-next-line: missing-fields
      require("snacks").lazygit({
        env = {
          SHELL = "/bin/bash",
        },
      })
    end, { desc = "Open lazygit" })

    vim.api.nvim_create_autocmd("LspProgress", {
      ---@param ev {data: {client_id: integer, params: lsp.ProgressParams}}
      callback = function(ev)
        local spinner = { "⠋", "⠙", "⠹", "⠸", "⠼", "⠴", "⠦", "⠧", "⠇", "⠏" }
        vim.notify(vim.lsp.status(), "info", {
          id = "lsp_progress",
          title = "LSP Progress",
          opts = function(notif)
            notif.icon = ev.data.params.value.kind == "end" and " "
              or spinner[math.floor(vim.uv.hrtime() / (1e6 * 80)) % #spinner + 1]
          end,
        })
      end,
    })

    ---@type table<number, {token:lsp.ProgressToken, msg:string, done:boolean}[]>
    local progress = vim.defaulttable()
    vim.api.nvim_create_autocmd("LspProgress", {
      ---@param ev {data: {client_id: integer, params: lsp.ProgressParams}}
      callback = function(ev)
        local client = vim.lsp.get_client_by_id(ev.data.client_id)
        local value = ev.data.params.value --[[@as {percentage?: number, title?: string, message?: string, kind: "begin" | "report" | "end"}]]
        if not client or type(value) ~= "table" then
          return
        end
        local p = progress[client.id]

        for i = 1, #p + 1 do
          if i == #p + 1 or p[i].token == ev.data.params.token then
            p[i] = {
              token = ev.data.params.token,
              msg = ("[%3d%%] %s%s"):format(
                value.kind == "end" and 100 or value.percentage or 100,
                value.title or "",
                value.message and (" **%s**"):format(value.message) or ""
              ),
              done = value.kind == "end",
            }
            break
          end
        end

        local msg = {} ---@type string[]
        progress[client.id] = vim.tbl_filter(function(v)
          return table.insert(msg, v.msg) or not v.done
        end, p)

        local spinner = { "⠋", "⠙", "⠹", "⠸", "⠼", "⠴", "⠦", "⠧", "⠇", "⠏" }
        vim.notify(table.concat(msg, "\n"), "info", {
          id = "lsp_progress",
          title = client.name,
          opts = function(notif)
            notif.icon = #progress[client.id] == 0 and " "
              or spinner[math.floor(vim.uv.hrtime() / (1e6 * 80)) % #spinner + 1]
          end,
        })
      end,
    })
  end,
  keys = function()
    local keys = {
      -- bufdelete
      {
        "<S-q>",
        function()
          require("snacks").bufdelete()
        end,
        desc = "Delete current buffer",
      },
      {
        "<leader>bd",
        function()
          require("snacks").bufdelete()
        end,
        desc = "Delete current buffer",
      },

      -- picker
      {
        "<leader>fn",
        function()
          ---@diagnostic disable-next-line: undefined-field
          require("snacks").picker.notifications({
            confirm = "focus_preview",
          })
        end,
        desc = "Pick notifications",
      },
      {
        "<leader>ff",
        function()
          require("snacks").picker()
        end,
        desc = "Pick pickers",
      },
      {
        "<leader>fg",
        function()
          require("snacks").picker.grep()
        end,
        desc = "Pick grep results",
      },
      {
        "<leader>fb",
        function()
          require("snacks").picker.buffers()
        end,
        desc = "Pick buffers",
      },
      {
        "<leader>fm",
        function()
          require("snacks").picker.marks()
        end,
        desc = "Pick marks",
      },
      {
        "<leader>fj",
        function()
          require("snacks").picker.jumps()
        end,
        desc = "Pick jump list",
      },
      {
        "<leader>fq",
        function()
          require("snacks").picker.qflist()
        end,
        desc = "Pick quickfix list",
      },
      {
        "<leader>fl",
        function()
          require("snacks").picker.loclist()
        end,
        desc = "Pick location list",
      },
      {
        "<leader>fd",
        function()
          require("snacks").picker.diagnostics()
        end,
        desc = "Pick diagnostics",
      },
      {
        "<C-p>",
        function()
          require("snacks").picker.files()
        end,
        desc = "Pick files",
      },
      {
        "gd",
        function()
          require("snacks").picker.lsp_definitions()
        end,
        desc = "Pick LSP definitions",
      },
      {
        "gri",
        function()
          require("snacks").picker.lsp_implementations()
        end,
        desc = "Pick LSP implementations",
      },
      {
        "grr",
        function()
          require("snacks").picker.lsp_references()
        end,
        desc = "Pick LSP references",
      },
      {
        "grt",
        function()
          require("snacks").picker.lsp_type_definitions()
        end,
        desc = "Pick LSP type definitions",
      },
      {
        "gO",
        function()
          require("snacks").picker.lsp_symbols({
            layout = "sidebar",
          })
        end,
        desc = "Pick LSP outgoing calls",
      },

      -- terminal
      {
        [[<C-\>]],
        function()
          require("snacks").terminal.toggle()
        end,
        mode = { "i", "n", "t" },
      },

      -- other
      {
        "<M-f>",
        function()
          require("snacks").zen()
        end,
        desc = "Toggle Zen Mode",
      },
    }

    return keys
  end,
}
