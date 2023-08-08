return {
    "nvim-tree/nvim-tree.lua",
    cmd = "NvimTreeToggle",
    dependencies = {
        "nvim-tree/nvim-web-devicons",
    },
    keys = {
        { [[\p]], "<CMD>NvimTreeToggle<CR>", desc = "NvimTree" }
    },
    config = function()
        require("nvim-tree").setup({
            view = {
                relativenumber = true,
                width = 50,
            }
        })
    end,
}
