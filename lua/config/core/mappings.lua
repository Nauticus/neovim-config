local keymap = vim.keymap

-- GLOBAL MAPPINGS
keymap.set("i", "<C-h>", "<BS>", { desc = "Backspace" })

-- UTILS (u)
keymap.set("n", "<leader>ur", "<CMD>so %<CR>", { desc = "Source file" })
keymap.set("n", "<leader>uy", "<CMD>redir @* | file | redir END<CR>", { desc = "Paste file info" })

-- Move lines
keymap.set("v", "J", ":m '>+1<CR>gv=gv")
keymap.set("v", "K", ":m '<-2<CR>gv=gv")
keymap.set("n", "J", "mzJ`z")

-- Toggle
keymap.set('n', [[\on]], "<Cmd>setlocal number! number?<CR>", { desc = "Toggle 'number'" })
keymap.set('n', [[\or]], "<Cmd>setlocal relativenumber! relativenumber?<CR>", { desc = "Toggle 'relativenumber'" })
keymap.set("n", [[\os]], "<Cmd>setlocal spell! spell?<CR>", { desc = "Toggle 'spell'" })

keymap.set({ 'n', 'x' }, '[p', '<Cmd>exe "put! " . v:register<CR>', { desc = 'Paste Above' })
keymap.set({ 'n', 'x' }, ']p', '<Cmd>exe "put "  . v:register<CR>', { desc = 'Paste Below' })
