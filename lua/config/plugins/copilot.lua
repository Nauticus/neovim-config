return {
    "github/copilot.vim",
    enabled = true,
    cmd = "Copilot",
    event = { "BufReadPost", "BufNewFile" },
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
