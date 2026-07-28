local M = {
    "lewis6991/gitsigns.nvim",
    dependencies = { "nvim-lua/plenary.nvim" },
}

function M.config()
    require("gitsigns").setup({
        sign_priority = 5,
        signs = {
            add = { text = "┃" },
            change = { text = "┃" },
            delete = { text = "╽" },
            topdelete = { text = "╿" },
            changedelete = { text = "┃" },
            untracked = { text = "┊" },
        },
        attach_to_untracked = true,
        current_line_blame = false,
        current_line_blame_opts = {
            virt_text = true,
            virt_text_pos = "eol",
            delay = 700,
            ignore_whitespace = true,
        },
        current_line_blame_formatter = "<author>, <author_time:%R> - <summary>",
        on_attach = function(bufnr)
            local gs = package.loaded.gitsigns

            local function map(mode, lhs, rhs, desc)
                vim.keymap.set(mode, lhs, rhs, { buffer = bufnr, desc = desc })
            end

            -- Navigation (nav_hunk replaces deprecated next_hunk / prev_hunk)
            map("n", "]c", function()
                gs.nav_hunk("next")
            end, "Next hunk")

            map("n", "[c", function()
                gs.nav_hunk("prev")
            end, "Previous hunk")

            -- Hunk actions (direct Lua calls, supports partial hunks in visual mode)
            map({ "n", "v" }, "<leader>ghs", gs.stage_hunk, "Stage hunk")
            map({ "n", "v" }, "<leader>ghr", gs.reset_hunk, "Reset hunk")
            map("n", "<leader>ghu", gs.stage_hunk, "Undo stage hunk") -- stage_hunk on staged signs unstages
            map("n", "<leader>ghp", gs.preview_hunk, "Preview hunk")

            -- Buffer-level actions
            map("n", "<leader>gs", gs.stage_buffer, "Stage buffer")
            map("n", "<leader>gr", gs.reset_buffer, "Reset buffer")
            map("n", "<leader>gb", function()
                gs.blame_line({ full = true })
            end, "Blame line")

            -- Toggles
            map("n", [[\gb]], gs.toggle_current_line_blame, "Toggle current line blame")
            map("n", [[\gd]], gs.preview_hunk_inline, "Preview hunk inline")

            -- Text object
            map({ "o", "x" }, "ih", "<Cmd>Gitsigns select_hunk<CR>", "Select hunk")
        end,
    })
end

return M
