return {
    "saghen/blink.cmp",
    -- dependencies = { "rafamadriz/friendly-snippets" },
    -- enabled = false,
    version = "1.*",
    ---@module 'blink.cmp'
    ---@type blink.cmp.Config
    event = { "InsertEnter", "CmdlineEnter" },
    opts = {
        keymap = { preset = "default" },
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
