return {
    "folke/which-key.nvim",
    enabled = true,
    opts = {
        preset = "helix",
        plugins = {
            spelling = { enabled = true },
            presets = {
                operators = true,
            },
        },
    },
    config = function(_, opts)
        local wk = require("which-key")
        wk.setup(opts)
        wk.add({ "<leader>f", group = "format", icon = { icon = "󰊄", color = "blue" } })
        wk.add({ "<leader>u", group = "misc", icon = { icon = "󱁤", color = "grey" } })
        wk.add({ "<leader>h", group = "harpoon", icon = { icon = "󰛢", color = "green" } })
        wk.add({ "<leader>p", group = "persistance", icon = { icon = "", color = "red" } })
        wk.add({ "<leader>l", group = "lsp", icon = { icon = "LSP", color = "azure" } })
        wk.add({ "<leader>g", group = "git", icon = { icon = "󰊢" } })
        wk.add({ "<leader>gh", group = "hunk", icon = { icon = "󰊢" } })
        wk.add({ "<leader>s", group = "search", mode = { "n", "v" }, icon = { icon = "󰭎" } })

        -- wk.register({ name = "+telescope" }, { prefix = "<leader>s", mode = "v" })
        -- wk.register({ name = "+telescope" }, { prefix = "<leader>s", mode = "n" })
        -- wk.register({
        --     ["\\"] = {
        --         name = "+toggle", l = { name = "+LSP" }, g = { name = "+Git" }, o = { name = "+Options" }
        --     }
        -- })
    end,
}
