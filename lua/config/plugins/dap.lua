return {
    "mfussenegger/nvim-dap",
    keys = {
        { "<leader>dc", "<cmd>lua require('dap').continue()<CR>", desc = "Continue" },
        { "<leader>dr", "<cmd>lua require('dap').repl.open()<CR>", desc = "Open REPL" },
        { "<leader>db", "<cmd>lua require('dap').toggle_breakpoint()<CR>", desc = "Toggle breakpoint" },
        { "<leader>dB", "<cmd>lua require('dap').set_breakpoint(vim.fn.input('Breakpoint condition: '))<CR>", desc = "Set breakpoint with condition" },
        { "<leader>dl", "<cmd>lua require('dap').set_breakpoint(nil, nil, vim.fn.input('Log point message: '))<CR>", desc = "Set log point" },
        { "<leader>do", "<cmd>lua require('dap').step_over()<CR>", desc = "Step over" },
        { "<leader>di", "<cmd>lua require('dap').step_into()<CR>", desc = "Step into" },
        { "<leader>du", "<cmd>lua require('dap').step_out()<CR>", desc = "Step out" },
        { "<leader>ds", "<cmd>lua require('dap').stop()<CR>", desc = "Stop" },
        { "<leader>de", "<cmd>lua require('dap').disconnect()<CR>", desc = "Disconnect" },
        { "<leader>dr", "<cmd>lua require('dap').repl.open()<CR>", desc = "Open REPL" },
        { "<leader>dl", "<cmd>lua require('dap').run_last()<CR>", desc = "Run last" },
    },
    config = function()
        local dap = require("dap")
        -- react native debugging
        dap.adapters.node2 = {
            type = "executable",
            command = "node",
            args = { os.getenv("HOME") .. "/.local/share/nvim/dapinstall/jsnode_dbg/vscode-react-native/extension/dist/debugger.bundle.js" },
        }
    end,
}
