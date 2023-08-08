local M = {
    "neovim/nvim-lspconfig",
    event = "BufReadPre",
    dependencies = {
        {
            "williamboman/mason-lspconfig.nvim",
            opts = {
                ensure_installed = { "lua_ls", "tsserver", "jsonls", "eslint" },
            },
            dependencies = {
                "williamboman/mason.nvim",
                config = function()
                    require("mason").setup({
                        ui = {
                            border = "single",
                        },
                    })
                end,
            },
        },
        "b0o/schemastore.nvim",
        "folke/neodev.nvim",
        "hrsh7th/cmp-nvim-lsp",
        {
            "pmizio/typescript-tools.nvim",
            dependencies = { "nvim-lua/plenary.nvim", "neovim/nvim-lspconfig" },
        },
        -- Lsp
        { "j-hui/fidget.nvim", config = true },
        {
            "jose-elias-alvarez/null-ls.nvim",
            event = "BufReadPre",
            dependencies = {
                "jayp0521/mason-null-ls.nvim",
            },
        },
        {
            "folke/trouble.nvim",
            dependencies = { "nvim-tree/nvim-web-devicons" },
            opts = {}
        }
    },
}

vim.diagnostic.config({
    float = {
        border = "single",
        source = "always",
    },
})

local mappings = function(client, bufnr)
    local keymap = vim.keymap
    local pickers = require("telescope.builtin")
    local capabilities = client.server_capabilities

    local show_line_diagnostics = function()
        vim.diagnostic.open_float({
            scope = "line",
            source = "always",
            max_width = 120,
            focusable = false,
            border = "rounded",
            header = "Line Diagnostics:",
        })
    end

    local lsp_formatting = function()
        vim.lsp.buf.format({
            filter = function(c)
                return c.name ~= "sumneko_lua"
            end,
            bufnr = bufnr,
        })
    end

    local list_workspaces = function()
        vim.pretty_print(vim.lsp.buf.list_workspace_folders())
    end

    -- Go to
    if capabilities.definitionProvider then
        keymap.set(
            "n",
            "gd",
            pickers.lsp_definitions,
            { desc = "Go to definition", buffer = bufnr }
        )
    end
    if capabilities.declarationProvider then
        keymap.set(
            "n",
            "<leader>lgD",
            vim.lsp.buf.declaration,
            { desc = "Go to declaration", buffer = bufnr }
        )
    end
    if capabilities.implementationProvider then
        keymap.set(
            "n",
            "<leader>lgi",
            pickers.lsp_implementations,
            { desc = "Go to implementation", buffer = bufnr }
        )
    end
    if capabilities.typeDefinitionProvider then
        keymap.set(
            "n",
            "<leader>lgt",
            pickers.lsp_type_definitions,
            { desc = "Go to type definition", buffer = bufnr }
        )
    end
    if capabilities.referencesProvider then
        keymap.set(
            "n",
            "gr",
            pickers.lsp_references,
            { desc = "Go to reference", buffer = bufnr }
        )
    end

    -- Lsp specific
    if capabilities.signatureHelpProvider then
        keymap.set(
            "n",
            "<leader>ls",
            vim.lsp.buf.signature_help,
            { desc = "Show signature help", buffer = bufnr }
        )
    end
    if capabilities.renameProvider then
        keymap.set(
            "n",
            "<leader>lr",
            vim.lsp.buf.rename,
            { desc = "Rename symbol under cursor", buffer = bufnr }
        )
    end
    if capabilities.documentFormattingProvider then
        keymap.set("n", "<leader>lf", lsp_formatting, {
            desc = "Format",
            buffer = bufnr,
        })
    end
    -- if capabilities.documentRangeFormattingProvider then
    --     keymap.set("v", "<leader>lf", vim.lsp.buf.range_formatting, { desc = "Range format" })
    -- end
    if capabilities.codeActionProvider then
        keymap.set(
            "n",
            "<leader>la",
            vim.lsp.buf.code_action,
            { desc = "Code actions", buffer = bufnr }
        )
    end

    if capabilities.hoverProvider then
        keymap.set("n", "K", vim.lsp.buf.hover, {
            desc = "Hover",
            buffer = bufnr,
        })
    end

    keymap.set(
        "n",
        "<leader>ld",
        show_line_diagnostics,
        { desc = "Show line diagnostics", buffer = bufnr }
    )

    -- Workspaces
    keymap.set(
        "n",
        "<leader>lwa",
        vim.lsp.buf.add_workspace_folder,
        { desc = "Add workspace folder" }
    )
    keymap.set(
        "n",
        "<leader>lwr",
        vim.lsp.buf.remove_workspace_folder,
        { desc = "Remove workspace folder" }
    )
    keymap.set("n", "<leader>lwl", list_workspaces, { desc = "List workspace folders" })
    keymap.set("n", [[\lh]], function()
        vim.lsp.inlay_hint(bufnr, nil)
    end, { desc = "Toggle inlay hints" })
end

local function on_attach(client, bufnr)
    mappings(client, bufnr)

    vim.lsp.handlers["textDocument/signatureHelp"] = vim.lsp.with(vim.lsp.handlers.signature_help, {
        border = "single",
        max_width = 80,
    })

    vim.lsp.handlers["textDocument/hover"] = vim.lsp.with(vim.lsp.handlers.hover, {
        border = "single",
        max_width = 120,
    })
