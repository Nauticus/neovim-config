local js_formatters = {
    "prettier_d",
    "prettier",
}

return {
    "stevearc/conform.nvim",
    opts = {
        formatters_by_ft = {
            lua = { "stylua" },
            sh = { "shfmt" },
            javascript = { js_formatters },
            javascriptreact = { js_formatters },
            typescript = { js_formatters },
            typescriptreact = { js_formatters },
            go = { "goimports", "golines", "gofmt" },
            yaml = { { "yamlfmt", "prettier_d", "prettier" } },
            html = { "prettier_d", "prettier" },
        },
    },
    init = function()
        vim.o.formatexpr = "v:lua.require('conform').formatexpr()"
    end,
    keys = {
        { "<leader>lf", '<cmd>lua require("conform").format()<cr>', desc = "Format" },
    },
}
