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
    },
    {
        "norcalli/nvim-colorizer.lua",
        cmd = { "ColorizerToggle", "ColorizerAttachToBuffer" },
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
        keys = { "gc", "gb", { "gc", mode = "v" }, { "gb", mode = "v" } },
        dependencies = { "nvim-treesitter/nvim-treesitter" },
        opts = {
            padding = true,
        },
        config = true,
    },
    {
        "zbirenbaum/neodim",
        event = "LspAttach",
        config = true,
    },
    { "ThePrimeagen/vim-be-good", cmd = "VimBeGood" },
}
