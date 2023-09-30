return {
    "RRethy/vim-illuminate",
    keys = {
        { [[\h]], "<CMD>IlluminateToggle<CR>", desc = "Toggle highlight" },
    },
    config = function()
        require("illuminate").configure({
            providers = {
                "lsp",
                "treesitter",
            },
            min_count_to_highlight = 2,
        })
    end,
}
