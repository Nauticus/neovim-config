return {
    "lukas-reineke/indent-blankline.nvim",
    enabled = false,
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
        show_current_context_start = true,
        disable_with_nolist = true,
    },
    config = true,
}
