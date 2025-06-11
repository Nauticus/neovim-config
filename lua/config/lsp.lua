vim.lsp.config("*", {
    root_markers = { '.git' },
})

-- Map over lsp runtime files
local configs = {}

for _, v in ipairs(vim.api.nvim_get_runtime_file("lsp/*", true)) do
	local name = vim.fn.fnamemodify(v, ":t:r")
	table.insert(configs, name)
end

vim.lsp.enable(configs)
