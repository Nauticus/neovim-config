--- class_editor.lua (experimental)
--- Opens class attributes in a vertical split with one class per line.
--- Save the scratch buffer to write changes back to the original file.
---
--- Uses treesitter queries to find class values across many languages:
---   html/jsx/tsx/vue/svelte/astro  — class / className attributes
---   css/scss                       — @apply directives
---   javascript/typescript          — clsx, twMerge, tw, cx calls
---
--- Usage: place cursor on/inside a class attribute and trigger the keybind.
---
--- Keybinds in the scratch buffer:
---   <C-s> / :w  — save changes back and close the scratch buffer
---   <C-q>        — close without saving

local M = {}

-- ── Treesitter queries ──────────────────────────────────────────────
-- Each entry: { query, extractor }
-- The extractor receives (node, bufnr) and returns a ClassLocation or nil.

local LANG_QUERIES = {
    -- HTML (and variants: htmldjango, svelte, astro, blade, vue-html)
    html = {
        -- class="value" / class='value'
        {
            query = [[
                (attribute
                    (attribute_name) @attr_name
                    (quoted_attribute_value) @attr_value)
            ]],
            attr_predicate = function(name_node, _bufnr)
                local name = vim.treesitter.get_node_text(name_node, _bufnr)
                return name == "class"
            end,
            value_node = function(_parent, value_node, bufnr)
                -- attribute_value is a child of quoted_attribute_value
                for child in value_node:iter_children() do
                    if child:type() == "attribute_value" then
                        return child
                    end
                end
                -- fallback: use the quoted_attribute_value itself (strip quotes later)
                return value_node
            end,
            wrapper = "attribute",
        },
    },

    -- TSX / JSX
    tsx = {
        -- className="value"  (plain string)
        {
            query = [[
                (jsx_attribute
                    (property_identifier) @attr_name
                    (string) @attr_value)
            ]],
            attr_predicate = function(name_node, _bufnr)
                local name = vim.treesitter.get_node_text(name_node, _bufnr)
                return name == "className"
            end,
            value_node = function(_parent, value_node, bufnr)
                -- string_fragment is a child of string
                for child in value_node:iter_children() do
                    if child:type() == "string_fragment" then
                        return child
                    end
                end
                return value_node
            end,
            wrapper = "jsx_string",
        },
        -- className={"value"}  (jsx_expression > string)
        {
            query = [[
                (jsx_attribute
                    (property_identifier) @attr_name
                    (jsx_expression (string) @attr_value))
            ]],
            attr_predicate = function(name_node, _bufnr)
                local name = vim.treesitter.get_node_text(name_node, _bufnr)
                return name == "className"
            end,
            value_node = function(_parent, value_node, bufnr)
                for child in value_node:iter_children() do
                    if child:type() == "string_fragment" then
                        return child
                    end
                end
                return value_node
            end,
            wrapper = "jsx_string",
        },
        -- className={`template literal`}
        {
            query = [[
                (jsx_attribute
                    (property_identifier) @attr_name
                    (jsx_expression (template_string) @attr_value))
            ]],
            attr_predicate = function(name_node, _bufnr)
                local name = vim.treesitter.get_node_text(name_node, _bufnr)
                return name == "className"
            end,
            value_node = function(_parent, value_node, _bufnr)
                -- Returns the whole template_string; we'll extract string_fragments
                return value_node
            end,
            wrapper = "jsx_template",
        },
        -- className={clsx(...)} or className={twMerge(...)}
        {
            query = [[
                (jsx_attribute
                    (property_identifier) @attr_name
                    (jsx_expression (call_expression) @call))
            ]],
            attr_predicate = function(name_node, _bufnr)
                local name = vim.treesitter.get_node_text(name_node, _bufnr)
                return name == "className"
            end,
            call_predicate = function(call_node, bufnr)
                local ident = call_node:named_child(0)
                if not ident then
                    return false
                end
                local name = vim.treesitter.get_node_text(ident, bufnr)
                return name == "clsx"
                    or name == "twMerge"
                    or name == "tw"
                    or name == "cx"
                    or name == "cva"
                    or name == "cls"
                    or name == "tv"
            end,
            wrapper = "jsx_call",
        },
    },

    -- JavaScript / TypeScript (for clsx, twMerge, etc. in .js/.ts files)
    javascript = {
        {
            query = [[
                (call_expression
                    (identifier) @fn_name
                    (arguments) @args)
            ]],
            call_predicate = function(call_node, bufnr)
                local ident = call_node:named_child(0)
                if not ident then
                    return false
                end
                local name = vim.treesitter.get_node_text(ident, bufnr)
                return name == "clsx"
                    or name == "twMerge"
                    or name == "tw"
                    or name == "cx"
                    or name == "cva"
                    or name == "cls"
                    or name == "tv"
            end,
            wrapper = "js_call",
        },
    },
    typescript = {
        -- reuse javascript queries (same AST shape)
    },

    -- CSS / SCSS — @apply
    css = {
        {
            query = [[
                (postcss_statement
                    (at_keyword) @kw
                    (plain_value) @value)
            ]],
            kw_predicate = function(kw_node, bufnr)
                local text = vim.treesitter.get_node_text(kw_node, bufnr)
                return text == "@apply"
            end,
            wrapper = "css_apply",
        },
    },
    scss = {
        -- same as css
    },
}

