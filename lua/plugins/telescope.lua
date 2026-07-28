local M = {
    "nvim-telescope/telescope.nvim",
    version = "*",
    dependencies = {
        "nvim-lua/plenary.nvim",
        { "nvim-telescope/telescope-ui-select.nvim" },
        { "kyoh86/telescope-windows.nvim" },
        { "tsakirist/telescope-lazy.nvim" },
    },
    init = function()
        -- Load ui-select immediately so vim.ui.select is replaced
        -- before LSP code actions or any other vim.ui.select calls fire.
        require("telescope").load_extension("ui-select")
    end,
    keys = {
        {
            "<leader>sf",
            function()
                require("telescope.builtin").find_files({ hidden = true })
            end,
            desc = "Find files",
        },
        {
            "<leader>sp",
            function()
                require("telescope.builtin").builtin()
            end,
            desc = "Find Pickers",
        },
        {
            "<leader>sr",
            function()
                require("telescope.builtin").resume()
            end,
            desc = "Resume last picker",
        },
        {
            "<leader>st",
            function()
                require("telescope").extensions.windows.list()
            end,
            desc = "Search windows",
        },
        {
            "<leader>sw",
            function()
                require("telescope.builtin").grep_string()
            end,
            desc = "Grep string",
        },
        {
            "<leader>sg",
            function()
                require("telescope.builtin").grep_string({
                    prompt_title = "Search in files",
                    search = "",
                })
            end,
            desc = "Grep interactive",
        },
        {
            "<leader>sw",
            function()
                local region = vim.fn.getregion(vim.fn.getpos("v"), vim.fn.getpos("."), {
                    type = vim.api.nvim_get_mode().mode,
                })
                require("telescope.builtin").grep_string({
                    search = table.concat(region, "\n"),
                })
            end,
            mode = "v",
            desc = "Grep visual selection",
        },
        {
            "<leader>s:",
            function()
                require("telescope.builtin").command_history()
            end,
            desc = "Command History",
        },
        {
            "<leader>scb",
            function()
                require("telescope.builtin").current_buffer_fuzzy_find()
            end,
            desc = "Current Buffer Fuzzy Find",
        },
        {
            "<leader>sb",
            function()
                require("telescope.builtin").buffers()
            end,
            desc = "Buffers",
        },
    },
}

M.config = function()
    local actions = require("telescope.actions")
    local telescope = require("telescope")

    telescope.setup({
        defaults = {
            initial_mode = "insert",
            color_devicons = false,
            sorting_strategy = "ascending",
            -- set_env = { ["COLORTERM"] = "truecolor" },
            file_ignore_patterns = { ".git/.*", "node_modules/.*" },
            layout_strategy = "horizontal",
            layout_config = {
                horizontal = {
                    prompt_position = "top",
                    width = { padding = 5 },
                    height = { padding = 5 },
                },
            },
            border = true,
            borderchars = {
                "─",
                "│",
                "─",
                "│",
                "╭",
                "╮",
                "╯",
                "╰",
            },
            mappings = {
                ["i"] = {
                    ["<C-?>"] = actions.which_key, -- keys from pressing <C-/>
                },
            },
        },
        pickers = {
            builtin = {
                -- previewer = false,
                include_extensions = true,
            },
            command_history = {
                theme = "ivy",
            },
            oldfiles = {
                only_cwd = true,
            },
            lsp_references = {
                theme = "ivy",
            },
            lsp_definitions = {
                theme = "ivy",
            },
            lsp_implementations = {
                theme = "ivy",
            },
            lsp_type_definitions = {
                theme = "ivy",
            },
            find_files = {
                find_command = { "rg", "--files", "--iglob", "!.git", "--hidden" },
                hidden = true,
            },
            live_grep = {
                disable_coordinates = true,
            },
        },
        extensions = {
            ["ui-select"] = {
                require("telescope.themes").get_dropdown({}),
            },
        },
    })

    telescope.load_extension("ui-select")
    telescope.load_extension("lazy")
    telescope.load_extension("windows")
end

return M
