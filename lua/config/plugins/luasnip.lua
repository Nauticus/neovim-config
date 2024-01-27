return {
    "L3MON4D3/LuaSnip",
    event = "BufReadPre",
    build = "make install_jsregexp",
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

        vim.api.nvim_create_user_command("LuaSnipEdit", function()
            require("luasnip.loaders").edit_snippet_files({
                extend = function(ft, paths)
                    if ft == "" then
                        ft = "all"
                    end
                    if #paths == 0 then
                        return {
                            {
                                vim.fn.stdpath("config") .. "/snippets/" .. ft .. ".snippets",
                                vim.fn.stdpath("config") .. "/snippets/" .. ft .. ".lua",
                            },
                        }
                    end

                    return {}
                end,
            })
        end, {})

        require("luasnip.loaders.from_lua").load({ paths = { "./snippets" } })
        require("luasnip.loaders.from_vscode").lazy_load({ path = { "./snippets" } })
    end,
}
