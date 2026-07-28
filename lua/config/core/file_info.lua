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

    -- git branch and changed status (via gitsigns buffer variables)
    local branch, changed = "(no branch)", "(unknown)"
    if vim.b.gitsigns_status_dict then
        branch = vim.b.gitsigns_head or vim.b.gitsigns_status_dict.head or "(no branch)"
        local gs = package.loaded.gitsigns
        if gs then
            local hunks = gs.get_hunks(0)
            if hunks then
                for _, hunk in ipairs(hunks) do
                    local added_start = hunk.added and hunk.added.start or 0
                    local added_count = hunk.added and hunk.added.count or 0
                    if line >= added_start and line < added_start + added_count then
                        changed = string.format("changed (%s)", hunk.type)
                        break
                    end
                end
            end
            if changed == "(unknown)" then
                changed = "unchanged"
            end
        end
    end

    return string.format("%s | L%d:C%d | %s | %s", path, line, col, branch, changed)
end

--- Copy the info string to all registers and show a notification.
function M.yank()
    local info = M.build()
    vim.fn.setreg("*", info)
    vim.fn.setreg("+", info)
    vim.fn.setreg(".", info)
    vim.fn.setreg("", info)
    vim.notify(info, vim.log.levels.INFO)
end

return M
