local assert = require("luassert")

describe("class_virtual_lines", function()
    local mod

    local function load_module()
        package.loaded["config.core.class_virtual_lines"] = nil
        return require("config.core.class_virtual_lines")
    end

    local bufnr

    before_each(function()
        mod = load_module()
        bufnr = vim.api.nvim_create_buf(false, true)
    end)

    after_each(function()
        if bufnr and vim.api.nvim_buf_is_valid(bufnr) then
            vim.api.nvim_buf_delete(bufnr, { force = true })
        end
        package.loaded["config.core.class_virtual_lines"] = nil
    end)

    -- Wrap a single JSX element in a function so treesitter parses it.
    -- For multiple elements, use inline set_content with a <> fragment.
    local function wrap_jsx(line)
        return {
            "export default function App() {",
            "  return (",
            "    " .. line,
            "  );",
            "}",
        }
    end

    local function set_content(lines, filetype)
        vim.api.nvim_buf_set_lines(bufnr, 0, -1, false, lines)
        vim.bo[bufnr].filetype = filetype
        vim.treesitter.stop(bufnr)
        vim.treesitter.get_parser(bufnr, filetype)
    end

    local function set_jsx(lines)
        set_content(wrap_jsx(lines), "tsx")
    end

    local function extmark_count()
        return #vim.api.nvim_buf_get_extmarks(bufnr, mod.ns, 0, -1, { details = true })
    end

    local function virt_classes()
        local marks = vim.api.nvim_buf_get_extmarks(bufnr, mod.ns, 0, -1, { details = true })
        local out = {}
        for _, mark in ipairs(marks) do
            local detail = mark[4]
            for _, group in ipairs(detail and detail.virt_lines or {}) do
                for _, seg in ipairs(group) do
                    table.insert(out, seg[1])
                end
            end
        end
        return out
    end

    local function extmark_rows()
        local marks = vim.api.nvim_buf_get_extmarks(bufnr, mod.ns, 0, -1, { details = true })
        local rows = {}
        for _, mark in ipairs(marks) do
            table.insert(rows, mark[2]) -- row (0-indexed)
        end
        table.sort(rows)
        return rows
    end

    -- Per-match class lists, in buffer order
    local function virt_class_groups()
        local marks = vim.api.nvim_buf_get_extmarks(bufnr, mod.ns, 0, -1, { details = true })
        -- Sort by row so order is deterministic
        table.sort(marks, function(a, b) return a[2] < b[2] end)
        local groups = {}
        for _, mark in ipairs(marks) do
            local detail = mark[4]
            local group = {}
            for _, vl in ipairs(detail and detail.virt_lines or {}) do
                for _, seg in ipairs(vl) do
                    table.insert(group, seg[1])
                end
            end
            if #group > 0 then
                table.insert(groups, group)
            end
        end
        return groups
    end

    describe("toggle on tsx with class=\"...\"", function()
        it("splits multiple classes into virtual lines", function()
            set_jsx('<div class="flex items-center justify-between px-4">x</div>')
            mod.toggle(bufnr)
            assert.equals(1, extmark_count())
            assert.same({ "flex", "items-center", "justify-between", "px-4" }, virt_classes())
        end)

        it("does nothing for a single class", function()
            set_jsx('<div class="flex">x</div>')
            mod.toggle(bufnr)
            assert.equals(0, extmark_count())
        end)

        it("does nothing for empty class attribute", function()
            set_jsx('<div class="">x</div>')
            mod.toggle(bufnr)
            assert.equals(0, extmark_count())
        end)

        it("does nothing for whitespace-only class", function()
            set_jsx('<div class="   ">x</div>')
            mod.toggle(bufnr)
            assert.equals(0, extmark_count())
        end)
    end)

    describe("toggle on tsx with template literal", function()
        it("splits className with template literal", function()
            set_jsx('<div className={`text-sm font-bold text-red-500`}>x</div>')
            mod.toggle(bufnr)
            assert.equals(1, extmark_count())
            assert.same({ "text-sm", "font-bold", "text-red-500" }, virt_classes())
        end)
    end)

    describe("toggle on html", function()
        it("splits class in HTML attribute", function()
            set_content({ '<div class="bg-white rounded-lg shadow-md">x</div>' }, "html")
            mod.toggle(bufnr)
            assert.equals(1, extmark_count())
            assert.same({ "bg-white", "rounded-lg", "shadow-md" }, virt_classes())
        end)
    end)

    describe("toggle on/off", function()
        it("clears extmarks on second toggle", function()
            set_jsx('<div class="flex items-center">x</div>')
            mod.toggle(bufnr)
            assert.equals(1, extmark_count())
            mod.toggle(bufnr)
            assert.equals(0, extmark_count())
        end)
    end)

    describe("refresh", function()
        it("updates virtual lines after buffer change", function()
            set_jsx('<div class="flex items-center">x</div>')
            mod.toggle(bufnr)
            assert.equals(1, extmark_count())

            -- Change content
            set_jsx('<div class="bg-red-500 text-white px-4 py-2">x</div>')
            mod.refresh(bufnr)
            assert.equals(1, extmark_count())
            assert.same({ "bg-red-500", "text-white", "px-4", "py-2" }, virt_classes())
        end)

        it("does nothing when disabled", function()
            set_jsx('<div class="flex items-center">x</div>')
            mod.refresh(bufnr)
            assert.equals(0, extmark_count())
        end)
    end)

    describe("unsupported filetype", function()
        it("does nothing for unsupported filetypes", function()
            set_content({ '<div class="flex items-center">x</div>' }, "python")
            mod.toggle(bufnr)
            assert.equals(0, extmark_count())
        end)
    end)

    describe("non-class attributes", function()
        it("ignores id attribute", function()
            set_jsx('<div id="flex items-center">x</div>')
            mod.toggle(bufnr)
            assert.equals(0, extmark_count())
        end)
    end)

    -- New tests: multiple elements and edge cases
    describe("multiple class attributes on different elements", function()
        it("renders virtual lines for all matching class attrs", function()
            set_content({
                "export default function App() {",
                "  return (",
                "    <>",
                '      <div class="flex items-center">a</div>',
                '      <span class="bg-white rounded-lg shadow-md">b</span>',
                "    </>",
                "  );",
                "}",
            }, "tsx")
            mod.toggle(bufnr)
            assert.equals(2, extmark_count())
            assert.same({ { "flex", "items-center" }, { "bg-white", "rounded-lg", "shadow-md" } }, virt_class_groups())
        end)

        it("skips single-class attrs but processes others", function()
            set_content({
                "export default function App() {",
                "  return (",
                "    <>",
                '      <div class="flex">a</div>',
                '      <span class="bg-white rounded-lg">b</span>',
                "    </>",
                "  );",
                "}",
            }, "tsx")
            mod.toggle(bufnr)
            assert.equals(1, extmark_count())
            assert.same({ "bg-white", "rounded-lg" }, virt_classes())
        end)

        it("skips non-class attrs but processes class attrs", function()
            set_content({
                "export default function App() {",
                "  return (",
                "    <>",
                '      <div id="flex items-center">a</div>',
                '      <span class="bg-white rounded-lg">b</span>',
                "    </>",
                "  );",
                "}",
            }, "tsx")
            mod.toggle(bufnr)
            assert.equals(1, extmark_count())
            assert.same({ "bg-white", "rounded-lg" }, virt_classes())
        end)

        it("handles empty class attr then valid class attr", function()
            set_content({
                "export default function App() {",
                "  return (",
                "    <>",
                '      <div class="">a</div>',
                '      <span class="bg-red-500 text-white">b</span>',
                "    </>",
                "  );",
                "}",
            }, "tsx")
            mod.toggle(bufnr)
            assert.equals(1, extmark_count())
            assert.same({ "bg-red-500", "text-white" }, virt_classes())
        end)
    end)

    describe("className variant", function()
        it("splits className with double quotes", function()
            set_jsx('<div className="flex items-center">x</div>')
            mod.toggle(bufnr)
            assert.equals(1, extmark_count())
            assert.same({ "flex", "items-center" }, virt_classes())
        end)
    end)

    describe("mixed attribute types on same element", function()
        it("only renders for class, not other attrs", function()
            set_jsx('<div id="foo" class="flex items-center" style="color:red">x</div>')
            mod.toggle(bufnr)
            assert.equals(1, extmark_count())
            assert.same({ "flex", "items-center" }, virt_classes())
        end)
    end)

    describe("extmark position", function()
        it("places extmarks on correct rows for multiple elements", function()
            set_content({
                "export default function App() {",
                "  return (",
                "    <>",
                '      <div class="flex items-center">a</div>',
                '      <span class="bg-white rounded-lg">b</span>',
                "    </>",
                "  );",
                "}",
            }, "tsx")
            mod.toggle(bufnr)
            -- Rows 0-indexed: line 4 = row 3, line 5 = row 4
            assert.same({ 3, 4 }, extmark_rows())
        end)
    end)
end)
