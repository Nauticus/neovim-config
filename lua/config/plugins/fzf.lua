return {
    "ibhagwan/fzf-lua",
    dependencies = { "nvim-tree/nvim-web-devicons" },
    keys = {
        {
            "<leader>sf",
            function()
                require("fzf-lua").files({
                    prompt = "Files ❯ ",
                    winopts = {
                        preview = {
                            hidden = "hidden",
                        },
                    },
                })
            end,
            desc = "Find files",
        },
        {
            "<leader>sp",
            function()
                require("fzf-lua").builtin()
            end,
            desc = "Find Pickers",
        },
        {
            "<leader>sr",
            function()
                require("fzf-lua").resume()
            end,
            desc = "Resume last picker",
        },
        {
            "<leader>sg",
            function()
                require("fzf-lua").live_grep()
            end,
            desc = "Grep interactive",
        },
        {
            "<leader>sw",
            function()
                require("fzf-lua").grep_visual()
            end,
            mode = "v",
            desc = "Grep visual selection",
        },
        {
            "<leader>sw",
            function()
                require("fzf-lua").grep_cword()
            end,
            mode = "n",
            desc = "Grep word under cursor",
        },
        {
            "<leader>sl",
            function()
                require("fzf-lua").blines()
            end,
            desc = "Search lines",
        },
    },
    opts = {
        "telescope",
        fzf_opts = {
            ["--ansi"] = "",
            ["--info"] = "default",
            ["--height"] = "100%",
            ["--layout"] = "reverse",
            ["--border"] = "none",
            ["--prompt"] = "❯",
            ["--pointer"] = "❯",
            ["--marker"] = "+",
            ["--no-scrollbar"] = "",
        },
        winopts = {
            height = 0.85,
            width = 0.80,
            preview = {
                vertical = "down:45%",
                layout = "vertical",
            },
        },
    },
    config = function(_, opts)
        local noicon = {
            git_icons = false,
            file_icons = false,
            color_icons = false,
        }

        opts["btags"] = noicon
        opts["buffers"] = noicon
        opts["complete_file"] = noicon
        opts["diagnostics"] = noicon
        opts["files"] = noicon
        opts["finder"] = noicon
        opts["git"] = {
            files = noicon,
            status = noicon,
        }
        opts["grep"] = noicon
        opts["lsp"] = noicon
        opts["quickfix"] = noicon
        opts["tabs"] = noicon
        opts["tags"] = noicon

        require("fzf-lua").setup(opts)
    end,
}
