return {
    "nvim-mini/mini.files",
    enabled = false,
    version = "*",
    keys = {
        {
            "-",
            function()
                require("mini.files").open(vim.fn.expand("%:p:h"))
            end,
            desc = "Explore cwd",
        },
    },
    opts = {
        options = { permanent_delete = false },
        mappings = {
            close = "<esc>",
            go_in = "<shift-cr>",
            go_in_plus = "<cr>",
            go_out = "_",
            go_out_plus = "-",
            show_help = "?",
        },
    },
}
