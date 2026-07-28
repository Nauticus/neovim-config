vim.lsp.config("*", {
    root_markers = { ".git" },
})

vim.o.foldmethod = "expr"
vim.o.foldexpr = "v:lua.vim.treesitter.foldexpr()"

-- Map over lsp runtime files
local configs = {}

for _, v in ipairs(vim.api.nvim_get_runtime_file("lsp/*", true)) do
    local name = vim.fn.fnamemodify(v, ":t:r")
    table.insert(configs, name)
end

vim.lsp.enable(configs)

-- Highlight references under cursor when LSP attaches
vim.api.nvim_create_autocmd("LspAttach", {
    callback = function(ev)
        local bufnr = ev.buf
        local client = vim.lsp.get_client_by_id(ev.data.client_id)

        if not client then
            return
        end

        if client:supports_method("textDocument/foldingRange") then
            local win = vim.api.nvim_get_current_win()
            vim.wo[win][0].foldexpr = "v:lua.vim.lsp.foldexpr()"
        end

        if not client:supports_method("textDocument/documentHighlight") then
            return
        end

        vim.api.nvim_create_autocmd("CursorHold", {
            group = vim.api.nvim_create_augroup("lsp_document_highlight", { clear = false }),
            buffer = bufnr,
            callback = function()
                vim.lsp.buf.document_highlight()
            end,
        })

        vim.api.nvim_create_autocmd("CursorMoved", {
            group = vim.api.nvim_create_augroup("lsp_clear_references", { clear = false }),
            buffer = bufnr,
            callback = function()
                vim.lsp.buf.clear_references()
            end,
        })
    end,
})
