return {
    "nvim-treesitter/nvim-treesitter",
    build = ":TSUpdate",
    event = "BufReadPre",
    keys = {
        {
            "<leader>uh",
            ":TSHighlightCapturesUnderCursor<CR>",
            desc = "(TS) Syntax captures under the cursor",
        },
    },
    dependencies = {
        "nvim-treesitter/nvim-treesitter-textobjects",
        "nvim-treesitter/nvim-treesitter-refactor",
        "nvim-treesitter/nvim-treesitter-context",
        "nvim-treesitter/playground",
        "nvim-treesitter/completion-treesitter",
        "windwp/nvim-ts-autotag",
    },
    config = function()
        local treesitter = require("nvim-treesitter")
        local query = require("nvim-treesitter.query")

        local foldmethod_backups = {}
        local foldexpr_backups = {}

        treesitter.define_modules({
            folding = {
                enable = true,
                attach = function(bufnr)
                    -- Fold settings are actually window based...
                    foldmethod_backups[bufnr] = vim.wo.foldmethod
                    foldexpr_backups[bufnr] = vim.wo.foldexpr
                    vim.wo.foldmethod = "expr"
                    vim.wo.foldexpr = "nvim_treesitter#foldexpr()"
                end,
                detach = function(bufnr)
                    vim.wo.foldmethod = foldmethod_backups[bufnr]
                    vim.wo.foldexpr = foldexpr_backups[bufnr]
                    foldmethod_backups[bufnr] = nil
                    foldexpr_backups[bufnr] = nil
                end,
                is_supported = query.has_folds,
            },
        })

        -- require("treesitter-context").setup()

        require("nvim-treesitter.configs").setup({
            ensure_installed = "all",
            ignore_install = { "haskell" },
            highlight = {
                enable = true,
                disable = function(lang, bufnr)
                    return vim.api.nvim_buf_line_count(bufnr) > 2000
                end
            },
            refactor = {
                highlight_definitions = { enable = true },
                highlight_current_scope = { enable = false }
            },
            -- tree_docs = { enable = true },
            incremental_selection = {
                enable = true,
                keymaps = {
                    init_selection = "<CR>",
                    node_incremental = "<BS>",
                    node_decremental = "<Del>",
                },
            },
            textobjects = {
                select = {
                    enable = true,
                    keymaps = {
                        -- You can use the capture groups defined in textobjects.scm
                        ["af"] = "@function.outer",
                        ["if"] = "@function.inner",
                        ["ac"] = "@class.outer",
                        ["ic"] = "@class.inner",
                        ["ii"] = "@call.inner",
                        ["ai"] = "@call.outer",
                    },
                },
            },
            autotag = { enable = true },
            context_commentstring = { enable = true },
            indent = { enable = true },
            playground = {
                enable = true,
                updatetime = 25,        -- Debounced time for highlighting nodes in the playground from source code
                persist_queries = true, -- Whether the query persists across vim sessions
            },
        })
    end,
}
