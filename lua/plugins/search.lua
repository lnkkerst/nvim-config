---@type LazySpec
return {
  {
    "kevinhwang91/nvim-hlslens",
    enabled = true,
    event = { "CmdlineEnter" },
    opts = {},
    config = function(_, opts)
      require("hlslens").setup(opts)
      local kopts = { noremap = true, silent = true }

      vim.api.nvim_set_keymap(
        "n",
        "n",
        [[<Cmd>execute("normal! " . v:count1 . 'n')<CR><Cmd>lua require('hlslens').start()<CR>]],
        kopts
      )
      vim.api.nvim_set_keymap(
        "n",
        "N",
        [[<Cmd>execute("normal! " . v:count1 . 'N')<CR><Cmd>lua require('hlslens').start()<CR>]],
        kopts
      )
      vim.api.nvim_set_keymap("n", "*", [[*<Cmd>lua require('hlslens').start()<CR>]], kopts)
      vim.api.nvim_set_keymap("n", "#", [[#<Cmd>lua require('hlslens').start()<CR>]], kopts)
      vim.api.nvim_set_keymap("n", "g*", [[g*<Cmd>lua require('hlslens').start()<CR>]], kopts)
      vim.api.nvim_set_keymap("n", "g#", [[g#<Cmd>lua require('hlslens').start()<CR>]], kopts)

      -- vim.api.nvim_set_keymap("n", "<Leader>l", ":noh<CR>", kopts)
    end,
  },

  {
    "cshuaimin/ssr.nvim",
    opts = {},
    keys = {
      {
        "<leader>sr",
        function()
          require("ssr").open()
        end,
        mode = { "n", "x" },
      },
    },
  },

  {
    "MagicDuck/grug-far.nvim",
    cmd = { "GrugFar" },
    opts = {},
  },
}
