return {
    "github/copilot.vim",
    enabled = false,
    cmd = "Copilot",
    event = { "BufReadPost", "BufNewFile" },
    config = function ()
        vim.g.copilot_enabled = 1
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
