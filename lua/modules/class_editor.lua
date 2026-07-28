--- class_editor.lua
--- Opens class attributes in a vertical split with one class per line.
--- Save the scratch buffer to write changes back to the original file.
---
--- Usage: place cursor on/inside a class attribute and trigger the keybind.
---
--- Keybinds in the scratch buffer:
---   <C-s> / :w  — save changes back and close the scratch buffer
---   <C-q> / :q  — close without saving

local M = {}

local DELIMITER_PATTERN = '["`{]'

--- Find the class attribute value under the cursor.
--- Returns { value, bufnr, lnum, quote_char, has_braces, full_line }
function M._extract_class()
    local bufnr = 0
    local cursor = vim.api.nvim_win_get_cursor(0)
    local lnum = cursor[1]

    local line = vim.api.nvim_buf_get_lines(bufnr, lnum - 1, lnum, true)[1]
    if not line then
        return nil
    end

    local eq_pos = line:find("class=", 1, true)
    if not eq_pos then
        return nil
    end

    -- Try to match the value
    local patterns = {
        'class=[{]*"([^"]*)"',
        "class=[{]*'([^']*)'",
        "class=[{]*`([^`]*)`",
    }

    local quote_char = '"'
    local has_braces = false
    local value = ""

    for _, pat in ipairs(patterns) do
        value = line:match(pat)
        if value and value:len() > 0 then
            -- Determine quote type and braces
            local after_eq = line:sub(eq_pos + 6, eq_pos + 6)
            has_braces = (after_eq == "{")
            if has_braces then
                quote_char = line:sub(eq_pos + 7, eq_pos + 7)
            else
                quote_char = after_eq
            end
            break
        end
    end

    if value:len() == 0 then
        return nil
    end

    return {
        value = value,
        bufnr = bufnr,
        lnum = lnum,
        quote_char = quote_char,
        has_braces = has_braces,
        full_line = line,
    }
end

--- Try to extract class from nearby lines
function M._extract_class_from_context()
    local bufnr = 0
    local lnum = vim.api.nvim_win_get_cursor(0)[1]
    local line_count = vim.api.nvim_buf_line_count(bufnr)

    for offset = -5, 5 do
        if offset == 0 then
            goto continue
        end
        local check_lnum = lnum + offset
        if check_lnum < 1 or check_lnum > line_count then
            goto continue
        end

        local check_line = vim.api.nvim_buf_get_lines(bufnr, check_lnum - 1, check_lnum, true)[1]
        if not check_line then
            goto continue
        end

        local eq_pos = check_line:find("class=", 1, true)
        if not eq_pos then
            goto continue
        end

        local patterns = {
            'class=[{]*"([^"]*)"',
            "class=[{]*'([^']*)'",
            "class=[{]*`([^`]*)`",
        }

        for _, pat in ipairs(patterns) do
            local value = check_line:match(pat)
            if value and value:len() > 0 then
                local after_eq = check_line:sub(eq_pos + 6, eq_pos + 6)
                local has_braces = (after_eq == "{")
                local quote_char = '"'
                if has_braces then
                    quote_char = check_line:sub(eq_pos + 7, eq_pos + 7)
                else
                    quote_char = after_eq
                end

                return {
                    value = value,
                    bufnr = bufnr,
                    lnum = check_lnum,
                    quote_char = quote_char,
                    has_braces = has_braces,
                    full_line = check_line,
                }
            end
        end

        ::continue::
    end

    return nil
end

--- Split the class string into individual classes (one per line)
function M._split_classes(value)
    local classes = {}
    for word in value:gmatch("%S+") do
        if word:len() > 0 then
            table.insert(classes, word)
        end
    end
    return classes
end

--- Join classes (lines) back into a single space-separated string
function M._join_classes(lines)
    local classes = {}
    for _, line in ipairs(lines) do
        local trimmed = line:match("^%s*(.-)%s*$")
        if trimmed:len() > 0 then
            table.insert(classes, trimmed)
        end
    end
    return table.concat(classes, " ")
end

