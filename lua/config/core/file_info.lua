--- Module that gathers orientation information about the current buffer.
local M = {}

--- Build a summary of the current buffer.
-- Returns a two-line string: a metadata line and the current line contents.
-- @return string formatted info
function M.build()
    local path = vim.fn.expand("%:.") -- path relative to cwd
    if path == "%" or path == "" then
        path = vim.fn.expand("%:p")
    end
    local line = vim.fn.line(".")
    local col = vim.fn.col(".")
    local line_text = vim.fn.getline(".")

    -- git branch and whole-file diff stats (via gitsigns buffer variables)
    local branch, diff = "(no branch)", "(unknown)"
    if vim.b.gitsigns_status_dict then
        local sd = vim.b.gitsigns_status_dict
        branch = vim.b.gitsigns_head or sd.head or "(no branch)"
        local a, c, r = sd.added or 0, sd.changed or 0, sd.removed or 0
        if a == 0 and c == 0 and r == 0 then
            diff = "clean"
        else
            diff = string.format("+%d/~%d/-%d", a, c, r)
        end
    end

    local ft = vim.bo.filetype or ""
    local lang = ft ~= "" and string.format("[%s] ", ft) or ""
    local meta = string.format("%s | L%d:C%d | %s | %s%s", path, line, col, branch, lang, diff)
    return string.format("%s\n%s", meta, line_text)
end

--- Build info for a visual selection (range of lines).
-- @param range_start line number of selection start (1-based)
-- @param range_end line number of selection end (1-based)
-- @return string formatted info
function M.build_selection(range_start, range_end)
    local path = vim.fn.expand("%:.")
    if path == "%" or path == "" then
        path = vim.fn.expand("%:p")
    end

    local branch, diff = "(no branch)", "(unknown)"
    if vim.b.gitsigns_status_dict then
        local sd = vim.b.gitsigns_status_dict
        branch = vim.b.gitsigns_head or sd.head or "(no branch)"
        local a, c, r = sd.added or 0, sd.changed or 0, sd.removed or 0
        if a == 0 and c == 0 and r == 0 then
            diff = "clean"
        else
            diff = string.format("+%d/~%d/-%d", a, c, r)
        end
    end

    local selected_lines = vim.fn.getline(range_start, range_end)
    local line_text = table.concat(selected_lines, "\n")
    local line_count = #selected_lines

    local ft = vim.bo.filetype or ""
    local lang = ft ~= "" and string.format("[%s] ", ft) or ""
    local meta
    if line_count == 1 then
        meta = string.format("%s | L%d | %s | %s%s", path, range_start, branch, lang, diff)
    else
        meta = string.format("%s | L%d-L%d (%d lines) | %s | %s%s", path, range_start, range_end, line_count, branch, lang, diff)
    end
    return string.format("%s\n%s", meta, line_text)
end

--- Copy the info string to all registers and show a notification.
function M.yank()
    local info = M.build()
    vim.fn.setreg("+", info)
    vim.fn.setreg("", info)
    vim.notify(info, vim.log.levels.INFO)
end

--- Copy visual-selection info to all registers and show a notification.
-- Must be called from a visual-mode keymap (before leaving visual mode).
function M.yank_selection()
    -- Capture range while still in visual mode: 'v' is selection start,
    -- '.' is current cursor. '<' and '>' are not yet set at this point.
    local v_line = vim.fn.line("v")
    local cur_line = vim.fn.line(".")
    local range_start = math.min(v_line, cur_line)
    local range_end = math.max(v_line, cur_line)

    -- Leave visual mode
    vim.api.nvim_feedkeys(vim.api.nvim_replace_termcodes("<Esc>", true, false, true), "n", false)

    local info = M.build_selection(range_start, range_end)
    vim.fn.setreg("+", info)
    vim.fn.setreg("", info)
    vim.notify(info, vim.log.levels.INFO)
end

return M
