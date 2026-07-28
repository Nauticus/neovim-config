return {
    "sindrets/diffview.nvim",
    dependencies = {
        "nvim-lua/plenary.nvim",
    },
    cmd = {
        "DiffviewOpen",
        "DiffviewFileHistory",
    },
    keys = {
        { "<leader>gd", "<cmd>DiffviewOpen<CR>", desc = "Diff view" },
        { "<leader>gh", "<cmd>DiffviewFileHistory %<CR>", desc = "File history" },
    },
    config = function()
        local actions = require("diffview.config").actions

        require("diffview").setup({
            -- Core options
            diff_binaries = false, -- Don't show diffs for binaries
            enhanced_diff_hl = true, -- Subtler delete-fill highlighting, better 2-way diff colors
            use_icons = vim.fn.has("win32") == 0, -- nvim-web-devicons is slow on Windows
            show_help_hints = true,
            watch_index = vim.fn.has("win32") == 0, -- fs_poll uses stat polling on Windows (no inotify)
            -- which is expensive; on Linux this is free via inotify

            -- Diff layout configuration per view type
            view = {
                default = {
                    layout = "diff2_horizontal", -- Side-by-side diffs for normal views
                    winbar_info = true, -- Show version info in winbar
                    disable_diagnostics = true, -- Reduce noise in diff buffers
                },
                merge_tool = {
                    layout = "diff3_mixed", -- OURS | THEIRS on top, LOCAL on bottom
                    winbar_info = true,
                    disable_diagnostics = true,
                },
                file_history = {
                    layout = "diff2_horizontal",
                    winbar_info = true,
                    disable_diagnostics = true,
                },
            },

            -- File panel (file tree on the left)
            file_panel = {
                listing_style = "tree", -- Tree view instead of flat list
                tree_options = {
                    flatten_dirs = true, -- Flatten single-child directories
                    folder_statuses = "only_folded",
                },
                win_config = {
                    position = "left",
                    width = 35,
                },
            },

            -- File history panel (commit list at the bottom)
            file_history_panel = {
                log_options = {
                    git = {
                        single_file = {
                            diff_merges = "combined",
                        },
                        multi_file = {
                            diff_merges = "first-parent",
                        },
                    },
                },
                win_config = {
                    position = "bottom",
                    height = 15,
                },
            },

            -- Default arguments prepended to commands
            default_args = {
                DiffviewOpen = { "--untracked-files=no" },
            },

            -- Hooks for customizing diff buffers
            hooks = {
                diff_buf_read = function()
                    -- Improve readability in diff windows
                    vim.opt_local.wrap = false
                    vim.opt_local.list = false
                end,
            },

            -- Custom keymaps (override defaults selectively)
            keymaps = {
                -- Keep all defaults, just add/override a few
                view = {
                    -- Stage/unstage from diff buffers directly
                    { "n", "<leader>gs", actions.toggle_stage_entry, desc = "Stage/unstage entry" },
                    { "n", "<leader>gS", actions.stage_all, desc = "Stage all entries" },
                    { "n", "<leader>gu", actions.unstage_all, desc = "Unstage all entries" },
                    {
                        "n",
                        "<leader>gr",
                        actions.restore_entry,
                        desc = "Restore entry (revert)",
                    },
                },
                file_panel = {
                    -- Quick close Diffview with q
                    { "n", "q", actions.close, desc = "Close the diff view" },
                },
            },
        })
    end,
}
