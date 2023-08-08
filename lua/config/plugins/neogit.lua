return {
    "NeogitOrg/neogit",
    dependencies = "nvim-lua/plenary.nvim",
    opts = {
        integrations = {
            telescope = true,
            diffview = true
        },
    },
    keys = {
        {"<leader>gn", "<CMD>Neogit<CR>", desc = "Neogit"}
    },
    config = true
}
