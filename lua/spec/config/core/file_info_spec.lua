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
        it("returns correct markdown format with no gitsigns", function()
            stub(vim.fn, "expand").returns("mappings.lua")
            stub(vim.fn, "line").returns(42)
            stub(vim.fn, "col").returns(10)
            stub(vim.fn, "getline").returns("    local x = 1")
            vim.b.gitsigns_status_dict = nil
            vim.bo.filetype = "lua"

            file_info = load_module()
            local result = file_info.build()
            assert.equals(
                "`mappings.lua` | L42:C10 | (no branch) | (unknown)\n```lua\n    local x = 1\n```",
                result
            )
        end)

        it("falls back to absolute path when relative is empty", function()
            local s_expand = stub(vim.fn, "expand")
            s_expand.returns("").on_call_with("%:.")
            s_expand.returns("/home/user/project/file.lua").on_call_with("%:p")
            stub(vim.fn, "line").returns(1)
            stub(vim.fn, "col").returns(1)
            stub(vim.fn, "getline").returns("")
            vim.b.gitsigns_status_dict = nil
            vim.bo.filetype = "lua"

            file_info = load_module()
            local result = file_info.build()
            assert.equals(
                "`/home/user/project/file.lua` | L1:C1 | (no branch) | (unknown)\n```lua\n\n```",
                result
            )
        end)

        it("shows clean when gitsigns attached but no changes", function()
            stub(vim.fn, "expand").returns("file.lua")
            stub(vim.fn, "line").returns(5)
            stub(vim.fn, "col").returns(3)
            stub(vim.fn, "getline").returns("hello")
            vim.b.gitsigns_status_dict = { head = "main", added = 0, changed = 0, removed = 0 }
            vim.b.gitsigns_head = "main"
            vim.bo.filetype = "txt"

            file_info = load_module()
            local result = file_info.build()
            assert.equals(
                "`file.lua` | L5:C3 | main | clean\n```txt\nhello\n```",
                result
            )
        end)

        it("shows diff stats for a mixed diff", function()
            stub(vim.fn, "expand").returns("file.lua")
            stub(vim.fn, "line").returns(50)
            stub(vim.fn, "col").returns(1)
            stub(vim.fn, "getline").returns("local foo = bar")
            vim.b.gitsigns_status_dict = { head = "main", added = 5, changed = 2, removed = 1 }
            vim.b.gitsigns_head = "main"
            vim.bo.filetype = "lua"

            file_info = load_module()
            local result = file_info.build()
            assert.equals(
                "`file.lua` | L50:C1 | main | +5/~2/-1\n```lua\nlocal foo = bar\n```",
                result
            )
        end)

        it("falls back to status_dict.head when gitsigns_head is nil", function()
            stub(vim.fn, "expand").returns("file.lua")
            stub(vim.fn, "line").returns(1)
            stub(vim.fn, "col").returns(1)
            stub(vim.fn, "getline").returns("test")
            vim.b.gitsigns_status_dict = { head = "detached-abc123", added = 0, changed = 0, removed = 0 }
            vim.b.gitsigns_head = nil
            vim.bo.filetype = "txt"

            file_info = load_module()
            local result = file_info.build()
            assert.equals(
                "`file.lua` | L1:C1 | detached-abc123 | clean\n```txt\ntest\n```",
                result
            )
        end)

        it("uses empty string for filetype when bo.filetype is nil", function()
            stub(vim.fn, "expand").returns("file.lua")
            stub(vim.fn, "line").returns(1)
            stub(vim.fn, "col").returns(1)
            stub(vim.fn, "getline").returns("x")
            vim.b.gitsigns_status_dict = nil
            vim.bo.filetype = nil

            file_info = load_module()
            local result = file_info.build()
            assert.equals(
                "`file.lua` | L1:C1 | (no branch) | (unknown)\n```\nx\n```",
                result
            )
        end)
    end)

    describe("yank", function()
        it("copies info to clipboard registers without error", function()
            stub(vim.fn, "expand").returns("file.lua")
            stub(vim.fn, "line").returns(1)
            stub(vim.fn, "col").returns(1)
            stub(vim.fn, "getline").returns("test")
            local s_setreg = stub(vim.fn, "setreg")
            local s_notify = stub(vim, "notify")

            vim.b.gitsigns_status_dict = nil
            vim.bo.filetype = "lua"

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