end

M.config = function()
    local null_ls = require("null-ls")
    local group_name = "vimrc_mason_lspconfig"
    vim.api.nvim_create_augroup(group_name, { clear = true })

    vim.api.nvim_create_autocmd("LspAttach", {
        callback = function(args)
            local bufnr = args.buf
            local client = vim.lsp.get_client_by_id(args.data.client_id)
            if client.supports_method("textDocument/inlayHint") then
                vim.lsp.inlay_hint(bufnr, false)
            end
        end,
        group = group_name,
    })

    require("mason-null-ls").setup({
        ensure_installed = { "stylua", "prettier", "yamlfmt" },
        automatic_setup = true,
    })

    null_ls.setup({
        debug = false,
        sources = {
            null_ls.builtins.code_actions.gitsigns,
            null_ls.builtins.formatting.yamlfmt,
            null_ls.builtins.formatting.prettier,
        },
        on_attach = on_attach
    })

    local cmp_nvim_lsp = require("cmp_nvim_lsp")

    local config = {
        vuels = {
            flags = { debounce_text_changes = 500 },
            init_options = {
                config = {
                    vetur = {
                        useWorkspaceDependencies = true,
                        validation = { templateProps = true },
                        experimental = { templateInterpolationService = false },
                    },
                },
            },
        },
        jsonls = {
            filetypes = { "json", "jsonc" },
            settings = {
                json = {
                    schemaDownload = { enable = true },
                    schemas = require("schemastore").json.schemas(),
                },
            },
        },
        eslint = { flags = { debounce_text_changes = 500 } },
    }

    require("mason-lspconfig").setup_handlers({
        function(server_name)
            local opts = {
                on_attach = on_attach,
                capabilities = cmp_nvim_lsp.default_capabilities(),
            }

            if server_name == "jsonls" then
                opts.capabilities.textDocument.completion.completionItem.snippetSupport = true
            end

            if config[server_name] then
                opts = vim.tbl_extend("force", opts, config[server_name])
            end

            require("lspconfig")[server_name].setup(opts)
        end,
        ["tsserver"] = function()
            local mason_registry = require('mason-registry')
            local tsserver_path = mason_registry.get_package('typescript-language-server'):get_install_path()

            require("typescript-tools").setup({
                on_attach = function(client, bufnr)
                    client.server_capabilities.documentFormattingProvider = false
                    client.server_capabilities.documentRangeFormattingProvider = false
                    on_attach(client, bufnr)
                end,
                capabilities = cmp_nvim_lsp.default_capabilities(),
                settings = {
                    tsserver_path = tsserver_path .. '/node_modules/typescript/lib/tsserver.js',
                    tsserver_file_preferences = {
                        includeInlayParameterNameHints = "all",
                        includeCompletionsForModuleExports = true,
                        quotePreference = "auto",
                    }
                }
            })
            -- require("typescript").setup({
            --     server = {
            --         debug = false,
            --         on_attach = function(client, bufnr)
            --             client.server_capabilities.documentFormattingProvider = false
            --             client.server_capabilities.documentRangeFormattingProvider = false
            --             on_attach(client, bufnr);
            --         end,
            --         capabilities = cmp_nvim_lsp.default_capabilities(),
            --         settings = {
            --             typescript = {
            --                 inlayHints = {
            --                     includeInlayParameterNameHints = "all",
            --                     includeInlayParameterNameHintsWhenArgumentMatchesName = true,
            --                     includeInlayFunctionParameterTypeHints = true,
            --                     includeInlayVariableTypeHints = false,
            --                     includeInlayPropertyDeclarationTypeHints = true,
            --                     includeInlayFunctionLikeReturnTypeHints = false,
            --                     includeInlayEnumMemberValueHints = true,
            --                 },
            --             },
            --             javascript = {
            --                 inlayHints = {
            --                     includeInlayParameterNameHints = "all",
            --                     includeInlayParameterNameHintsWhenArgumentMatchesName = true,
            --                     includeInlayFunctionParameterTypeHints = true,
            --                     includeInlayVariableTypeHints = false,
            --                     includeInlayPropertyDeclarationTypeHints = true,
            --                     includeInlayFunctionLikeReturnTypeHints = false,
            --                     includeInlayEnumMemberValueHints = true,
            --                 },
            --             },
            --         },
            --         init_options = {
            --             hostInfo = "neovim",
            --             plugins = {
            --                 {
            --                     name = "@styled/typescript-styled-plugin",
            --                     location = os.getenv("HOME") .. "/.nvm/versions/node/v16.16.0/lib"
            --                 }
            --             }
            --         }
            --     }
            -- })
        end,
        ["lua_ls"] = function()
            local neodev = require("neodev")

            neodev.setup()

            require("lspconfig").lua_ls.setup({
                on_attach = on_attach,
                capabilities = cmp_nvim_lsp.default_capabilities(),
                settings = {
                    Lua = {
                        hint = {
                            enable = true
                        },
                        completion = {
                            callSnippet = "Replace",
                        },
                    },
                },
            })
        end,
    })
end

return M
