---@diagnostic disable: missing-fields

return {
    "hrsh7th/nvim-cmp",
    event = { "InsertEnter", "CmdlineEnter" },
    dependencies = {
        "hrsh7th/cmp-buffer",
        "andersevenrud/cmp-tmux",
        { "saadparwaiz1/cmp_luasnip", dependencies = { "L3MON4D3/LuaSnip" } },
        "hrsh7th/cmp-path",
        "hrsh7th/cmp-nvim-lsp",
        "ray-x/cmp-treesitter",
        "hrsh7th/cmp-nvim-lua",
        "lukas-reineke/cmp-under-comparator",
        "hrsh7th/cmp-cmdline",
    },
    config = function()
        local cmp = require("cmp")
        local luasnip = require("luasnip")

        local mapping_next = function(fallback)
            if cmp.visible() then
                cmp.select_next_item()
            elseif luasnip.jumpable(1) then
                luasnip.jump(1)
            else
                fallback()
            end
        end

        local mapping_prev = function(fallback)
            if cmp.visible() then
                cmp.select_prev_item()
            elseif luasnip.jumpable(-1) then
                luasnip.jump(-1)
            else
                fallback()
            end
        end

        cmp.setup({
            performance = {
                async_budget = 1,
            },
            snippet = {
                expand = function(args)
                    luasnip.lsp_expand(args.body)
                end,
            },
            experimental = { ghost_text = false },
            completion = {
                keyword_length = 2,
            },
            window = {
                completion = cmp.config.window.bordered({
                    border = "none",
                    winhighlight = "Normal:CmpCompletionWindowFlat,FloatBorder:CmpCompletionWindow,CursorLine:Visual,Search:None",
                }),
                documentation = vim.tbl_deep_extend(
                    "force",
                    cmp.config.window.bordered({
                        border = "single",
                        winhighlight = "Normal:Normal,FloatBorder:CmpDocumentationWindow,CursorLine:Visual,Search:None",
                    }),
                    {
                        max_height = 10,
                        max_width = 80,
                    }
                ),
            },
            sorting = {
                priority_weight = 2,
                comparators = {
                    cmp.config.compare.locality,
                    cmp.config.compare.recently_used,
                    cmp.config.compare.score,
                    cmp.config.compare.sort_text,
                    cmp.config.compare.offset,
                    cmp.config.compare.order,
                },
            },
            sources = cmp.config.sources({
                {
                    name = "nvim_lsp",
                    priority_weight = 9,
                    entry_filter = function(entry)
                        return require("cmp.types").lsp.CompletionItemKind[entry:get_kind()]
                            ~= "Text"
                    end,
                },
                { name = "luasnip", priority_weight = 7 },
                { name = "nvim_lua", priority_weight = 6 },
                { name = "path" },
            }, {
                { name = "tmux", max_item_count = 10 },
                {
                    name = "buffer",
                    max_item_count = 10,
                    option = {
                        get_bufnrs = function()
                            return vim.api.nvim_list_bufs()
                        end,
                    },
                },
            }),
            mapping = {
                ["<C-n>"] = cmp.mapping({
                    i = mapping_next,
                    s = mapping_next,
                    c = function(fallback)
                        if cmp.visible() then
                            cmp.select_next_item({ behavior = cmp.SelectBehavior.Select })
                        else
                            fallback()
                        end
                    end,
                }),
                ["<C-p>"] = cmp.mapping({
                    i = mapping_prev,
                    s = mapping_prev,
                    c = function(fallback)
                        if cmp.visible() then
                            cmp.select_prev_item({ behavior = cmp.SelectBehavior.Select })
                        else
                            fallback()
                        end
                    end,
                }),

                ["<C-f>"] = cmp.mapping.scroll_docs(5),
                ["<C-u>"] = cmp.mapping.scroll_docs(-5),

                ["<C-j>"] = cmp.mapping(function(fallback)
                    if luasnip.choice_active() then
                        luasnip.change_choice(1)
                    else
                        fallback()
                    end
                end, { "i", "s" }),
                ["<C-k>"] = cmp.mapping(function(fallback)
                    if luasnip.choice_active() then
                        luasnip.change_choice(-1)
                    else
                        fallback()
                    end
                end, { "i", "s" }),

                ["<C-y>"] = cmp.mapping({
                    i = cmp.mapping.confirm({
                        behavior = cmp.ConfirmBehavior.Replace,
                        select = false,
                    }),
                    c = cmp.mapping.confirm({ select = false }),
                }),

                ["<C-c>"] = cmp.mapping({
                    i = function(fallback)
                        if cmp.visible() then
                            cmp.abort()
                        else
                            fallback()
                        end
                    end,
                    c = function(fallback)
                        if cmp.visible() then
                            cmp.close()
                        else
                            fallback()
                        end
                    end,
                }),
            },
        })

        cmp.setup.cmdline("/", {
            mapping = cmp.mapping.preset.cmdline(),
            sources = {
                { name = "buffer", max_item_count = 2 },
            },
        })

        cmp.setup.cmdline("?", {
            mapping = cmp.mapping.preset.cmdline(),
            sources = {
                { name = "buffer", max_item_count = 2 },
            },
        })

        cmp.setup.cmdline(":", {
            mapping = cmp.mapping.preset.cmdline(),
            sources = {
                { name = "cmdline" },
            },
        })
    end,
}
