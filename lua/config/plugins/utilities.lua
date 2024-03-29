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
        config = function()
            vim.g.mkdp_auto_close = 0
        end,
        ft = "markdown",
    },
    {
        "JoosepAlviste/nvim-ts-context-commentstring",
        config = function()
            require("ts_context_commentstring").setup({
                enable_autocmd = false,
            })
        end,
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
        lazy = false,
        config = function()
            require("Comment").setup({
                padding = true,
                pre_hook = require("ts_context_commentstring.integrations.comment_nvim").create_pre_hook(),
            })
        end,
    },
    { "ThePrimeagen/vim-be-good", cmd = "VimBeGood" },
}
