return {
    { dir = "~/code/personal/nvim-routine" },
    {
        "loctvl842/monokai-pro.nvim",
        enabled = false,
        config = function()
            require("monokai-pro").setup({
                transparent_background = true,
                filter = "pro",
            })

            vim.cmd.colorscheme("monokai-pro")
        end,
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
                    types = {},
                    keywords = { "bold" },
                },
                custom_highlights = function(colors)
                    return {
                        OilDir = { fg = colors.blue },
                        GutterSep = { fg = colors.base },
                        MatchParen = { bg = colors.surface0, bold = true },
                        MatchWord = { bg = colors.surface0, underdashed = true, bold = true },
                        CmpCompletionWindow = { fg = colors.surface2 },
                        LspInlayHint = { bg = colors.mantle, fg = colors.surface2 },
                        LspReferenceText = { bg = colors.surface0 }, -- used for highlighting "text" references
                        LspReferenceRead = { bg = colors.surface0 }, -- used for highlighting "read" references
                        LspReferenceWrite = { bg = colors.surface0 }, -- used for highlighting "write" references
                        FoldColumn = { fg = colors.surface2 },
                        NWinBar = { bg = colors.mantle },
                        LuaSnipModeChoice = { fg = colors.mantle, bg = colors.teal },
                        LuaSnipModeInsert = { fg = colors.mantle, bg = colors.green },
                        CmpDocumentationWindow = { fg = colors.rosewater },
                        CmpCompletionWindowFlat = { fg = colors.text, bg = colors.surface0 },
                        CmpItemAbbrMatch = { fg = colors.blue },
                        CmpItemAbbr = { fg = utils.darken(colors.text, 0.6, colors.mantle) },
                        CmpItemAbbrMatchFuzzy = { link = "CmpItemAbbrMatch" },
                        GitSignsUntracked = { fg = utils.blend(colors.green, colors.surface2, 0.5) },
                        IndentBlanklineIndent = { fg = colors.surface0 },
                        IndentBlanklineScope = { fg = colors.overlay0 },
                        IlluminatedWordText = { bg = colors.surface0 },
                        IlluminatedWordRead = { bg = colors.surface0 },
                        IlluminatedWordWrite = { bg = colors.surface0 },
                    }
                end,
                integrations = {
                    cmp = true,
                    gitsigns = true,
                    nvimtree = true,
                    telescope = true,
                    notify = true,
                    mini = true,
                    mason = true,
                    semantic_tokens = true,
                    treesitter = true,
                    which_key = true,
                    indent_blankline = true,
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
