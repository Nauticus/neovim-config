return {
    "hrsh7th/nvim-cmp",
    dependencies = {
        "hrsh7th/cmp-nvim-lsp",
        "hrsh7th/cmp-path",
        "hrsh7th/cmp-buffer",
        "saadparwaiz1/cmp_luasnip",
        "rafamadriz/friendly-snippets",
    },
    event = "InsertEnter",
    config = function()
        local cmp = require("cmp")
        local luasnip = require("luasnip")

        cmp.setup({
            preselect = cmp.PreselectMode.Item,
            performance = {
                debounce = 60,
                throttle = 30,
                fetching_timeout = 500,
                filtering_context_budget = 3,
                confirm_resolve_timeout = 80,
                async_budget = 1,
                max_view_entries = 200,
            },
            mapping = cmp.mapping.preset.insert({
                ["<C-e>"] = cmp.mapping.abort(),
                ["<C-y>"] = cmp.mapping.confirm({ select = true }),
            }),
            snippet = {
                expand = function(args)
                    luasnip.lsp_expand(args.body)
                end,
            },
            window = {
                completion = cmp.config.window.bordered(),
                documentation = cmp.config.window.bordered(),
            },
            sources = cmp.config.sources({
                { name = "nvim_lsp", priority = 1000 },
                { name = "luasnip", priority = 750 },
                { name = "path", priority = 500 },
                { name = "buffer", priority = 250, keyword_length = 3, max_item_count = 5 },
            }),
            view = {
                docs = {
                    auto_open = true,
                },
            },
        })

        -- Set up completion for cmdline (file paths, etc.)
        cmp.setup.cmdline({ "/", "?" }, {
            mapping = cmp.mapping.preset.cmdline(),
            sources = {
                { name = "buffer" },
            },
        })
        cmp.setup.cmdline(":", {
            mapping = cmp.mapping.preset.cmdline(),
            sources = {
                { name = "path" },
            },
        })
    end,
}
