return {
    "nvim-lualine/lualine.nvim",
    enabled = true,
    dependencies = { "nvim-tree/nvim-web-devicons" },
    config = function()
        local colors = require("catppuccin.palettes").get_palette "mocha"
        local theme
        if colors ~= nil then
            theme = {
                normal = {
                    a = { bg = colors.mantle, fg = colors.subtext0, gui = 'bold' },
                    b = { fg = colors.subtext0 },
                    c = { fg = colors.subtext0 },
                    z = { bg = colors.mantle }
                },
                insert = {
                    a = { bg = colors.peach, fg = colors.crust, gui = 'bold' },
                    z = { bg = colors.mantle }
                }
            }
        end
        require("lualine").setup({
            options = {
                theme = theme,
                disabled_filetypes = { "NvimTree", "DiffviewFiles", "harpoon", "TelescopePrompt" },
                component_separators = { left = "", right = "" },
                section_separators = { left = "", right = "" },
                always_divide_middle = false,
                globalstatus = true,
            },
            sections = {
                lualine_a = { {
                    "mode",
                    fmt = function(str)
                        return str:sub(1, 1):upper()
                    end
                } },
                lualine_b = {
                    { "filetype", icon_only = true },
                    { "filename", path = 1,        file_status = true, shorting_target = 50 },
                },
                lualine_c = {},
                lualine_x = {
                    {
                        "diagnostics",
                        sources = { "nvim_diagnostic" },
                        symbols = { error = " ", warn = " ", info = " ", hint = " " },
                    },
                },
                lualine_y = {
                    {
                        "diff",
                        symbols = { added = "+", modified = "~", removed = "−" },
                        colored = true,
                        padding = { left = 1, right = 1 },
                    },
                    {
                        "progress",
                    },
                    {
                        "location",
                    },
                },
                lualine_z = { "branch" },
            },
            extensions = { "quickfix", "fugitive" },
            inactive_sections = {
                lualine_a = { { "filetype", icon_only = true } },
                lualine_b = { { "filename", path = 1 } },
                lualine_c = {},
                lualine_x = {},
                lualine_y = {},
                lualine_z = {},
            },
        })
    end
}
