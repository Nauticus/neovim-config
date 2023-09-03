return {
    "luukvbaal/statuscol.nvim",
    enabled = true,
    event = "VeryLazy",
    config = function()
        local builtin = require("statuscol.builtin")

        require("statuscol").setup({
            setopts = true,
            bt_ignore = { "terminal" },
            ft_ignore = {
                "oil",
                "NvimTree",
            },
            segments = {
                {
                    text = { " ", builtin.lnumfunc, " " },
                    sign = {
                        auto = false,
                        wrap = true,
                    },
                    click = "v:lua.ScLa",
                },
                {
                    sign = { name = { "Diagnostic" }, wrap = true },
                    click = "v:lua.ScSa",
                },
                {
                    text = { " ", builtin.foldfunc, " " },
                    condition = { builtin.not_empty, true, builtin.not_empty },
                    sign = {
                        wrap = true,
                    },
                    click = "v:lua.ScFa",
                },
                {
                    sign = {
                        name = { "GitSigns" },
                        fillchar = "│",
                        maxwidth = 1,
                        colwidth = 1,
                        auto = false,
                        wrap = true,
                    },
                    click = "v:lua.ScSa",
                },
            },
            clickhandlers = {
                FoldOther = false,
            },
        })
    end,
}