--- Write the scratch buffer content back to the original file
function M:save()
    local state = vim.t[vim.api.nvim_get_current_win()]
    if not state or not state.original_bufnr then
        vim.notify("No class editor state found", vim.log.levels.WARN)
        return
    end

    local orig_bufnr = state.original_bufnr
    local orig_lnum = state.original_lnum
    local quote_char = state.quote_char
    local has_braces = state.has_braces

    -- Get current lines from scratch buffer
    local lines = vim.api.nvim_buf_get_lines(0, 0, -1, false)
    local new_value = M._join_classes(lines)

    -- Get the original line from the source buffer
    local orig_lines = vim.api.nvim_buf_get_lines(orig_bufnr, orig_lnum - 1, orig_lnum, true)
    if not orig_lines[1] then
        vim.notify("Original line no longer exists", vim.log.levels.ERROR)
        return
    end

    local orig_line = orig_lines[1]
    local eq_pos = orig_line:find("class=", 1, true)
    if not eq_pos then
        vim.notify("Could not find class= in original line", vim.log.levels.ERROR)
        return
    end

    -- Find the opening and closing delimiters
    local after_eq = orig_line:sub(eq_pos + 6, eq_pos + 6)
    local open_delim, close_delim

    if has_braces then
        open_delim = "{" .. quote_char
        close_delim = quote_char .. "}"
    else
        open_delim = after_eq
        close_delim = after_eq
    end

    -- Find the closing delimiter position
    local close_pos = orig_line:find(close_delim, eq_pos + 6, true)
    if not close_pos then
        vim.notify("Could not find closing delimiter", vim.log.levels.ERROR)
        return
    end

    local before = orig_line:sub(1, eq_pos + 5) -- up to and including class=
    local after = orig_line:sub(close_pos + close_delim:len())

    local new_line = before .. open_delim .. new_value .. close_delim .. after

    -- Replace the line in the original buffer
    vim.api.nvim_buf_set_lines(orig_bufnr, orig_lnum - 1, orig_lnum, false, { new_line })

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

--- Quit without saving
function M:quit()
    vim.cmd("bdelete!")
    vim.cmd("close")
end

--- Open the class editor
function M.open()
    local info = M._extract_class()
    if not info then
        info = M._extract_class_from_context()
    end
    if not info then
        vim.notify(
            "No class attribute found under cursor",
            vim.log.levels.WARN,
            { title = "Class Editor" }
        )
        return
    end

    local classes = M._split_classes(info.value)
    if #classes == 0 then
        vim.notify("Class attribute is empty", vim.log.levels.WARN, { title = "Class Editor" })
        return
    end

    -- Create a vertical split
    vim.cmd("vsplit")
    local new_win = vim.api.nvim_get_current_win()
    local new_buf = vim.api.nvim_create_buf(false, true) -- scratch, unlisted
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
    vim.api.nvim_buf_set_name(new_buf, "Class Editor")

    -- Store state in the window's t[] table
    local state = {
        original_bufnr = info.bufnr,
        original_lnum = info.lnum,
        quote_char = info.quote_char or '"',
        has_braces = info.has_braces or false,
    }
    vim.t[new_win] = state

    -- Keymaps for the scratch buffer
    vim.keymap.set("n", "<C-s>", function()
        M.save(vim.t[vim.api.nvim_get_current_win()])
    end, { buf = new_buf, desc = "Save classes back to file" })

    vim.keymap.set("i", "<C-s>", function()
        vim.api.nvim_feedkeys(
            vim.api.nvim_replace_termcodes("<Esc>", true, false, true),
            "n",
            false
        )
        M.save(vim.t[vim.api.nvim_get_current_win()])
    end, { buf = new_buf, desc = "Save classes back to file" })

    vim.keymap.set({ "n", "i" }, "<C-q>", function()
        vim.cmd("bdelete!")
        vim.cmd("close")
    end, { buf = new_buf, desc = "Close without saving" })

    -- Override :write to call save
    vim.api.nvim_create_autocmd("BufWriteCmd", {
        buffer = new_buf,
        callback = function()
            M.save(vim.t[vim.api.nvim_get_current_win()])
        end,
    })

    -- Set cursor to first class
    vim.api.nvim_win_set_cursor(new_win, { 1, 0 })

    vim.notify(
        string.format("Opened %d class(es) — <C-s> save, <C-q> quit", #classes),
        vim.log.levels.INFO,
        { title = "Class Editor" }
    )
end

return M
