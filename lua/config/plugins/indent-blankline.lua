return {
    "lukas-reineke/indent-blankline.nvim",
    enabled = true,
    opts = {
        filetype = {
            "javascript",
            "javascriptreact",
            "typescript",
            "typescriptreact",
            "lua",
            "go",
            "yaml",
            "json",
        },
        use_treesitter = true,
        use_treesitter_scope = true,
        show_current_context = true,
        show_current_context_start = false,
        disable_with_nolist = true,
    },
    config = true,
}
