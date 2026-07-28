return {
    "mason-org/mason.nvim",
    cmd = { "Mason", "MasonInstall", "MasonUninstall", "MasonUninstallAll", "MasonUpdate", "MasonLog" },
    init = function()
        -- Ensure Mason binaries are on PATH before LSP servers try to start
        local mason_bin = vim.fn.stdpath("data") .. "/mason/bin"
        if vim.uv.fs_stat(mason_bin) then
            vim.env.PATH = mason_bin .. "/" .. vim.env.PATH
        end
    end,
    opts = {},
}
