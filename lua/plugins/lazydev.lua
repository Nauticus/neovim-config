return {
    "folke/lazydev.nvim",
    ft = "lua",
    enabled = function()
        return vim.g.lazydev_enabled == nil and true or vim.g.lazydev_enabled
    end,
    opts = {
        library = {
            { path = "${3rd}/luv/library", words = { "vim%.uv" } },
        },
        integrations = {
            lspconfig = false,
            cmp = false,
        }
    }
}
