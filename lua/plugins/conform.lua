local js_formatters = {
    "prettier_d",
    "prettier",
}

return {
    "stevearc/conform.nvim",
    keys = {
        {
            "<leader>fm",
            function()
                require("conform").format()
            end,
            desc = "Format current buffer.",
        },
        {
            "<leader>fm",
            function()
                require("conform").format()
            end,
            desc = "Format selected lines.",
            mode = "v",
        },
        {
            "<leader>fmi",
            function()
                require("conform").format({ { formatters = { "injected" } } })
            end,
            desc = "Format with injected formatter(useful for raw lines processing).",
            mode = "v",
        },
    },
    opts = {
        formatters_by_ft = {
            lua = { "stylua" },
            sh = { "shfmt" },
            javascript = js_formatters,
            javascriptreact = js_formatters,
            typescript = js_formatters,
            typescriptreact = js_formatters,
            go = { "goimports", "golines", "gofmt" },
            yaml = { "yamlfmt", "prettier_d", "prettier", stop_after_first = true },
            html = { "prettier_d", "prettier" },
            scss = { "prettier" },
            css = { "prettier" },
            svg = { "xmlformat", stop_after_first = true },
            tex = { "latexindent" },
        },
        default_format_opts = {
            lsp_format = "fallback",
            timeout_ms = 10000,
        },
    },
    init = function()
        vim.o.formatexpr = "v:lua.require'conform'.formatexpr()"
    end,
}
