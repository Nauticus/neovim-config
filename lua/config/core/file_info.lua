--- Module that gathers orientation information about the current buffer.
local M = {}

--- Build a single-line summary of the current buffer.
-- @return string formatted info
function M.build()
    local path = vim.fn.expand("%:.") -- path relative to cwd
    if path == "%" or path == "" then
        path = vim.fn.expand("%:p")
    end
    local line = vim.fn.line(".")
    local col = vim.fn.col(".")

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

    return string.format("%s | L%d:C%d | %s | %s", path, line, col, branch, diff)
end

--- Copy the info string to all registers and show a notification.
function M.yank()
    local info = M.build()
    vim.fn.setreg("+", info)
    vim.fn.setreg("", info)
    vim.notify(info, vim.log.levels.INFO)
end

return M
