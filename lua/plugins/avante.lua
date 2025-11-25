return {
    "yetone/avante.nvim",
    enabled = false,
    version = false,
    opts = {
        provider = "copilot",
        hints = { enabled = false },
    },
    build = "make",
    dependencies = {
        "nvim-treesitter/nvim-treesitter",
        "stevearc/dressing.nvim",
        "nvim-lua/plenary.nvim",
        "MunifTanjim/nui.nvim",
    }
}
