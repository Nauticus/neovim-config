return {
    "mfussenegger/nvim-lint",
    config = function()
        require("lint").linters_by_ft = {
            typescript = { "eslint_d" },
            typescriptreact = { "eslint_d" },
            javascript = { "eslint_d" },
            javascriptreact = { "eslint_d" },
            lua = { "luacheck" },
        }

        vim.api.nvim_create_autocmd({ "BufEnter", "BufWritePost", "TextChanged" }, {
            pattern = "*.ts,*.tsx,*.js,*.jsx,*.lua",
            callback = function()
                require("lint").try_lint()
            end,
        })
    end,
}
