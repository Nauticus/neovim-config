return {
    "luukvbaal/statuscol.nvim",
    enabled = true,
    config = function(_, opts)
        local builtin = require('statuscol.builtin')

        require("statuscol").setup({
            setopts = true,
            bt_ignore = { 'terminal' },
            ft_ignore = {
                'oil',
                'NvimTree',
                "NeogitCommitMessage",
                "NeogitCommitView",
                "NeogitGitCommandHistory",
                "NeogitLogView",
                "NeogitNotification",
                "NeogitPopup",
                "NeogitStatus",
                "NeogitStatusNew",
            },
            segments = {
                {
                    sign = { name = { "Diagnostic" }, wrap = true },
                    click = "v:lua.ScSa"
                },
                {
                    text = { builtin.lnumfunc },
                    sign = {
                        auto = false,
                        wrap = true
                    },
                    click = 'v:lua.ScLa',
                },
                {
                    text = { ' ', builtin.foldfunc, ' ' },
                    condition = { builtin.not_empty, true, builtin.not_empty },
                    sign = {
                        wrap = true,
                    },
                    click = 'v:lua.ScFa'
                },
                {
                    sign = {
                        name = { "GitSigns" },
                        fillchar = "│",
                        maxwidth = 1,
                        colwidth = 1,
                        auto = false,
                        wrap = true
                    },
                    click = "v:lua.ScSa"
                },
            },
            clickhandlers = {
                FoldOther = false,
            },
        })
    end,
}
