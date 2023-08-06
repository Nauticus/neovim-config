return {
    { "kylechui/nvim-surround",     event = "BufReadPre", config = true },
    {
        'echasnovski/mini.basics',
        version = "*",
        config = function()
            require("mini.basics").setup({
                options = { basic = false, extra_ui = false },
                mappings = {
                    basic = true,
                    option_toggle_prefix = ""
                }
            })
        end
    },
    { 'echasnovski/mini.bracketed', version = '*',        config = true },
    -- { "tpope/vim-unimpaired" },
    { "junegunn/vim-easy-align",    cmd = "EasyAlign" },
    {
        "folke/flash.nvim",
        event = "VeryLazy",
        ---@type Flash.Config
        opts = {},
        keys = {
            {
                "r",
                mode = "o",
                function()
                    require("flash").remote()
                end,
                desc = "Remote Flash",
            },
        },
    },
    {
        "ggandor/leap.nvim",
        enabled = false,
        keys = {
            { "s", mode = "n" },
            { "S", mode = "n" },
            { "x", mode = "v" },
            { "X", mode = "v" },
        },
        opts = {
            safe_labels = {},
            labels = "setonuhidrclgkjmwxbSETONUHIDRCLGKJMWXB",
        },
        config = function(_, opts)
            local leap = require("leap")
            leap.add_default_mappings()

            local function make_labels(str)
                local dict = {}
                for i = 1, #str do
                    dict[i] = str:sub(i, i)
                end
                return dict
            end

            leap.opts.safe_labels = opts.safe_labels
            leap.opts.labels = make_labels(opts.labels)
        end,
    },
    {
        "ggandor/flit.nvim",
        dependencies = { "ggandor/leap.nvim" },
        keys = {
            { "f", mode = { "n", "v" } },
            { "F", mode = { "n", "v" } },
            { "t", mode = { "n", "v" } },
            { "T", mode = { "n", "v" } },
        },
        enabled = false,
        config = true,
    },
}
