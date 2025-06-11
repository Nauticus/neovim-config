return {
    "folke/zen-mode.nvim",
    opts = {
        window = {
            width = 0.8,
            height = 0.8,
            options = {
                foldcolumn = "0",
            },
        },
        plugins = {
            gitsigns = { enabled = true },
            tmux = { enabled = true },
            wezterm = { enabled = true },
        },
        on_open = function()
            vim.o.cmdheight = 0
        end,
        on_close = function()
            vim.o.cmdheight = 1
        end,
    },
    keys = {
        { [[\z]], "<CMD>ZenMode<CR>", desc = "Toggle zen mode" },
    },
}
