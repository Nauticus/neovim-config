return {
    "ThePrimeagen/harpoon",
    branch = "harpoon2",
    keys = {
        {
            "[h",
            function()
                require("harpoon"):list():prev()
            end,
            desc = "Previous mark (Harpoon)",
        },
        {
            "]h",
            function()
                require("harpoon"):list():next()
            end,
            desc = "Next mark (Harpoon)",
        },
        {
            "<leader>hh",
            function()
                local harpoon = require("harpoon")
                harpoon.ui:toggle_quick_menu(harpoon:list())
            end,
            desc = "Toggle Harpoon UI",
        },
        {
            "<leader>ha",
            function()
                require("harpoon"):list():append()
            end,
            desc = "Mark file",
        },
        {
            "gh",
            function()
                local count = vim.v.count
                require("harpoon"):list():select(count)
            end,
            desc = "Go to marked file"
        }
    },
    opts = {
        settings = {
            save_on_toggle = true,
            sync_on_ui_close = true,
        }
    },
    dependencies = {
        "nvim-lua/plenary.nvim",
    },
}
