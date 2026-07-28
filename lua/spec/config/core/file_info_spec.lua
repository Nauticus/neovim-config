local assert = require("luassert")
local stub = require("luassert.stub")

describe("file_info", function()
    local file_info
    local orig_getline = vim.fn.getline -- save once at module load time

    before_each(function()
        vim.fn.getline = orig_getline
    end)

    local function load_module()
        package.loaded["config.core.file_info"] = nil
        return require("config.core.file_info")
    end

    after_each(function()
        package.loaded["config.core.file_info"] = nil
    end)

    describe("build", function()
        it("returns HTML with code tags and no gitsigns", function()
            stub(vim.fn, "expand").returns("mappings.lua")
            stub(vim.fn, "line").returns(42)
            stub(vim.fn, "col").returns(10)
            vim.fn.getline = function() return "    local x = 1" end
            vim.b.gitsigns_status_dict = nil
            vim.bo.filetype = "lua"

            file_info = load_module()
            assert.equals(
                "<code>mappings.lua | L42:C10 | (no branch) | [lua] (unknown)<br>    local x = 1</code>",
                file_info.build()
            )
        end)

        it("falls back to absolute path when relative is empty", function()
            local s_expand = stub(vim.fn, "expand")
            s_expand.returns("").on_call_with("%:.")
            s_expand.returns("/home/user/project/file.lua").on_call_with("%:p")
            stub(vim.fn, "line").returns(1)
            stub(vim.fn, "col").returns(1)
            vim.fn.getline = function() return "" end
            vim.b.gitsigns_status_dict = nil
            vim.bo.filetype = "lua"

            file_info = load_module()
            assert.equals(
                "<code>/home/user/project/file.lua | L1:C1 | (no branch) | [lua] (unknown)<br></code>",
                file_info.build()
            )
        end)

        it("shows clean when gitsigns attached but no changes", function()
            stub(vim.fn, "expand").returns("file.lua")
            stub(vim.fn, "line").returns(5)
            stub(vim.fn, "col").returns(3)
            vim.fn.getline = function() return "hello" end
            vim.b.gitsigns_status_dict = { head = "main", added = 0, changed = 0, removed = 0 }
            vim.b.gitsigns_head = "main"
            vim.bo.filetype = "txt"

            file_info = load_module()
            assert.equals(
                "<code>file.lua | L5:C3 | main | [txt] clean<br>hello</code>",
                file_info.build()
            )
        end)

        it("shows diff stats for a mixed diff", function()
            stub(vim.fn, "expand").returns("file.lua")
            stub(vim.fn, "line").returns(50)
            stub(vim.fn, "col").returns(1)
            vim.fn.getline = function() return "local foo = bar" end
            vim.b.gitsigns_status_dict = { head = "main", added = 5, changed = 2, removed = 1 }
            vim.b.gitsigns_head = "main"
            vim.bo.filetype = "lua"

            file_info = load_module()
            assert.equals(
                "<code>file.lua | L50:C1 | main | [lua] +5/~2/-1<br>local foo = bar</code>",
                file_info.build()
            )
        end)

        it("escapes HTML special characters in code", function()
            stub(vim.fn, "expand").returns("index.html")
            stub(vim.fn, "line").returns(1)
            stub(vim.fn, "col").returns(1)
            vim.fn.getline = function() return '<div class="foo">bar & baz</div>' end
            vim.b.gitsigns_status_dict = nil
            vim.bo.filetype = "html"

            file_info = load_module()
            assert.equals(
                "<code>index.html | L1:C1 | (no branch) | [html] (unknown)<br>&lt;div class=&quot;foo&quot;&gt;bar &amp; baz&lt;/div&gt;</code>",
                file_info.build()
            )
        end)

        it("omits lang tag when bo.filetype is empty", function()
            stub(vim.fn, "expand").returns("file.txt")
            stub(vim.fn, "line").returns(1)
            stub(vim.fn, "col").returns(1)
            vim.fn.getline = function() return "x" end
            vim.b.gitsigns_status_dict = nil
            vim.bo.filetype = ""

            file_info = load_module()
            assert.equals(
                "<code>file.txt | L1:C1 | (no branch) | (unknown)<br>x</code>",
                file_info.build()
            )
        end)
    end)

    describe("build_selection", function()
        it("shows single-line selection without range suffix", function()
            stub(vim.fn, "expand").returns("file.lua")
            vim.fn.getline = function() return { "local x = 1" } end
            vim.b.gitsigns_status_dict = nil
            vim.bo.filetype = "lua"

            file_info = load_module()
            assert.equals(
                "<code>file.lua | L5 | (no branch) | [lua] (unknown)<br>local x = 1</code>",
                file_info.build_selection(5, 5)
            )
        end)

        it("shows multi-line selection with range and line count", function()
            stub(vim.fn, "expand").returns("file.lua")
            vim.fn.getline = function() return { "local a = 1", "local b = 2", "local c = 3" } end
            vim.b.gitsigns_status_dict = { head = "main", added = 2, changed = 1, removed = 0 }
            vim.b.gitsigns_head = "main"
            vim.bo.filetype = "lua"

            file_info = load_module()
            assert.equals(
                "<code>file.lua | L10-L12 (3 lines) | main | [lua] +2/~1/-0<br>local a = 1<br>local b = 2<br>local c = 3</code>",
                file_info.build_selection(10, 12)
            )
        end)

        it("escapes HTML in multi-line selection", function()
            stub(vim.fn, "expand").returns("app.tsx")
            vim.fn.getline = function() return { '<div>hi</div>', '<span>&</span>' } end
            vim.b.gitsigns_status_dict = nil
            vim.bo.filetype = "tsx"

            file_info = load_module()
            assert.equals(
                "<code>app.tsx | L1-L2 (2 lines) | (no branch) | [tsx] (unknown)<br>&lt;div&gt;hi&lt;/div&gt;<br>&lt;span&gt;&amp;&lt;/span&gt;</code>",
                file_info.build_selection(1, 2)
            )
        end)

        it("omits lang tag when filetype is empty", function()
            stub(vim.fn, "expand").returns("file.txt")
            vim.fn.getline = function() return { "line one", "line two" } end
            vim.b.gitsigns_status_dict = nil
            vim.bo.filetype = ""

            file_info = load_module()
            assert.equals(
                "<code>file.txt | L1-L2 (2 lines) | (no branch) | (unknown)<br>line one<br>line two</code>",
                file_info.build_selection(1, 2)
            )
        end)
    end)

    describe("yank", function()
        it("copies info to clipboard registers without error", function()
            stub(vim.fn, "expand").returns("file.lua")
            stub(vim.fn, "line").returns(1)
            stub(vim.fn, "col").returns(1)
            vim.fn.getline = function() return "test" end
            local s_setreg = stub(vim.fn, "setreg")
            local s_notify = stub(vim, "notify")

            vim.b.gitsigns_status_dict = nil
            vim.bo.filetype = "lua"

            file_info = load_module()
            file_info.yank()

            assert.stub(s_setreg).was_called()
            assert.stub(s_notify).was_called()
            for _, call in ipairs(s_setreg.calls) do
                local reg = call.vals[1]
                assert.is_true(reg == "+" or reg == "", string.format("unexpected register: %s", reg))
            end
        end)
    end)

    describe("yank_selection", function()
        it("copies selection info to clipboard registers without error", function()
            stub(vim.fn, "expand").returns("file.lua")
            local s_line = stub(vim.fn, "line")
            s_line.returns(5).on_call_with("v")
            s_line.returns(1).on_call_with(".")
            vim.fn.getline = function() return { "a", "b", "c", "d", "e" } end
            stub(vim.api, "nvim_feedkeys")
            local s_setreg = stub(vim.fn, "setreg")
            local s_notify = stub(vim, "notify")

            vim.b.gitsigns_status_dict = nil
            vim.bo.filetype = "lua"

            file_info = load_module()
            file_info.yank_selection()

            assert.stub(s_setreg).was_called()
            assert.stub(s_notify).was_called()
        end)
    end)
end)
