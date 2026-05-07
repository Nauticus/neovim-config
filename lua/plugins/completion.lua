return {
    "saghen/blink.cmp",
    -- dependencies = { "rafamadriz/friendly-snippets" },
    -- enabled = false,
    version = "1.*",
    ---@module 'blink.cmp'
    ---@type blink.cmp.Config
    event = { "VimEnter" },
    opts = {
        keymap = {
            preset = "default",
            ["<Tab>"] = {
                "snippet_forward",
                function() -- sidekick next edit suggestion
                    return require("sidekick").nes_jump_or_apply()
                end,
                function() -- if you are using Neovim's native inline completions
                    return vim.lsp.inline_completion.get()
                end,
                "fallback",
            },
        },
        appearance = {
            nerd_font_variant = "mono",
        },
        completion = {
            documentation = {
                auto_show = true,
                auto_show_delay_ms = 500,
            },
            menu = {
                auto_show_delay_ms = 300,
            },
        },
        signature = { enabled = true },
        sources = {
            default = { "lsp", "path", "buffer" },
        },
        fuzzy = { implementation = "rust" },
    },
    opts_extend = { "sources.default" },
}
