return {
    "folke/which-key.nvim",
    enabled = true,
    opts = {
        plugins = {
            spelling = { enabled = true },
        },
        window = {
            border = "single",
            position = "bottom",
            padding = { 1, 0, 1, 0 },
            margin = { 2, 2, 1, 2 },
        },
        layout = {
            align = "left",
            width = { min = 20, max = 80 },
            spacing = 5,
        },
    },
    config = function(_, opts)
        local wk = require("which-key")
        wk.setup(opts)

        wk.register({ name = "+utilities" }, { prefix = "<leader>u" })
        wk.register({ name = "+harpoon" }, { prefix = "<leader>h" })
        wk.register({ name = "+persistance" }, { prefix = "<leader>p" })
        wk.register({ name = "+LSP" }, { prefix = "<leader>l" })
        wk.register(
            { name = "+gitsigns", h = { name = "+hunk" } },
            { prefix = "<leader>g" }
        )
        wk.register({ name = "+telescope" }, { prefix = "<leader>s", mode = "v" })
        wk.register({ name = "+telescope" }, { prefix = "<leader>s", mode = "n" })
        wk.register({
            ["\\"] = {
                name = "+toggle", l = { name = "+LSP" }, g = { name = "+Git" }, o = { name = "+Options" }
            }
        })
    end,
}
