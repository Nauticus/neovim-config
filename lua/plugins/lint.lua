return {
    "mfussenegger/nvim-lint",
    config = function()
        require("lint").linters_by_ft = {
            typescript = { "eslint" },
            typescriptreact = { "eslint" },
            javascript = { "eslint" },
            javascriptreact = { "eslint" },
            lua = { "luacheck" },
        }

        vim.api.nvim_create_autocmd({ "BufEnter", "BufWritePost", "TextChanged" }, {
            callback = function()
                require("lint").try_lint(nil, {
                    ignore_errors = true,
                })
            end,
        })
    end,
}
