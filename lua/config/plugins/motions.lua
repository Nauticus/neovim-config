return {
    {
        "echasnovski/mini.surround",
        keys = {
            { "gsa", desc = "Add surrounding", mode = { "n", "v" } },
            { "gsd", desc = "Delete surrounding" },
            { "gsf", desc = "Find right surrounding" },
            { "gsF", desc = "Find left surrounding" },
            { "gsh", desc = "Highlight surrounding" },
            { "gsr", desc = "Replace surrounding" },
            { "gsn", desc = "Update `MiniSurround.config.n_lines`" },
        },
        opts = {
            mappings = {
                add = "gsa", -- Add surrounding in Normal and Visual modes
                delete = "gsd", -- Delete surrounding
                find = "gsf", -- Find surrounding (to the right)
                find_left = "gsF", -- Find surrounding (to the left)
                highlight = "gsh", -- Highlight surrounding
                replace = "gsr", -- Replace surrounding
                update_n_lines = "gsn", -- Update `n_lines`
            },
        },
    },
    {
        "echasnovski/mini.basics",
        version = "*",
        config = function()
            require("mini.basics").setup({
                options = { basic = false, extra_ui = false },
                mappings = {
                    basic = true,
                    option_toggle_prefix = "",
                },
            })
        end,
    },
    { "echasnovski/mini.bracketed", version = "*", config = true },
    -- { "tpope/vim-unimpaired" },
    { "junegunn/vim-easy-align", cmd = "EasyAlign" },
}
