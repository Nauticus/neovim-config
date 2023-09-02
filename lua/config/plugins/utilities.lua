return {
    -- Docs
    { "nanotee/luv-vimdocs", event = "VeryLazy" },
    { "milisims/nvim-luaref", event = "VeryLazy" },
    { "Asheq/close-buffers.vim", cmd = "Bdelete" },

    {
        "mbbill/undotree",
        cmd = "UndotreeToggle",
        keys = {
            { [[\u]], ":UndotreeToggle<CR>", desc = "Undotree" },
        },
        config = function()
            vim.g.undotree_WindowLayout = 2
            vim.g.undotree_SetFocusWhenToggle = 1
            vim.g.undotree_SplitWidth = 35
        end,
    },
    {
        "norcalli/nvim-colorizer.lua",
        cmd = { "ColorizerToggle", "ColorizerAttachToBuffer" },
        keys = {
            { [[\c]], "<CMD>ColorizerToggle<CR>", desc = "Colorizer" },
        },
        opts = {
            scss = { rgb_fn = true },
            css = { rgb_fn = true },
        },
    },
    {
        "iamcco/markdown-preview.nvim",
        build = function()
            vim.fn["mkdp#util#install"]()
        end,
        ft = "markdown",
    },
    {
        "anuvyklack/pretty-fold.nvim",
        config = true,
    },
    {
        "numToStr/Comment.nvim",
        keys = {
            { "gcc", mode = "n", desc = "Comment toggle current line" },
            { "gc", mode = { "n", "o" }, desc = "Comment toggle linewise" },
            { "gc", mode = "x", desc = "Comment toggle linewise (visual)" },
            { "gbc", mode = "n", desc = "Comment toggle current block" },
            { "gb", mode = { "n", "o" }, desc = "Comment toggle blockwise" },
            { "gb", mode = "x", desc = "Comment toggle blockwise (visual)" },
        },
        dependencies = { "nvim-treesitter/nvim-treesitter" },
        config = function()
            require("Comment").setup({
                pre_hook = function(ctx)
                    ---@diagnostic disable-next-line: return-type-mismatch
                    return require("ts_context_commentstring.internal").calculate_commentstring()
                end,
                padding = true,
            })
        end,
    },
    {
        "zbirenbaum/neodim",
        event = "LspAttach",
        config = true,
    },
    { "ThePrimeagen/vim-be-good", cmd = "VimBeGood" },
}
