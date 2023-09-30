return {
    "rebelot/heirline.nvim",
    enabled = false,
    config = function()
        local conditions = require("heirline.conditions")
        local utils = require("heirline.utils")
        -- the winbar parameter is optional!
        local FileNameBlock = {
            -- let's first set up some attributes needed by this component and it's children
            init = function(self)
                self.filename = vim.api.nvim_buf_get_name(0)
            end,
        }
        -- We can now define some children separately and add them later

        local FileIcon = {
            init = function(self)
                local filename = self.filename
                local extension = vim.fn.fnamemodify(filename, ":e")
                self.icon, self.icon_color = require("nvim-web-devicons").get_icon_color(filename, extension,
                    { default = true })
            end,
            provider = function(self)
                return self.icon and (self.icon .. " ")
            end,
            hl = function(self)
                return { fg = self.icon_color }
            end
        }

        local FileName = {
            provider = function(self)
                -- first, trim the pattern relative to the current directory. For other
                -- options, see :h filename-modifers
                local filename = vim.fn.fnamemodify(self.filename, ":~:.")
                if filename == "" then return "[No Name]" end
                -- now, if the filename would occupy more than 1/4th of the available
                -- space, we trim the file path to its initials
                -- See Flexible Components section below for dynamic truncation
                if not conditions.width_percent_below(#filename, 0.50) then
                    filename = vim.fn.pathshorten(filename)
                end
                return filename
            end,
            hl = { fg = utils.get_highlight("Directory").fg },
        }

        local FileFlags = {
            {
                condition = function()
                    return vim.bo.modified
                end,
                provider = "[+]",
                hl = { fg = "green" },
            },
            {
                condition = function()
                    return not vim.bo.modifiable or vim.bo.readonly
                end,
                provider = "",
                hl = { fg = "orange" },
            },
        }

        -- Now, let's say that we want the filename color to change if the buffer is
        -- modified. Of course, we could do that directly using the FileName.hl field,
        -- but we'll see how easy it is to alter existing components using a "modifier"
        -- component

        local FileNameModifer = {
            hl = function()
                if vim.bo.modified then
                    -- use `force` because we need to override the child's hl foreground
                    return { fg = "cyan", bold = true, force = true }
                end
            end,
        }
        local Align = { provider = "%=" }
        local Space = { provider = " " }

        -- let's add the children to our FileNameBlock component
        FileNameBlock = utils.insert(FileNameBlock,
            FileIcon,
            utils.insert(FileNameModifer, FileName), -- a new table where FileName is a child of FileNameModifier
            FileFlags,
            { provider = '%<' } -- this means that the statusline is cut here when there's not enough space
        )

        local Git = {
            condition = function()
                return conditions.is_git_repo() and conditions.is_active()
            end,

            init = function(self)
                self.status_dict = vim.b.gitsigns_status_dict
                self.has_changes = self.status_dict.added ~= 0 or self.status_dict.removed ~= 0 or
                    self.status_dict.changed ~= 0
            end,

            hl = { fg = "orange" },

            { -- git branch name
                provider = function(self)
                    return " " .. self.status_dict.head
                end,
                hl = { bold = true }
            },
            -- You could handle delimiters, icons and counts similar to Diagnostics
            {
                condition = function(self)
                    return self.has_changes
                end,
                provider = "("
            },
            {
                provider = function(self)
                    local count = self.status_dict.added or 0
                    return count > 0 and ("+" .. count)
                end,
                hl = "GitSignsAdd",
            },
            {
                provider = function(self)
                    local count = self.status_dict.removed or 0
                    return count > 0 and ("-" .. count)
                end,
                hl = "GitSignsDelete",
            },
            {
                provider = function(self)
                    local count = self.status_dict.changed or 0
                    return count > 0 and ("~" .. count)
                end,
                hl = "GitSignsChange",
            },
            {
                condition = function(self)
                    return self.has_changes
                end,
                provider = ")",
            },
        }

        local Diagnostics = {

            condition = conditions.has_diagnostics,

            static = {
                error_icon = "",
                warn_icon = "",
                info_icon = "",
                hint_icon = "",
            },

            init = function(self)
                self.errors = #vim.diagnostic.get(0, { severity = vim.diagnostic.severity.ERROR })
                self.warnings = #vim.diagnostic.get(0, { severity = vim.diagnostic.severity.WARN })
                self.hints = #vim.diagnostic.get(0, { severity = vim.diagnostic.severity.HINT })
                self.info = #vim.diagnostic.get(0, { severity = vim.diagnostic.severity.INFO })
            end,

            update = { "DiagnosticChanged", "BufEnter" },

            {
                provider = function(self)
                    -- 0 is just another output, we can decide to print it or not!
                    return self.errors > 0 and (self.errors .. " ")
                end,
                hl = { fg = "diag_error" },
            },
            {
                provider = function(self)
                    return self.warnings > 0 and (self.warnings .. " ")
                end,
                hl = { fg = "diag_warn" },
            },
            {
                provider = function(self)
                    return self.info > 0 and (self.info .. " ")
                end,
                hl = { fg = "diag_info" },
            },
            {
                provider = function(self)
                    return self.hints > 0 and (self.hints)
                end,
                hl = { fg = "diag_hint" },
            },
        }

        local LSPActive = {
            condition = function()
                return conditions.lsp_attached() and conditions.is_active()
            end,
            update    = { 'LspAttach', 'LspDetach' },

            provider  = function()
                local names = {}
                for _, server in pairs(vim.lsp.get_clients({ bufnr = 0 })) do
                    table.insert(names, server.name)
                end
                return " [" .. table.concat(names, " ") .. "]"
            end,
            hl        = { fg = "green", bold = true },
        }

        -- I take no credits for this! :lion:
        local ScrollBar = {
            static = {
                sbar = { '▁', '▂', '▃', '▄', '▅', '▆', '▇', '█' }
                -- Another variant, because the more choice the better.
                -- sbar = { '🭶', '🭷', '🭸', '🭹', '🭺', '🭻' }
            },
            provider = function(self)
                local curr_line = vim.api.nvim_win_get_cursor(0)[1]
                local lines = vim.api.nvim_buf_line_count(0)
                local i = math.floor((curr_line - 1) / lines * #self.sbar) + 1
                return string.rep(self.sbar[i], 2)
            end,
            hl = { fg = "blue", bg = "bright_bg" },
        }

        local colors = require("catppuccin.palettes").get_palette "mocha"
        if colors ~= nil then
            require("heirline").load_colors({
                bright_bg = colors.base,
                bright_fg = utils.get_highlight("Folded").fg,
                red = utils.get_highlight("DiagnosticError").fg,
                dark_red = utils.get_highlight("DiffDelete").bg,
                green = utils.get_highlight("String").fg,
                blue = utils.get_highlight("Function").fg,
                gray = utils.get_highlight("NonText").fg,
                orange = utils.get_highlight("Constant").fg,
                purple = utils.get_highlight("Statement").fg,
                cyan = utils.get_highlight("Special").fg,
                diag_warn = utils.get_highlight("DiagnosticWarn").fg,
                diag_error = utils.get_highlight("DiagnosticError").fg,
                diag_hint = utils.get_highlight("DiagnosticHint").fg,
                diag_info = utils.get_highlight("DiagnosticInfo").fg,
                git_del = utils.get_highlight("diffDeleted").fg,
                git_add = utils.get_highlight("diffAdded").fg,
                git_change = utils.get_highlight("diffChanged").fg,
            })
        end


        require("heirline").setup({
            winbar = { hl = "NWinBar", FileNameBlock, Align, Git, Space, ScrollBar },
            opts = {
                disable_winbar_cb = function(args)
                    return conditions.buffer_matches({
                        buftype = { "nofile", "prompt", "help", "quickfix" },
                        filetype = { "^git.*", "^oil.*", "fugitive", "Trouble", "dashboard" },
                    }, args.buf)
                end,
            }
        })
    end
}
