---@type LazySpec
return {
  {
    "kevinhwang91/nvim-hlslens",
    version = false,
    event = { "CmdlineEnter" },
    opts = {},
    keys = {
      {
        "n",
        [[<Cmd>execute('normal! ' .. v:count1 .. 'n')<CR><Cmd>lua require('hlslens').start()<CR>]],
        mode = "n",
        noremap = true,
        silent = true,
        desc = "Next search result with hlslens",
      },
      {
        "N",
        [[<Cmd>execute('normal! ' .. v:count1 .. 'N')<CR><Cmd>lua require('hlslens').start()<CR>]],
        mode = "n",
        noremap = true,
        silent = true,
        desc = "Prev search result with hlslens",
      },
      {
        "*",
        [[*<Cmd>lua require('hlslens').start()<CR>]],
        mode = "n",
        noremap = true,
        silent = true,
        desc = "Search word under cursor forward with hlslens",
      },
      {
        "#",
        [[#<Cmd>lua require('hlslens').start()<CR>]],
        mode = "n",
        noremap = true,
        silent = true,
        desc = "Search word under cursor backward with hlslens",
      },
      {
        "g*",
        [[g*<Cmd>lua require('hlslens').start()<CR>]],
        mode = "n",
        noremap = true,
        silent = true,
        desc = "Search partial word forward with hlslens",
      },
      {
        "g#",
        [[g#<Cmd>lua require('hlslens').start()<CR>]],
        mode = "n",
        noremap = true,
        silent = true,
        desc = "Search partial word backward with hlslens",
      },
    },
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
