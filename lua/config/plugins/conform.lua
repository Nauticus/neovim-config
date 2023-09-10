local js_formatters = {
    "prettier_d",
    "prettier",
}

return {
    "stevearc/conform.nvim",
    opts = {
        formatters_by_ft = {
            lua = { "stylua" },
            javascript = js_formatters,
            javascriptreact = js_formatters,
            typescript = js_formatters,
            typescriptreact = js_formatters,
            go = { formatters = { "gofmt", "goimports", "golines" }, run_all_formatters = true },
            yaml = { formatters = { "yamlfmt" } },
        },
    },
    keys = {
        { "<leader>lf", '<cmd>lua require("conform").format()<cr>', desc = "Format" },
    },
}