-- Share javascript queries for typescript
if LANG_QUERIES.typescript then
    LANG_QUERIES.typescript = LANG_QUERIES.javascript
end
if LANG_QUERIES.scss then
    LANG_QUERIES.scss = LANG_QUERIES.css
end

-- ── Helpers ─────────────────────────────────────────────────────────

--- Get the language tree for a buffer
local function get_parser(bufnr)
    bufnr = bufnr or 0
    local ft = vim.bo[bufnr].filetype
    local lang = vim.treesitter.language.get_lang(ft)
    if not lang then
        return nil
    end
    return vim.treesitter.get_parser(bufnr, lang)
end

--- Check if a node contains a given cursor position (lnum, col — both 0-indexed)
local function node_contains(node, lnum, col, bufnr)
    bufnr = bufnr or 0
    local srow, scol, erow, ecol = node:range()
    return lnum >= srow
        and lnum <= erow
        and (lnum > srow or col >= scol)
        and (lnum < erow or col <= ecol)
end

--- Extract string_fragments from a template_string node
local function extract_template_fragments(node, bufnr)
    local fragments = {}
    for child in node:iter_children() do
        if child:type() == "string_fragment" then
            local text = vim.treesitter.get_node_text(child, bufnr)
            for word in text:gmatch("%S+") do
                if word:len() > 0 then
                    table.insert(fragments, word)
                end
            end
        end
    end
    return fragments
end

--- Extract classes from a call_expression's arguments
local function extract_call_args(call_node, bufnr)
    local classes = {}
    local args = call_node:field("arguments")[1]
    if not args then
        return classes
    end
    for child in args:iter_children() do
        if child:type() == "string" then
            for sc in child:iter_children() do
                if sc:type() == "string_fragment" then
                    local text = vim.treesitter.get_node_text(sc, bufnr)
                    for word in text:gmatch("%S+") do
                        if word:len() > 0 then
                            table.insert(classes, word)
                        end
                    end
                end
            end
        elseif child:type() == "template_string" then
            for _, frag in ipairs(extract_template_fragments(child, bufnr)) do
                table.insert(classes, frag)
            end
        end
    end
    return classes
end

