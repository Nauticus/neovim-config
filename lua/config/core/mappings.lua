local keymap = vim.keymap

-- Disable F15 globally (prevents waking machine from sleep)
keymap.set(
    { "n", "i", "v", "x", "s", "o", "c" },
    "<F15>",
    "<Nop>",
    { desc = "Noop (F15 disabled)" }
)

-- GLOBAL MAPPINGS
keymap.set("i", "<C-h>", "<BS>", { desc = "Backspace" })

-- UTILS (u)
keymap.set("n", "<leader>ut", function()
    return "<Cmd>packadd nvim.undotree | Undotree<CR>"
end, { expr = true, desc = "Undotree" })
keymap.set("n", "<leader>ur", "<CMD>so %<CR>", { desc = "Source file" })
keymap.set("n", "<leader>uy", "<CMD>redir @* | file | redir END<CR>", { desc = "Paste file info" })
keymap.set("n", "<leader>uf", function()
    require("config.core.file_info").yank()
end, { desc = "Copy file info to clipboard" })
keymap.set("v", "<leader>uf", function()
    require("config.core.file_info").yank_selection()
end, { desc = "Copy selection info to clipboard" })

-- Move lines
keymap.set("v", "J", ":m '>+1<CR>gv=gv")
keymap.set("v", "K", ":m '<-2<CR>gv=gv")
keymap.set("n", "J", "mzJ`z")

-- Toggle
-- Toggles
local toggle_opt = function(opt) --[[@param opt string]]
  vim.opt[opt]:set(not vim.opt[opt].get())
  vim.notify(
    string.format("%s: %s", opt, vim.opt[opt].get()),
    vim.log.levels.INFO,
    { title = "Option toggled" }
  )
end

keymap.set("n", [[\on]], function() toggle_opt("number") end, { desc = "Toggle 'number'" })
keymap.set("n", [[\or]], function() toggle_opt("relativenumber") end, { desc = "Toggle 'relativenumber'" })
keymap.set("n", [[\os]], function() toggle_opt("spell") end, { desc = "Toggle 'spell'" })
keymap.set("n", [[\ol]], function() toggle_opt("list") end, { desc = "Toggle 'list'" })
keymap.set("n", [[\ob]], function() toggle_opt("breakindent") end, { desc = "Toggle 'breakindent'" })
keymap.set("n", [[\ow]], function() toggle_opt("wrap") end, { desc = "Toggle 'wrap'" })

-- Paste above/below
keymap.set({ "n", "x" }, "[p", function()
  vim.fn.put("!", vim.v.register)
end, { desc = "Paste Above" })
keymap.set({ "n", "x" }, "]p", function()
  vim.fn.put("", vim.v.register)
end, { desc = "Paste Below" })

-- Tailwind class virtual lines (toggle)
keymap.set("n", "<leader>cc", function()
    require("config.core.class_virtual_lines").toggle()
end, { desc = "Toggle class virtual lines" })

-- Go to definition in a vertical split
keymap.set("n", "<C-w>]", function()
    vim.cmd.vsplit()
    vim.lsp.buf.definition()
end, { desc = "Go to definition in vertical split" })
