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

        it("shows clean when gitsigns attached but no changes", function()
            local s_expand = stub(vim.fn, "expand")
            s_expand.returns("file.lua")
            local s_line = stub(vim.fn, "line")
            s_line.returns(5)
            local s_col = stub(vim.fn, "col")
            s_col.returns(3)

            vim.b.gitsigns_status_dict = { head = "main", added = 0, changed = 0, removed = 0 }
            vim.b.gitsigns_head = "main"

            file_info = load_module()
            local result = file_info.build()
            assert.equals("file.lua | L5:C3 | main | clean", result)
        end)

        it("shows diff stats when file has additions only", function()
            local s_expand = stub(vim.fn, "expand")
            s_expand.returns("file.lua")
            local s_line = stub(vim.fn, "line")
            s_line.returns(10)
            local s_col = stub(vim.fn, "col")
            s_col.returns(1)

            vim.b.gitsigns_status_dict = { head = "feature", added = 3, changed = 0, removed = 0 }
            vim.b.gitsigns_head = "feature"

            file_info = load_module()
            local result = file_info.build()
            assert.equals("file.lua | L10:C1 | feature | +3/~0/-0", result)
        end)

        it("shows diff stats for a mixed diff", function()
            local s_expand = stub(vim.fn, "expand")
            s_expand.returns("file.lua")
            local s_line = stub(vim.fn, "line")
            s_line.returns(50)
            local s_col = stub(vim.fn, "col")
            s_col.returns(1)

            vim.b.gitsigns_status_dict = { head = "main", added = 5, changed = 2, removed = 1 }
            vim.b.gitsigns_head = "main"

            file_info = load_module()
            local result = file_info.build()
            assert.equals("file.lua | L50:C1 | main | +5/~2/-1", result)
        end)

        it("treats missing keys as zero", function()
            local s_expand = stub(vim.fn, "expand")
            s_expand.returns("file.lua")
            local s_line = stub(vim.fn, "line")
            s_line.returns(1)
            local s_col = stub(vim.fn, "col")
            s_col.returns(1)

            vim.b.gitsigns_status_dict = { head = "main" }
            vim.b.gitsigns_head = "main"

            file_info = load_module()
            local result = file_info.build()
            assert.equals("file.lua | L1:C1 | main | clean", result)
        end)

        it("falls back to status_dict.head when gitsigns_head is nil", function()
            local s_expand = stub(vim.fn, "expand")
            s_expand.returns("file.lua")
            local s_line = stub(vim.fn, "line")
            s_line.returns(1)
            local s_col = stub(vim.fn, "col")
            s_col.returns(1)

            vim.b.gitsigns_status_dict = { head = "detached-abc123", added = 0, changed = 0, removed = 0 }
            vim.b.gitsigns_head = nil

            file_info = load_module()
            local result = file_info.build()
            assert.equals("file.lua | L1:C1 | detached-abc123 | clean", result)
        end)
    end)

    describe("yank", function()
        it("copies info to clipboard registers without error", function()
            local s_expand = stub(vim.fn, "expand")
            s_expand.returns("file.lua")
            local s_line = stub(vim.fn, "line")
            s_line.returns(1)
            local s_col = stub(vim.fn, "col")
            s_col.returns(1)
            local s_setreg = stub(vim.fn, "setreg")
            local s_notify = stub(vim, "notify")

            vim.b.gitsigns_status_dict = nil

            file_info = load_module()
            file_info.yank()

            assert.stub(s_setreg).was_called()
            assert.stub(s_notify).was_called()
            -- verify only valid registers are used
            for _, call in ipairs(s_setreg.calls) do
                local reg = call.vals[1]
                assert.is_true(reg == "+" or reg == "", string.format("unexpected register: %s", reg))
            end
        end)
    end)
end)
