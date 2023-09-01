return {
    "stevearc/conform.nvim",
    opts = {
        formatters_by_ft = {
            lua = { "stylua" },
            javascript = { "prettier_d", "prettier" },
            go = { formatters = { "gofmt", "goimports", "golines" }, run_all_formatters = true },
        },
    },
    keys = {
        { "<leader>lf", '<cmd>lua require("conform").format()<cr>', desc = "Format" },
    },
}
