return {
    'echasnovski/mini.clue',
    enabled = false,
    version = false,
    config = function()
        local miniclue = require('mini.clue')
        miniclue.setup({
            triggers = {
                -- Leader triggers
                { mode = 'n', keys = '<Leader>' },
                { mode = 'x', keys = '<Leader>' },

                -- Built-in completion
                { mode = 'i', keys = '<C-x>' },

                -- `g` key
                { mode = 'n', keys = 'g' },
                { mode = 'x', keys = 'g' },

                -- Marks
                { mode = 'n', keys = "'" },
                { mode = 'n', keys = '`' },
                { mode = 'x', keys = "'" },
                { mode = 'x', keys = '`' },

                -- Registers
                { mode = 'n', keys = '"' },
                { mode = 'x', keys = '"' },
                { mode = 'i', keys = '<C-r>' },
                { mode = 'c', keys = '<C-r>' },

                -- Window commands
                { mode = 'n', keys = '<C-w>' },

                { mode = 'n', keys = [[\]] },

                -- `z` key
                { mode = 'n', keys = 'z' },
                { mode = 'x', keys = 'z' },

                -- unimpaired keys
                { mode = 'n', keys = ']' },
                { mode = 'n', keys = '[' },

            },

            clues = {
                -- Enhance this by adding descriptions for <Leader> mapping groups
                miniclue.gen_clues.builtin_completion(),
                miniclue.gen_clues.g(),
                miniclue.gen_clues.marks(),
                miniclue.gen_clues.registers(),
                miniclue.gen_clues.windows({
                    submode_move = true,
                    submode_navigate = true,
                    submode_resize = true,
                }),
                miniclue.gen_clues.z(),

                { mode = 'n', keys = '<leader>l', desc = "+Language Server Provider" },
                { mode = 'x', keys = '<leader>l', desc = "+Language Server Provider" },

                { mode = 'n', keys = '<leader>p', desc = "+Session" },

                { mode = 'n', keys = '<leader>g', desc = "+Git" },
                { mode = 'x', keys = '<leader>g', desc = "+Git" },

                { mode = 'n', keys = '<leader>h', desc = "+Harpoon" },

                { mode = 'n', keys = '<leader>s', desc = "+Search" },
                { mode = 'x', keys = '<leader>s', desc = "+Search" },

                { mode = 'n', keys = '<leader>u', desc = "+Utilities" },

                { mode = 'n', keys = '<leader>t', desc = "+Structural search and replace" },
                { mode = 'x', keys = '<leader>t', desc = "+Structural search and replace" },

                { mode = 'n', keys = [[\o]], desc = "+Options" },
                { mode = 'n', keys = [[\l]], desc = "+LSP" },
                { mode = 'n', keys = [[\g]], desc = "+Git" },
            },
            window = {
                delay = 200,
                config = {
                    anchor = "NE",
                    width = "auto",
                }
            },
        })
    end
}
