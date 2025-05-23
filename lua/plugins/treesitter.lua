---@type LazySpec
return {
  {
    "nvim-treesitter/nvim-treesitter",
    version = false,
    build = ":TSUpdate",
    lazy = vim.fn.argc(-1) == 0, -- load treesitter early when opening a file from the cmdline
    event = { "LazyFile", "VeryLazy" },
    cmd = { "TSUpdate" },
    config = function()
      require("nvim-treesitter.configs").setup({
        ensure_installed = {},

        sync_install = false,

        auto_install = true,

        highlight = {
          enable = true,
          additional_vim_regex_highlighting = false,
          disable = function(lang, buf)
            local disabled_langs = { "vue" }
            if vim.tbl_contains(disabled_langs, lang) then
              return true
            end
            local max_filesize = 10 * 1024
            local ok, stats = pcall(vim.loop.fs_stat, vim.api.nvim_buf_get_name(buf))
            if ok and stats and stats.size > max_filesize then
              return true
            end
          end,
        },

        indent = {
          enable = true,
        },
      })

      -- folding provider
      vim.wo.foldlevel = 99
      vim.wo.foldmethod = "expr"
      vim.wo.foldexpr = "v:lua.vim.treesitter.foldexpr()"
    end,
  },

  {
    "HiPhish/rainbow-delimiters.nvim",
    submodules = false,
    event = { "BufReadPost" },
    dependencies = { { "nvim-treesitter/nvim-treesitter" } },
  },

  {
    "nvim-treesitter/nvim-treesitter-context",
    dependencies = { { "nvim-treesitter/nvim-treesitter" } },
    event = { "BufReadPost" },
    opts = {},
  },

  {
    "windwp/nvim-ts-autotag",
    dependencies = { { "nvim-treesitter/nvim-treesitter" } },
    event = { "LazyFile" },
    opts = {
      opts = {
        enable_close_on_slash = true,
      },
    },
  },

  {
    "kylechui/nvim-surround",
    event = "LazyFile",
    dependencies = { "nvim-treesitter/nvim-treesitter" },
    opts = {},
  },

  {
    "andymass/vim-matchup",
    version = false,
    event = { "BufReadPost" },
    dependencies = { "nvim-treesitter/nvim-treesitter" },
    init = function()
      vim.g.matchup_matchparen_pumvisible = 0
    end,
    config = function()
      require("nvim-treesitter.configs").setup({
        matchup = {
          enable = true,
        },
      })
    end,
  },
  {
    "nvim-treesitter/nvim-treesitter-textobjects",
    dependencies = { "nvim-treesitter/nvim-treesitter" },
    event = { "BufReadPost" },
    config = function()
      require("nvim-treesitter.configs").setup({
        textobjects = {
          move = {
            enable = true,
            set_jumps = true,
            goto_next_start = {
              ["]f"] = {
                query = "@function.outer",
                desc = "Next function start",
              },
              ["]c"] = {
                query = "@class.outer",
                desc = "Next class start",
              },
              ["]l"] = {
                query = "@loop.outer",
                desc = "Next loop start",
              },
              ["]p"] = {
                query = "@parameter.outer",
                desc = "Next parameter start",
              },
              ["]a"] = {
                query = "@attribute.outer",
                desc = "Next attribute start",
              },
              ["]b"] = {
                query = "@block.outer",
                desc = "Next block start",
              },
            },
            goto_next_end = {
              ["]F"] = {
                query = "@function.outer",
                desc = "Next function end",
              },
              ["]C"] = {
                query = "@class.outer",
                desc = "Next class end",
              },
              ["]L"] = {
                query = "@loop.outer",
                desc = "Next loop end",
              },
              ["]P"] = {
                query = "@parameter.outer",
                desc = "Next parameter end",
              },
              ["]A"] = {
                query = "@attribute.outer",
                desc = "Next attribute end",
              },
              ["]B"] = {
                query = "@block.outer",
                desc = "Next block end",
              },
            },
            goto_previous_start = {
              ["[f"] = {
                query = "@function.outer",
                desc = "Previous function start",
              },
              ["[c"] = {
                query = "@class.outer",
                desc = "Previous class start",
              },
              ["[l"] = {
                query = "@loop.outer",
                desc = "Previous loop start",
              },
              ["[p"] = {
                query = "@parameter.outer",
                desc = "Previous parameter start",
              },
              ["[a"] = {
                query = "@attribute.outer",
                desc = "Previous attribute start",
              },
              ["[b"] = {
                query = "@block.outer",
                desc = "Previous block start",
              },
            },
            goto_previous_end = {
              ["[F"] = {
                query = "@function.outer",
                desc = "Previous function end",
              },
              ["[C"] = {
                query = "@class.outer",
                desc = "Previous class end",
              },
              ["[L"] = {
                query = "@loop.outer",
                desc = "Previous loop end",
              },
              ["[P"] = {
                query = "@parameter.outer",
                desc = "Previous parameter end",
              },
              ["[A"] = {
                query = "@attribute.outer",
                desc = "Previous attribute end",
              },
              ["[B"] = {
                query = "@block.outer",
                desc = "Previous block end",
              },
            },
          },

          select = {
            enable = true,
            lookahead = true,
            keymaps = {
              ["as"] = {
                query = "@local.scope",
                query_group = "locals",
                desc = "Select language scope",
              },
              ["af"] = {
                query = "@function.outer",
                desc = "function",
              },
              ["if"] = {
                query = "@function.inner",
                desc = "function",
              },
              ["ac"] = {
                query = "@class.outer",
                desc = "class",
              },
              ["ic"] = {
                query = "@class.inner",
                desc = "class",
              },
              ["ap"] = {
                query = "@parameter.outer",
                desc = "parameter",
              },
              ["ip"] = {
                query = "@parameter.inner",
                desc = "parameter",
              },
              ["al"] = {
                query = "@loop.outer",
                desc = "loop",
              },
              ["il"] = {
                query = "@loop.inner",
                desc = "loop",
              },
              ["aa"] = {
                query = "@attribute.outer",
                desc = "attribute",
              },
              ["ia"] = {
                query = "@attribute.inner",
                desc = "attribute",
              },
            },
            include_surrounding_whitespace = false,
          },

          swap = {
            enable = true,
            swap_next = {
              ["<leader>sp"] = "@parameter.inner",
              ["<leader>sa"] = "@attribute.inner",
            },
            swap_previous = {
              ["<leader>sP"] = "@parameter.inner",
              ["<leader>sA"] = "@attribute.inner",
            },
          },
        },
      })
    end,
  },

  {
    "aaronik/treewalker.nvim",
    event = { "LazyFile" },
    dependencies = { "nvim-treesitter/nvim-treesitter" },
    opts = {
      highlight = true,
      highlight_duration = 500,
    },
    keys = {
      {
        "<M-h>",
        function()
          require("treewalker").move_out()
        end,
      },
      {
        "<M-l>",
        function()
          require("treewalker").move_in()
        end,
      },
      {
        "<M-j>",
        function()
          require("treewalker").move_down()
        end,
      },
      {
        "<M-k>",
        function()
          require("treewalker").move_up()
        end,
      },
    },
  },

  {
    "Wansmer/treesj",
    dependencies = { "nvim-treesitter/nvim-treesitter" },
    cmd = { "TSJToggle", "TSJJoin", "TSJSplit" },
    opts = {},
  },
}
