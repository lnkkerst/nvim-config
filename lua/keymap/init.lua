vim.g.mapleader = " "
require("keymap.config")

local wk = require("which-key")

-- Plugin BufferLine
wk.register({
    ["<A-1>"] = { "<cmd>BufferLineGoToBuffer 1<cr>", "BufferLineGoToBuffer 1" },
    ["<A-2>"] = { "<cmd>BufferLineGoToBuffer 2<cr>", "BufferLineGoToBuffer 2" },
    ["<A-3>"] = { "<cmd>BufferLineGoToBuffer 3<cr>", "BufferLineGoToBuffer 3" },
    ["<A-4>"] = { "<cmd>BufferLineGoToBuffer 4<cr>", "BufferLineGoToBuffer 4" },
    ["<A-5>"] = { "<cmd>BufferLineGoToBuffer 5<cr>", "BufferLineGoToBuffer 5" },
    ["<A-6>"] = { "<cmd>BufferLineGoToBuffer 6<cr>", "BufferLineGoToBuffer 6" },
    ["<A-7>"] = { "<cmd>BufferLineGoToBuffer 7<cr>", "BufferLineGoToBuffer 7" },
    ["<A-8>"] = { "<cmd>BufferLineGoToBuffer 8<cr>", "BufferLineGoToBuffer 8" },
    ["<A-9>"] = { "<cmd>BufferLineGoToBuffer 9<cr>", "BufferLineGoToBuffer 9" },
    ["<A-j>"] = { "<cmd>BufferLineCycleNext<cr>", "BufferLineCycleNext" },
    ["<A-k>"] = { "<cmd>BufferLineCyclePrev<cr>", "BufferLineCyclePrev" },
    ["<A-S-j>"] = { "<cmd>BufferLineMoveNext<cr>", "BufferLineMoveNext" },
    ["<A-S-k>"] = { "<cmd>BufferLineMovePrev<cr>", "BufferLineMovePrev" },
    b = {
        name = "bufferline action",
        ["e"] = { "<cmd>BufferLineSortByExtension<cr>", "BufferLineSortByExtension" },
        ["d"] = { "<cmd>BufferLineSortByDirectory<cr>", "BufferLineSortByDirectory" },
        ["p"] = { "<cmd>BufferLinePick<cr>", "BufferLinePick" }
    }
})

-- Plugin Lspsaga
wk.register({
    ["K"] = { "<cmd>Lspsaga hover_doc<cr>", "Lspsaga hover doc" },
    g = {
        name = "lspsaga action",
        x = { "<cmd>Lspsaga code_action<cr>", "Lspsaga code action" },
        d = { "<cmd>Lspsaga show_line_diagnostics<cr>", "Lspsaga show line diagnostics" },
        j = { "<cmd>Lspsaga diagnostic_jump_next<cr>", "Lspsaga next diagnostics" },
        k = { "<cmd>Lspsaga diagnostic_jump_prev<cr>", "Lspsaga prev diagnostics" },
        r = { "<cmd>Lspsaga rename<cr>", "Lspsaga rename" }
    }
})

wk.register({
    ["gx"] = { "<cmd>Lspsaga range_code_action<cr>", "Lspsaga range code action", mode = "x" }
})

-- Plugin accelerate_jk
wk.register({
    ["j"] = { "<Plug>(accelerated_jk_gj)", "accelerate j" },
    ["k"] = { "<Plug>(accelerated_jk_gk)", "accelerate k" }
})

-- Plugin Nvim-tree
wk.register({
    ["<C-n>"] = { "<cmd>NvimTreeToggle<cr>", "NvimTreeToggle" }
})

-- Plugin Aerial
wk.register({
    ["<A-a>"] = { "<cmd>AerialToggle<cr>", "AerialToggle" }
})

-- Plugin Telescope
wk.register({
    ["t"] = {
        name = "Telescope",
        ["f"] = {
            "<cmd>Telescope find_files<cr>",
            "Telescope find files"
        }
    }
}, { prefix = "<leader>" })

-- Plugin Markdown Preview
wk.register({
    ["<F12>"] = {
        "<cmd>MarkdownPreviewToggle<cr>",
        "Markdown Preview"
    }
})

-- Plugin Hop
wk.register({
    ["h"] = {
        name = "Hop action",
        ["l"] = { "<cmd>HopLine<cr>", "HopLine" },
        ["w"] = { "<cmd>HopWord<cr>", "HopWord" },
        ["c"] = {
            name = "HopChar",
            ["1"] = { "<cmd>HopChar1<cr>", "HopChar1" },
            ["2"] = { "<cmd>HopChar2<cr>", "HopChar2" }
        },
        ["p"] = { "<cmd>HopPattern<cr>", "HopPattern" }
    }
}, { prefix = "<leader>" })

-- Plugin Jaq
wk.register({
    ["j"] = { "<cmd>Jaq<cr>", "Jaq" }
}, { prefix = "<leader>" })

-- Plugin focus.nvim
wk.register({
    ["f"] = {
        name = "focus",
        ["h"] = { "<cmd>FocusSplitLeft<cr>", "FocusSplitLeft" },
        ["j"] = { "<cmd>FocusSplitDown<cr>", "FocusSplitDown" },
        ["k"] = { "<cmd>FocusSplitUp<cr>", "FocusSplitUp" },
        ["l"] = { "<cmd>FocusSplitRight<cr>", "FocusSplitRight" }
    }
})

-- Plugin ToggleTerm
wk.register({
    ["<C-\\>"] = { "ToggleTerm" }
})

-- Plugin NeoScroll
wk.register({
    ["<C-b>"] = { "NeoScroll backward" },
    ["<C-f>"] = { "NeoScroll forward" },
    ["<C-u>"] = { "NeoScroll up" },
    ["<C-d>"] = { "NeoScroll down" },
    ["<C-y>"] = { "NeoScroll up" },
    ["<C-e>"] = { "NeoScroll down" }
})

-- Plugin Dap
wk.register({
    ["d"] = {
        name = "Dap for debug",
        ["u"] = { "<cmd>lua require('dapui').toggle()<cr>", "Toggle dap UI" },
        ["b"] = { "<cmd>lua require('dap').toggle_breakpoint()<cr>", "Toggle breakpoint" },
        ["r"] = { "<cmd>lua require('dap').continue()<cr>", "Dap Continue" },
        ["o"] = { "<cmd>lua require('dapui').open()<cr>", "Open dap UI" },
        ["c"] = { "<cmd>lua require('dapui').close()<cr>", "Close dap UI" }
    }
}, { prefix = "<leader>" })

wk.register({
    ["<C-s>"] = { "<cmd>w<cr>", "Save file" }
})