--- Strip surrounding quotes from text
local function strip_quotes(text)
    local stripped = text
    if #stripped >= 2 then
        local first = stripped:sub(1, 1)
        local last = stripped:sub(#stripped, #stripped)
        if
            (first == '"' and last == '"')
            or (first == "'" and last == "'")
            or (first == "`" and last == "`")
        then
            stripped = stripped:sub(2, #stripped - 1)
        end
    end
    return stripped
end

--- Get the detected language for a buffer
local function get_lang(bufnr)
    bufnr = bufnr or 0
    local ft = vim.bo[bufnr].filetype
    local lang = vim.treesitter.language.get_lang(ft)
    if lang then
        return lang
    end
    -- Fallback: map common filetypes to languages
    local ft_to_lang = {
        vue = "html",
        svelte = "html",
        astro = "html",
        ejs = "html",
        htmldjango = "html",
        blade = "html",
        javascriptreact = "tsx",
        typescriptreact = "tsx",
        jsx = "tsx",
    }
    return ft_to_lang[ft] or nil
end

-- ── Main extraction ─────────────────────────────────────────────────

--- ClassLocation describes where the classes live and how to modify them.
--- {
---   bufnr,
---   value       — the full class string (e.g. "bg-red-500 text-white"),
---   text        — original raw text of the value node(s),
---   wrapper     — type string identifying the context,
---   lines_start, lines_end  — buf lines affected (0-indexed, inclusive end for multi-line),
---   lines       — original buffer lines in the range,
---   -- For attribute value replacement:
---   value_node_start_row, value_node_start_col,
---   value_node_end_row, value_node_end_col,
---   -- For @apply: list of plain_value nodes
---   apply_nodes,
---   -- For call args:
---   call_node,
---   -- For template strings:
---   template_node,
--- }
function M.extract(bufnr)
    bufnr = bufnr or 0
    local cursor = vim.api.nvim_win_get_cursor(0)
    local lnum = cursor[1] - 1 -- 0-indexed
    local col = cursor[2]

    local lang = get_lang(bufnr)
    if not lang then
        return nil
    end

    local queries = LANG_QUERIES[lang]
    if not queries then
        return nil
    end

    local parser = get_parser(bufnr)
    if not parser then
        return nil
    end

    local tree = parser:parse()[1]
    if not tree then
        return nil
    end
    local root = tree:root()

    -- For each query pattern
    for _, spec in ipairs(queries) do
        local q = vim.treesitter.query.parse(lang, spec.query)
        for id, node, _metadata in q:iter_captures(root, bufnr, 0, -1) do
            local capture_name = q.captures[id]

            -- Check if the node is under or near the cursor
            if not node_contains(node, lnum, col, bufnr) then
                goto continue
            end

            if capture_name == "attr_name" and spec.attr_predicate then
                -- Validate the attribute name
                if not spec.attr_predicate(node, bufnr) then
                    goto continue
                end
                -- Find the sibling value node (same parent)
                local parent = node:parent()
                if not parent then
                    goto continue
                end

                -- Find the matching value capture in the same parent
                for child in parent:iter_children() do
                    -- Check if this child matched as attr_value
                    local child_row, child_col = child:start()
                    -- We need to check if the cursor is in the attribute region
                    if node_contains(parent, lnum, col, bufnr) then
                        if spec.value_node then
                            -- Find the quoted_attribute_value or string child
                            for sibling in parent:iter_children() do
                                local sib_type = sibling:type()
                                if sib_type == "quoted_attribute_value" or sib_type == "string" then
                                    local val_node = spec.value_node(parent, sibling, bufnr)
                                    if val_node then
                                        local text = vim.treesitter.get_node_text(val_node, bufnr)
                                        local srow, scol, erow, ecol = val_node:range()
                                        return {
                                            bufnr = bufnr,
                                            value = strip_quotes(text),
                                            wrapper = spec.wrapper or "attribute",
                                            value_node = val_node,
                                            value_node_start_row = srow,
                                            value_node_start_col = scol,
                                            value_node_end_row = erow,
                                            value_node_end_col = ecol,
                                            call_node = nil,
                                        }
                                    end
                                end
                            end
                        end
                        break
                    end
                end
            end

            if capture_name == "kw" and spec.kw_predicate then
                -- @apply directive
                if spec.kw_predicate(node, bufnr) then
                    local parent = node:parent()
                    if not parent then
                        goto continue
                    end
                    local apply_nodes = {}
                    for child in parent:iter_children() do
                        if child:type() == "plain_value" then
                            table.insert(apply_nodes, child)
                        end
                    end
                    if #apply_nodes == 0 then
                        goto continue
                    end

                    local classes = {}
                    for _, anode in ipairs(apply_nodes) do
                        local text = vim.treesitter.get_node_text(anode, bufnr)
                        for word in text:gmatch("%S+") do
                            table.insert(classes, word)
                        end
                    end
                    local first_row, first_col = apply_nodes[1]:start()
                    local last_node = apply_nodes[#apply_nodes]
                    local last_row, last_col = last_node:end_()

                    return {
                        bufnr = bufnr,
                        value = table.concat(classes, " "),
                        wrapper = "css_apply",
                        apply_nodes = apply_nodes,
                        value_node_start_row = first_row,
                        value_node_start_col = first_col,
                        value_node_end_row = last_row,
                        value_node_end_col = last_col,
                    }
                end
            end

            if capture_name == "call" and spec.call_predicate then
                if spec.call_predicate(node, bufnr) then
                    local classes = extract_call_args(node, bufnr)
                    local srow, scol = node:start()
                    local erow, ecol = node:end_()
                    return {
                        bufnr = bufnr,
                        value = table.concat(classes, " "),
                        wrapper = spec.wrapper or "js_call",
                        call_node = node,
                        value_node_start_row = srow,
                        value_node_start_col = scol,
                        value_node_end_row = erow,
                        value_node_end_col = ecol,
                    }
                end
            end

            ::continue::
        end
    end

    return nil
end

-- ── Split / Join ────────────────────────────────────────────────────

function M.split_classes(value)
    local classes = {}
    for word in value:gmatch("%S+") do
        if word:len() > 0 then
            table.insert(classes, word)
        end
    end
    return classes
end

function M.join_classes(lines)
    local classes = {}
    for _, line in ipairs(lines) do
        local trimmed = line:match("^%s*(.-)%s*$")
        if trimmed:len() > 0 then
            table.insert(classes, trimmed)
        end
    end
    return table.concat(classes, " ")
end

-- ── Save back ───────────────────────────────────────────────────────

function M:save(location)
    local lines = vim.api.nvim_buf_get_lines(0, 0, -1, false)
    local new_value = M.join_classes(lines)

    if location.wrapper == "css_apply" then
        -- Replace each plain_value node's text, keeping one class per node
        -- For simplicity: replace all plain_values with the new classes
        -- and add/remove nodes as needed. Since TS nodes aren't editable,
        -- we replace the text in the buffer.
        local first_row = location.value_node_start_row
        local first_col = location.value_node_start_col
        local last_row = location.value_node_end_row
        local last_col = location.value_node_end_col

        if first_row == last_row then
            local buf_lines =
                vim.api.nvim_buf_get_lines(location.bufnr, first_row, first_row + 1, false)
            local line = buf_lines[1]
            local before = line:sub(1, first_col)
            local after = line:sub(last_col + 1)
            local new_line = before .. new_value .. after
            vim.api.nvim_buf_set_lines(
                location.bufnr,
                first_row,
                first_row + 1,
                false,
                { new_line }
            )
        else
            -- Multi-line @apply (rare but possible)
            local buf_lines =
                vim.api.nvim_buf_get_lines(location.bufnr, first_row, last_row + 1, false)
            local first_line = buf_lines[1]
            local last_line = buf_lines[#buf_lines]
            local before = first_line:sub(1, first_col)
            local after = last_line:sub(last_col + 1)

            -- Collect middle lines
            local middle = {}
            for i = 2, #buf_lines - 1 do
                table.insert(middle, buf_lines[i])
            end

            local new_lines = { before .. new_value .. after }
            for _, m in ipairs(middle) do
                table.insert(new_lines, m)
            end
            -- Remove extra lines
            vim.api.nvim_buf_set_lines(location.bufnr, first_row, last_row + 1, false, new_lines)
        end
    elseif location.call_node then
        -- Replace the entire call expression text
        local first_row = location.value_node_start_row
        local first_col = location.value_node_start_col
        local last_row = location.value_node_end_row
        local last_col = location.value_node_end_col

        -- Rebuild the call: fn_name(classes, ...)
        local call_text = vim.treesitter.get_node_text(location.call_node, location.bufnr)
        local fn_name = call_text:match("(%S+)%(.*")

        if first_row == last_row then
            local buf_lines =
                vim.api.nvim_buf_get_lines(location.bufnr, first_row, first_row + 1, false)
            local line = buf_lines[1]
            local before = line:sub(1, first_col)
            local after = line:sub(last_col + 1)

            -- Rebuild call with new classes as string args
            local classes = M.split_classes(new_value)
            local args = {}
            for _, c in ipairs(classes) do
                table.insert(args, "'" .. c .. "'")
            end
            local new_call = fn_name .. "(" .. table.concat(args, ", ") .. ")"
            local new_line = before .. new_call .. after
            vim.api.nvim_buf_set_lines(
                location.bufnr,
                first_row,
                first_row + 1,
                false,
                { new_line }
            )
        else
            -- Multi-line call — just replace the whole region
            local buf_lines =
                vim.api.nvim_buf_get_lines(location.bufnr, first_row, last_row + 1, false)
            local first_line = buf_lines[1]
            local last_line = buf_lines[#buf_lines]
            local before = first_line:sub(1, first_col)
            local after = last_line:sub(last_col + 1)

            local classes = M.split_classes(new_value)
            local args = {}
            for _, c in ipairs(classes) do
                table.insert(args, "'" .. c .. "'")
            end
            local new_call = fn_name .. "(" .. table.concat(args, ", ") .. ")"
            local new_lines = { before .. new_call .. after }
            vim.api.nvim_buf_set_lines(location.bufnr, first_row, last_row + 1, false, new_lines)
        end
    else
        -- Standard attribute / string value replacement
        local first_row = location.value_node_start_row
        local first_col = location.value_node_start_col
        local last_row = location.value_node_end_row
        local last_col = location.value_node_end_col

        if first_row == last_row then
            local buf_lines =
                vim.api.nvim_buf_get_lines(location.bufnr, first_row, first_row + 1, false)
            local line = buf_lines[1]
            local before = line:sub(1, first_col)
            local after = line:sub(last_col + 1)
            local new_line = before .. new_value .. after
            vim.api.nvim_buf_set_lines(
                location.bufnr,
                first_row,
                first_row + 1,
                false,
                { new_line }
            )
        else
            -- Multi-line value (template literals etc.)
            local buf_lines =
                vim.api.nvim_buf_get_lines(location.bufnr, first_row, last_row + 1, false)
            local first_line = buf_lines[1]
            local last_line = buf_lines[#buf_lines]
            local before = first_line:sub(1, first_col)
            local after = last_line:sub(last_col + 1)

            local new_lines = { before .. new_value .. after }
            vim.api.nvim_buf_set_lines(location.bufnr, first_row, last_row + 1, false, new_lines)
        end
    end

    -- Notify
    local class_count = 0
    for _ in new_value:gmatch("%S+") do
        class_count = class_count + 1
    end
    vim.notify(
        string.format("Updated %d class(es)", class_count),
        vim.log.levels.INFO,
        { title = "Class Editor" }
    )

    -- Close the scratch buffer
    vim.cmd("bdelete!")
    vim.cmd("close")
end

-- ── Quit ────────────────────────────────────────────────────────────

function M:quit()
    vim.cmd("bdelete!")
    vim.cmd("close")
end

-- ── Open ────────────────────────────────────────────────────────────

function M.open()
    local bufnr = 0
    local location = M.extract(bufnr)
    if not location then
        vim.notify(
            "No class attribute or @apply found under cursor",
            vim.log.levels.WARN,
            { title = "Class Editor" }
        )
        return
    end

    local classes = M.split_classes(location.value)
    if #classes == 0 then
        vim.notify("Class attribute is empty", vim.log.levels.WARN, { title = "Class Editor" })
        return
    end

    -- Create a vertical split
    vim.cmd("vsplit")
    local new_win = vim.api.nvim_get_current_win()
    local new_buf = vim.api.nvim_create_buf(false, true) -- scratch
    vim.api.nvim_win_set_buf(new_win, new_buf)

    -- Set the class lines
    vim.api.nvim_buf_set_lines(new_buf, 0, -1, false, classes)

    -- Configure the buffer
    vim.api.nvim_set_option_value("buftype", "nofile", { buf = new_buf })
    vim.api.nvim_set_option_value("bufhidden", "wipe", { buf = new_buf })
    vim.api.nvim_set_option_value("swapfile", false, { buf = new_buf })
    vim.api.nvim_set_option_value("modifiable", true, { buf = new_buf })
    vim.api.nvim_set_option_value("syntax", "", { buf = new_buf })
    vim.api.nvim_set_option_value("filetype", "class_editor", { buf = new_buf })
    vim.api.nvim_buf_set_name(new_buf, "Class Editor [" .. location.wrapper .. "]")

    -- Store state in the window's t[] table
    vim.t[new_win] = {
        location = location,
    }

    -- Keymaps for the scratch buffer
    vim.keymap.set("n", "<C-s>", function()
        local state = vim.t[vim.api.nvim_get_current_win()]
        if state then
            M.save(state.location)
        end
    end, { buf = new_buf, desc = "Save classes back to file" })

    vim.keymap.set("i", "<C-s>", function()
        vim.api.nvim_feedkeys(
            vim.api.nvim_replace_termcodes("<Esc>", true, false, true),
            "n",
            false
        )
        local state = vim.t[vim.api.nvim_get_current_win()]
        if state then
            M.save(state.location)
        end
    end, { buf = new_buf, desc = "Save classes back to file" })

    vim.keymap.set({ "n", "i" }, "<C-q>", function()
        vim.cmd("bdelete!")
        vim.cmd("close")
    end, { buf = new_buf, desc = "Close without saving" })

    -- Override :write to call save
    vim.api.nvim_create_autocmd("BufWriteCmd", {
        buffer = new_buf,
        callback = function()
            local state = vim.t[vim.api.nvim_get_current_win()]
            if state then
                M.save(state.location)
            end
        end,
    })

    -- Set cursor to first class
    vim.api.nvim_win_set_cursor(new_win, { 1, 0 })

    vim.notify(
        string.format(
            "Opened %d class(es) [%s] — <C-s> save, <C-q> quit",
            #classes,
            location.wrapper
        ),
        vim.log.levels.INFO,
        { title = "Class Editor" }
    )
end

return M
