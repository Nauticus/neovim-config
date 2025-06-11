return {
    {
        "folke/flash.nvim",
        event = "VeryLazy",
        opts = {
            modes = {
                char = { enabled = false },
            }
        },
        keys = {
            { "s",     mode = { "n", "x", "o" }, function() require("flash").jump() end,              desc = "Flash" },
            { "S",     mode = { "n", "x", "o" }, function() require("flash").treesitter() end,        desc = "Flash Treesitter" },
            { "r",     mode = "o",               function() require("flash").remote() end,            desc = "Remote Flash" },
            { "R",     mode = { "o", "x" },      function() require("flash").treesitter_search() end, desc = "Treesitter Search" },
            { "<c-s>", mode = { "c" },           function() require("flash").toggle() end,            desc = "Toggle Flash Search" },
        },
    },
    {
        "catppuccin/nvim",
        enabled = true,
        lazy = false,
        priority = 1000,
        name = "catppuccin",
        config = function()
            local utils = require("catppuccin.utils.colors")
            require("catppuccin").setup({
                flavour = "mocha", -- latte, frappe, macchiato, mocha
                compile_path = vim.fn.stdpath("cache") .. "/catppuccin",
                transparent_background = true,
                styles = {
                    variables = {},
                    conditionals = { "bold" },
                    comments = { "italic" },
                    types = {},
                    keywords = { "bold" },
                },
                custom_highlights = function(colors)
                    return {
                        -- CursorLine = { blend = 90 },
                        -- OilDir = { fg = colors.blue },
                        -- GutterSep = { fg = colors.base },
                        -- MatchParen = { bg = colors.surface0, bold = true },
                        -- MatchWord = { bg = colors.surface0, underdashed = true, bold = true },
                        -- CmpCompletionWindow = { fg = colors.surface2 },
                        -- LspInlayHint = { bg = colors.mantle, fg = colors.surface2 },
                        -- LspReferenceText = { bg = colors.surface0 },  -- used for highlighting "text" references
                        -- LspReferenceRead = { bg = colors.surface0 },  -- used for highlighting "read" references
                        -- LspReferenceWrite = { bg = colors.surface0 }, -- used for highlighting "write" references
                        -- FoldColumn = { fg = colors.surface2 },
                        -- NWinBar = { bg = colors.mantle },
                        -- LuaSnipModeChoice = { fg = colors.mantle, bg = colors.teal },
                        -- LuaSnipModeInsert = { fg = colors.mantle, bg = colors.green },
                        -- GitSignsUntracked = { fg = utils.blend(colors.green, colors.surface2, 0.5) },
                        -- IndentBlanklineIndent = { fg = colors.surface0 },
                        -- IndentBlanklineScope = { fg = colors.overlay0 },
                        -- IlluminatedWordText = { bg = colors.surface0 },
                        -- IlluminatedWordRead = { bg = colors.surface0 },
                        -- IlluminatedWordWrite = { bg = colors.surface0 },
                        -- CopilotSuggestion = { fg = colors.surface1, bg = colors.mantle },
                        -- LineNr = { bg = utils.blend(colors.base, colors.surface0, 0.7) },
                        -- LineNrBelow = { fg = utils.blend(colors.surface1, colors.blue, 0.7) },
                        -- LineNrAbove = { fg = utils.blend(colors.surface1, colors.green, 0.7) },
                        -- CursorLineNr = { bg = colors.surface0 },
                        -- -- LineNrBelow = { bg = colors.mauve },
                    }
                end,
                integrations = {
                    cmp = false,
                    blink_cmp = true,
                    gitsigns = true,
                    nvimtree = true,
                    telescope = false,
                    notify = true,
                    mini = true,
                    mason = true,
                    semantic_tokens = true,
                    treesitter = true,
                    which_key = true,
                    indent_blankline = false,
                    native_lsp = {
                        enabled = true,
                        virtual_text = {
                            errors = { "italic" },
                            hints = { "italic" },
                            warnings = { "italic" },
                            information = { "italic" },
                        },
                        underlines = {
                            errors = { "undercurl" },
                            hints = { "undercurl" },
                            warnings = { "undercurl" },
                            information = { "undercurl" },
                        },
                    },
                    -- For more plugins integrations please scroll down (https://github.com/catppuccin/nvim#integrations)
                },
            })
            vim.cmd.colorscheme("catppuccin")
        end,
    },
}
