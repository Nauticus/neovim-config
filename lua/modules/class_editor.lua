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

-- ── Known class-manipulation function names ─────────────────────────

local CLASS_FUNCS = {
    clsx = true,
    twMerge = true,
    tw = true,
    cx = true,
    cva = true,
    cls = true,
    tv = true,
}

-- ── Treesitter queries ──────────────────────────────────────────────
-- Each spec has:
--   query   — captures a parent node as @target, plus child captures as needed
--   check   — function(target_node, captures_table, bufnr) -> true/false
--   extract — function(target_node, captures_table, bufnr) -> ClassLocation

local LANG_QUERIES = {
    html = {
        -- class="value" / class='value'
        {
            query = [[
                (attribute
                    (attribute_name) @name
                    (quoted_attribute_value) @raw_value) @target
            ]],
            check = function(_target, captures, bufnr)
                local name = vim.treesitter.get_node_text(captures.name[1], bufnr)
                return name == "class"
            end,
            extract = function(_target, captures, bufnr)
                local raw_node = captures["raw_value"][1]
                -- Find attribute_value inside quoted_attribute_value
                local val_node
                for child in raw_node:iter_children() do
                    if child:type() == "attribute_value" then
                        val_node = child
                        break
                    end
                end
                val_node = val_node or raw_node
                local text = vim.treesitter.get_node_text(val_node, bufnr)
                local srow, scol, erow, ecol = val_node:range()
                return {
                    bufnr = bufnr,
                    value = strip_quotes(text),
                    wrapper = "attribute",
                    value_node = val_node,
                    value_node_start_row = srow,
                    value_node_start_col = scol,
                    value_node_end_row = erow,
                    value_node_end_col = ecol,
                }
            end,
        },
    },

    tsx = {
        -- className="value"  (plain string)
        {
            query = [[
                (jsx_attribute
                    (property_identifier) @name
                    (string) @raw_value) @target
            ]],
            check = function(_target, captures, bufnr)
                local name = vim.treesitter.get_node_text(captures.name[1], bufnr)
                return name == "className"
            end,
            extract = function(_target, captures, bufnr)
                local raw_node = captures["raw_value"][1]
                -- string_fragment inside string
                local val_node
                for child in raw_node:iter_children() do
                    if child:type() == "string_fragment" then
                        val_node = child
                        break
                    end
                end
                val_node = val_node or raw_node
                local text = vim.treesitter.get_node_text(val_node, bufnr)
                local srow, scol, erow, ecol = val_node:range()
                return {
                    bufnr = bufnr,
                    value = strip_quotes(text),
                    wrapper = "jsx_string",
                    value_node = val_node,
                    value_node_start_row = srow,
                    value_node_start_col = scol,
                    value_node_end_row = erow,
                    value_node_end_col = ecol,
                }
            end,
        },

        -- className={"value"}  (jsx_expression > string)
        {
            query = [[
                (jsx_attribute
                    (property_identifier) @name
                    (jsx_expression (string) @raw_value)) @target
            ]],
            check = function(_target, captures, bufnr)
                local name = vim.treesitter.get_node_text(captures.name[1], bufnr)
                return name == "className"
            end,
            extract = function(_target, captures, bufnr)
                local raw_node = captures["raw_value"][1]
                local val_node
                for child in raw_node:iter_children() do
                    if child:type() == "string_fragment" then
                        val_node = child
                        break
                    end
                end
                val_node = val_node or raw_node
                local text = vim.treesitter.get_node_text(val_node, bufnr)
                local srow, scol, erow, ecol = val_node:range()
                return {
                    bufnr = bufnr,
                    value = strip_quotes(text),
                    wrapper = "jsx_string",
                    value_node = val_node,
                    value_node_start_row = srow,
                    value_node_start_col = scol,
                    value_node_end_row = erow,
                    value_node_end_col = ecol,
                }
            end,
        },

        -- className={`template literal`}
        {
            query = [[
                (jsx_attribute
                    (property_identifier) @name
                    (jsx_expression (template_string) @raw_value)) @target
            ]],
            check = function(_target, captures, bufnr)
                local name = vim.treesitter.get_node_text(captures.name[1], bufnr)
                return name == "className"
            end,
            extract = function(_target, captures, bufnr)
                local tmpl_node = captures["raw_value"][1]
                local fragments = extract_template_fragments(tmpl_node, bufnr)
                local srow, scol = tmpl_node:start()
                local erow, ecol = tmpl_node:end_()
                return {
                    bufnr = bufnr,
                    value = table.concat(fragments, " "),
                    wrapper = "jsx_template",
                    value_node = tmpl_node,
                    value_node_start_row = srow,
                    value_node_start_col = scol,
                    value_node_end_row = erow,
                    value_node_end_col = ecol,
                }
            end,
        },

        -- className={clsx(...)} or className={twMerge(...)}
        {
            query = [[
                (jsx_attribute
                    (property_identifier) @name
                    (jsx_expression (call_expression) @call)) @target
            ]],
            check = function(_target, captures, bufnr)
                local name = vim.treesitter.get_node_text(captures.name[1], bufnr)
                if name ~= "className" then
                    return false
                end
                local call_node = captures.call[1]
                local ident = call_node:named_child(0)
                if not ident then
                    return false
                end
                local fname = vim.treesitter.get_node_text(ident, bufnr)
                return CLASS_FUNCS[fname] == true
            end,
            extract = function(_target, captures, bufnr)
                local call_node = captures.call[1]
                local classes = extract_call_args(call_node, bufnr)
                local srow, scol = call_node:start()
                local erow, ecol = call_node:end_()
                return {
                    bufnr = bufnr,
                    value = table.concat(classes, " "),
                    wrapper = "jsx_call",
                    call_node = call_node,
                    value_node_start_row = srow,
                    value_node_start_col = scol,
                    value_node_end_row = erow,
                    value_node_end_col = ecol,
                }
            end,
        },
    },

    -- JavaScript / TypeScript (for clsx, twMerge, etc. in .js/.ts files)
    javascript = {
        {
            query = [[
                (call_expression
                    (identifier) @fn
                    (arguments) @args) @target
            ]],
            check = function(_target, captures, bufnr)
                local fname = vim.treesitter.get_node_text(captures.fn[1], bufnr)
                return CLASS_FUNCS[fname] == true
            end,
            extract = function(target, _captures, bufnr)
                local classes = extract_call_args(target, bufnr)
                local srow, scol = target:start()
                local erow, ecol = target:end_()
                return {
                    bufnr = bufnr,
                    value = table.concat(classes, " "),
                    wrapper = "js_call",
                    call_node = target,
                    value_node_start_row = srow,
                    value_node_start_col = scol,
                    value_node_end_row = erow,
                    value_node_end_col = ecol,
                }
            end,
        },
    },

    -- CSS / SCSS — @apply
    css = {
        {
            query = [[
                (postcss_statement
                    (at_keyword) @kw
                    (plain_value) @value) @target
            ]],
            check = function(_target, captures, bufnr)
                local kw = vim.treesitter.get_node_text(captures.kw[1], bufnr)
                return kw == "@apply"
            end,
            extract = function(_target, captures, bufnr)
                local value_nodes = captures.value
                if not value_nodes or #value_nodes == 0 then
                    return nil
                end
                local classes = {}
                for _, vn in ipairs(value_nodes) do
                    local text = vim.treesitter.get_node_text(vn, bufnr)
                    for word in text:gmatch("%S+") do
                        table.insert(classes, word)
                    end
                end
                local first_row, first_col = value_nodes[1]:start()
                local last_node = value_nodes[#value_nodes]
                local last_row, last_col = last_node:end_()
                return {
                    bufnr = bufnr,
                    value = table.concat(classes, " "),
                    wrapper = "css_apply",
                    value_node_start_row = first_row,
                    value_node_start_col = first_col,
                    value_node_end_row = last_row,
                    value_node_end_col = last_col,
                }
            end,
        },
    },
}

-- Share javascript queries for typescript; css for scss
LANG_QUERIES.typescript = LANG_QUERIES.javascript
LANG_QUERIES.scss = LANG_QUERIES.css

-- ── Helpers ─────────────────────────────────────────────────────────

--- Strip surrounding quotes from text
local function strip_quotes(text)
    if #text >= 2 then
        local first = text:sub(1, 1)
        local last = text:sub(#text, #text)
        if
            (first == '"' and last == '"')
            or (first == "'" and last == "'")
            or (first == "`" and last == "`")
        then
            return text:sub(2, #text - 1)
        end
    end
    return text
end

--- Check if a node contains a given cursor position (lnum, col — both 0-indexed)
local function node_contains(node, lnum, col)
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

--- Get the detected treesitter language for a buffer
local function get_lang(bufnr)
    bufnr = bufnr or 0
    local ft = vim.bo[bufnr].filetype
    if not ft or ft == "" then
        return nil
    end
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
    }
    return ft_to_lang[ft] or nil
end

--- Get the treesitter parser for a buffer
local function get_parser(bufnr)
    bufnr = bufnr or 0
    local lang = get_lang(bufnr)
    if not lang then
        return nil
    end
    return vim.treesitter.get_parser(bufnr, lang)
end

-- ── Main extraction ─────────────────────────────────────────────────

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

        -- Group captures by match so we have all captures for each target
        for match in q:iter_matches(root, bufnr, 0, -1) do
            -- Build captures table: { name = {node}, raw_value = {node}, target = {node}, ... }
            local captures = {}
            for id, node in pairs(match) do
                local name = q.captures[id]
                if not captures[name] then
                    captures[name] = {}
                end
                captures[name][#captures[name] + 1] = node
            end

            local target_node = captures.target[1]
            if not target_node then
                goto continue
            end

            -- Check if the target node contains the cursor
            if not node_contains(target_node, lnum, col) then
                goto continue
            end

            -- Validate with spec.check
            if not spec.check(target_node, captures, bufnr) then
                goto continue
            end

            -- Extract
            local result = spec.extract(target_node, captures, bufnr)
            if result then
                return result
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
        -- Replace the text span covering all plain_value nodes
        local first_row = location.value_node_start_row
        local first_col = location.value_node_start_col
        local last_row = location.value_node_end_row
        local last_col = location.value_node_end_col

        local buf_lines = vim.api.nvim_buf_get_lines(location.bufnr, first_row, last_row + 1, false)
        local first_line = buf_lines[1]
        local last_line = buf_lines[#buf_lines]
        local before = first_line:sub(1, first_col)
        local after = last_line:sub(last_col + 1)

        if first_row == last_row then
            vim.api.nvim_buf_set_lines(
                location.bufnr,
                first_row,
                first_row + 1,
                false,
                { before .. new_value .. after }
            )
        else
            local middle = {}
            for i = 2, #buf_lines - 1 do
                table.insert(middle, buf_lines[i])
            end
            local new_lines = { before .. new_value .. after }
            for _, m in ipairs(middle) do
                table.insert(new_lines, m)
            end
            vim.api.nvim_buf_set_lines(location.bufnr, first_row, last_row + 1, false, new_lines)
        end
    elseif location.call_node then
        -- Replace the entire call expression text
        local first_row = location.value_node_start_row
        local first_col = location.value_node_start_col
        local last_row = location.value_node_end_row
        local last_col = location.value_node_end_col

        local call_text = vim.treesitter.get_node_text(location.call_node, location.bufnr)
        local fn_name = call_text:match("(%S+)%(.*")

        local classes = M.split_classes(new_value)
        local args = {}
        for _, c in ipairs(classes) do
            table.insert(args, "'" .. c .. "'")
        end
        local new_call = fn_name .. "(" .. table.concat(args, ", ") .. ")"

        local buf_lines = vim.api.nvim_buf_get_lines(location.bufnr, first_row, last_row + 1, false)
        local first_line = buf_lines[1]
        local last_line = buf_lines[#buf_lines]
        local before = first_line:sub(1, first_col)
        local after = last_line:sub(last_col + 1)

        if first_row == last_row then
            vim.api.nvim_buf_set_lines(
                location.bufnr,
                first_row,
                first_row + 1,
                false,
                { before .. new_call .. after }
            )
        else
            local middle = {}
            for i = 2, #buf_lines - 1 do
                table.insert(middle, buf_lines[i])
            end
            local new_lines = { before .. new_call .. after }
            for _, m in ipairs(middle) do
                table.insert(new_lines, m)
            end
            vim.api.nvim_buf_set_lines(location.bufnr, first_row, last_row + 1, false, new_lines)
        end
    else
        -- Standard attribute / string value replacement
        local first_row = location.value_node_start_row
        local first_col = location.value_node_start_col
        local last_row = location.value_node_end_row
        local last_col = location.value_node_end_col

        local buf_lines = vim.api.nvim_buf_get_lines(location.bufnr, first_row, last_row + 1, false)
        local first_line = buf_lines[1]
        local last_line = buf_lines[#buf_lines]
        local before = first_line:sub(1, first_col)
        local after = last_line:sub(last_col + 1)

        if first_row == last_row then
            vim.api.nvim_buf_set_lines(
                location.bufnr,
                first_row,
                first_row + 1,
                false,
                { before .. new_value .. after }
            )
        else
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
