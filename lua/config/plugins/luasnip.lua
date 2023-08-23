return {
    "L3MON4D3/LuaSnip",
    event = "BufReadPre",
    build = "make install_jsregexp",
    dependencies = {
        "rafamadriz/friendly-snippets",
    },
    config = function()
        local luasnip = require("luasnip")
        local types = require("luasnip.util.types")

        luasnip.config.set_config({
            history = true,
            update_events = "TextChanged,TextChangedI",
            region_check_events = "CursorHold",
            delete_check_events = "TextChanged",
            ext_opts = {
                [types.choiceNode] = {
                    active = {
                        virt_text = { { "󱅖 ", "LuaSnipModeChoice" } },
                    },
                },
                [types.insertNode] = {
                    active = {
                        virt_text = { { " ", "LuaSnipModeInsert" } },
                    },
                },
            },
        })

        require("luasnip.loaders.from_lua").load()
        require("luasnip.loaders.from_vscode").lazy_load()
    end,
}
