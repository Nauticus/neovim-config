return {
    { "kylechui/nvim-surround", event = "BufReadPre", config = true },
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
