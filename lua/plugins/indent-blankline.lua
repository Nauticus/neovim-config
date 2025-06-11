return {
    "lukas-reineke/indent-blankline.nvim",
    enabled = true,
    keys = {
        {
            [[\i]],
            "<CMD>IBLToggle<CR>",
            desc = "Toggle indent-blankline",
        },
    },
    config = function()
        require("ibl").setup({
            enabled = false,
            indent = {
                char = "╎",
                highlight = "IndentBlanklineIndent",
            },
            scope = {
                enabled = true,
                show_start = false,
                show_end = false,
                highlight = "IndentBlanklineScope",
            },
        })
    end,
}
