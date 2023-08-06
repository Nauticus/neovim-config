return {
    "sindrets/diffview.nvim",
    cmd = {
        "DiffviewOpen",
        "DiffviewFileHistory"
    },
    dependencies = {
        "nvim-lua/plenary.nvim",
    },
    config = true,
    keys = {
        { "<leader>gd", "<cmd>DiffviewOpen<CR>", desc = "Diff view" }
    }
}
