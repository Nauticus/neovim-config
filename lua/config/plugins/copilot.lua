return {
    "github/copilot.vim",
    enabled = true,
    cmd = "Copilot",
    event = { "BufReadPost", "BufNewFile" },
    config = function ()
        vim.g.copilot_enabled = 0
    end
}
-- return {
--     "zbirenbaum/copilot.lua",
--     cmd = "Copilot",
--     event = "InsertEnter",
--     config = function()
--         require("copilot").setup({
--             suggestion = {
--
--             },
--         })
--     end,
-- }
