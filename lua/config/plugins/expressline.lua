local generator = function(win_id)
    local el_segments = {}
    local builtin = require('el.builtin')

    -- Keep in mind, these can be the builtin strings,
    -- which are found in |:help statusline|
    table.insert(el_segments, vim.b.gitsigns_head)
    table.insert(el_segments, "%=")
    table.insert(el_segments, builtin.file)
    table.insert(el_segments, "%=")

    return el_segments
end

return {
    "tjdevries/express_line.nvim",
    enabled = false,
    config = function()
        require('el').setup { generator = generator }
    end
}
