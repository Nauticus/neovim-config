local assert = require("luassert")
local stub = require("luassert.stub")

describe("file_info", function()
    local file_info

    local function load_module()
        package.loaded["config.core.file_info"] = nil
        return require("config.core.file_info")
    end

    after_each(function()
        package.loaded["config.core.file_info"] = nil
        package.loaded.gitsigns = nil
    end)

    describe("build", function()
        it("returns correct format with no gitsigns", function()
            local s_expand = stub(vim.fn, "expand")
            local s_line = stub(vim.fn, "line")
            local s_col = stub(vim.fn, "col")

            s_expand.returns("lua/config/core/mappings.lua")
            s_line.returns(42)
            s_col.returns(10)
            vim.b.gitsigns_status_dict = nil

            file_info = load_module()
            local result = file_info.build()
            assert.equals("lua/config/core/mappings.lua | L42:C10 | (no branch) | (unknown)", result)
        end)

        it("falls back to absolute path when relative is empty", function()
            local s_expand = stub(vim.fn, "expand")
            s_expand.returns("").on_call_with("%:.")
            s_expand.returns("/home/user/project/file.lua").on_call_with("%:p")
            local s_line = stub(vim.fn, "line")
            s_line.returns(1)
            local s_col = stub(vim.fn, "col")
            s_col.returns(1)
            vim.b.gitsigns_status_dict = nil

            file_info = load_module()
            local result = file_info.build()
            assert.equals("/home/user/project/file.lua | L1:C1 | (no branch) | (unknown)", result)
        end)

        it("shows branch and unchanged when gitsigns attached but no hunks", function()
            local s_expand = stub(vim.fn, "expand")
            s_expand.returns("file.lua")
            local s_line = stub(vim.fn, "line")
            s_line.returns(5)
            local s_col = stub(vim.fn, "col")
            s_col.returns(3)

            vim.b.gitsigns_status_dict = { head = "main" }
            vim.b.gitsigns_head = "main"
            package.loaded.gitsigns = { get_hunks = function() return {} end }

            file_info = load_module()
            local result = file_info.build()
            assert.equals("file.lua | L5:C3 | main | unchanged", result)
        end)

        it("shows changed (add) when cursor is inside an add hunk", function()
            local s_expand = stub(vim.fn, "expand")
            s_expand.returns("file.lua")
            local s_line = stub(vim.fn, "line")
            s_line.returns(10)
            local s_col = stub(vim.fn, "col")
            s_col.returns(1)

            vim.b.gitsigns_status_dict = { head = "feature" }
            vim.b.gitsigns_head = "feature"
            package.loaded.gitsigns = {
                get_hunks = function()
                    return { { type = "add", added = { start = 8, count = 5 }, removed = { start = 0, count = 0 } } }
                end,
            }

            file_info = load_module()
            local result = file_info.build()
            assert.equals("file.lua | L10:C1 | feature | changed (add)", result)
        end)

        it("shows unchanged when cursor is outside all hunks", function()
            local s_expand = stub(vim.fn, "expand")
            s_expand.returns("file.lua")
            local s_line = stub(vim.fn, "line")
            s_line.returns(50)
            local s_col = stub(vim.fn, "col")
            s_col.returns(1)

            vim.b.gitsigns_status_dict = { head = "main" }
            vim.b.gitsigns_head = "main"
            package.loaded.gitsigns = {
                get_hunks = function()
                    return {
                        { type = "change", added = { start = 1, count = 3 }, removed = { start = 1, count = 2 } },
                        { type = "delete", added = { start = 10, count = 1 }, removed = { start = 10, count = 4 } }
                    }
                end,
            }

            file_info = load_module()
            local result = file_info.build()
            assert.equals("file.lua | L50:C1 | main | unchanged", result)
        end)

        it("shows changed (change) when cursor is inside a change hunk", function()
            local s_expand = stub(vim.fn, "expand")
            s_expand.returns("file.lua")
            local s_line = stub(vim.fn, "line")
            s_line.returns(2)
            local s_col = stub(vim.fn, "col")
            s_col.returns(1)

            vim.b.gitsigns_status_dict = { head = "main" }
            vim.b.gitsigns_head = "main"
            package.loaded.gitsigns = {
                get_hunks = function()
                    return { { type = "change", added = { start = 1, count = 5 }, removed = { start = 1, count = 3 } } }
                end,
            }

            file_info = load_module()
            local result = file_info.build()
            assert.equals("file.lua | L2:C1 | main | changed (change)", result)
        end)

        it("shows changed (delete) when cursor is inside a delete hunk", function()
            local s_expand = stub(vim.fn, "expand")
            s_expand.returns("file.lua")
            local s_line = stub(vim.fn, "line")
            s_line.returns(12)
            local s_col = stub(vim.fn, "col")
            s_col.returns(1)

            vim.b.gitsigns_status_dict = { head = "main" }
            vim.b.gitsigns_head = "main"
            package.loaded.gitsigns = {
                get_hunks = function()
                    return { { type = "delete", added = { start = 10, count = 4 }, removed = { start = 10, count = 8 } } }
                end,
            }

            file_info = load_module()
            local result = file_info.build()
            assert.equals("file.lua | L12:C1 | main | changed (delete)", result)
        end)

        it("falls back to status_dict.head when gitsigns_head is nil", function()
            local s_expand = stub(vim.fn, "expand")
            s_expand.returns("file.lua")
            local s_line = stub(vim.fn, "line")
            s_line.returns(1)
            local s_col = stub(vim.fn, "col")
            s_col.returns(1)

            vim.b.gitsigns_status_dict = { head = "detached-abc123" }
            vim.b.gitsigns_head = nil
            package.loaded.gitsigns = { get_hunks = function() return {} end }

            file_info = load_module()
            local result = file_info.build()
            assert.equals("file.lua | L1:C1 | detached-abc123 | unchanged", result)
        end)

        it("handles gitsigns.get_hunks returning nil", function()
            local s_expand = stub(vim.fn, "expand")
            s_expand.returns("file.lua")
            local s_line = stub(vim.fn, "line")
            s_line.returns(1)
            local s_col = stub(vim.fn, "col")
            s_col.returns(1)

            vim.b.gitsigns_status_dict = { head = "main" }
            vim.b.gitsigns_head = "main"
            package.loaded.gitsigns = { get_hunks = function() return nil end }

            file_info = load_module()
            local result = file_info.build()
            assert.equals("file.lua | L1:C1 | main | unchanged", result)
        end)
    end)
end)
