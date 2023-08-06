return {
    "NeogitOrg/neogit",
    dependencies = "nvim-lua/plenary.nvim",
    opts = {
        integrations = {
            telescope = true,
            diffview = true
        },
    },
    config = true
}
