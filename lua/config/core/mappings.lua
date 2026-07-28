local keymap = vim.keymap

-- Disable F15 globally (prevents waking machine from sleep)
keymap.set({ 'n', 'i', 'v', 'x', 's', 'o', 'c' }, '<F15>', '<Nop>', { desc = 'Noop (F15 disabled)' })

-- GLOBAL MAPPINGS
keymap.set("i", "<C-h>", "<BS>", { desc = "Backspace" })

-- UTILS (u)
keymap.set("n", "<leader>ut", function()
    return "<Cmd>packadd nvim.undotree | Undotree<CR>"
end, { expr = true, desc = "Undotree" })
keymap.set("n", "<leader>ur", "<CMD>so %<CR>", { desc = "Source file" })
keymap.set("n", "<leader>uy", "<CMD>redir @* | file | redir END<CR>", { desc = "Paste file info" })
keymap.set("n", "<leader>uf", function()
    local path = vim.fn.expand("%:.") -- path relative to cwd
    if path == "%" or path == "" then path = vim.fn.expand("%:p") end
    local line, col = vim.fn.line("."), vim.fn.col(".")

    -- git branch and changed status (via gitsigns buffer variables)
    local branch, changed = "(no branch)", "(unknown)"
    if vim.b.gitsigns_status_dict then
        branch = vim.b.gitsigns_head or vim.b.gitsigns_status_dict.head or "(no branch)"
        -- check if current line is inside any hunk
        local gs = package.loaded.gitsigns
        if gs then
            local hunks = gs.get_hunks(0)
            if hunks then
                for _, hunk in ipairs(hunks) do
                    local added_start = hunk.added and hunk.added.start or 0
                    local added_count = hunk.added and hunk.added.count or 0
                    if line >= added_start and line < added_start + added_count then
                        changed = string.format("changed (%s)", hunk.type)
                        break
                    end
                end
            end
            if changed == "(unknown)" then
                changed = "unchanged"
            end
        end
    end

    local info = string.format("%s | L%d:C%d | %s | %s", path, line, col, branch, changed)
    vim.fn.setreg("*")
    vim.fn.setreg("+")
    vim.fn.setreg(".", info)
    vim.fn.setreg("", info)
    vim.notify(info, vim.log.levels.INFO)
end, { desc = "Copy file info to clipboard" })

-- Move lines
keymap.set("v", "J", ":m '>+1<CR>gv=gv")
keymap.set("v", "K", ":m '<-2<CR>gv=gv")
keymap.set("n", "J", "mzJ`z")

-- Toggle
keymap.set('n', [[\on]], "<Cmd>set number! number?<CR>", { desc = "Toggle 'number'" })
keymap.set('n', [[\or]], "<Cmd>set relativenumber! relativenumber?<CR>", { desc = "Toggle 'relativenumber'" })
keymap.set("n", [[\os]], "<Cmd>set spell! spell?<CR>", { desc = "Toggle 'spell'" })
keymap.set("n", [[\ol]], "<Cmd>set list! list?<CR>", { desc = "Toggle 'list'" })
keymap.set("n", [[\ob]], "<Cmd>set bri! bri?<CR>", { desc = "Toggle 'breakindent'" })
keymap.set("n", [[\ow]], "<Cmd>set wrap! wrap?<CR>", { desc = "Toggle 'wrap'" })

keymap.set({ 'n', 'x' }, '[p', '<Cmd>exe "put! " . v:register<CR>', { desc = 'Paste Above' })
keymap.set({ 'n', 'x' }, ']p', '<Cmd>exe "put "  . v:register<CR>', { desc = 'Paste Below' })

-- Go to definition in a vertical split
keymap.set('n', '<C-w>]', function()
  vim.cmd.vsplit()
  vim.lsp.buf.definition()
end, { desc = 'Go to definition in vertical split' })
