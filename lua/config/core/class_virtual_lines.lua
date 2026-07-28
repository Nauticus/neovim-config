--- Virtually split tailwind class strings into one-class-per-line
--- Uses treesitter to find class attribute values and extmarks with virt_lines.

local M = {}

local ns = vim.api.nvim_create_namespace("class_virtual_lines")
local _enabled = {} -- per-buffer: _enabled[bufnr] = boolean

-- Attribute names to match
local CLASS_ATTRS = {
    class = true,
    className = true,
    ["class-name"] = true,
    ["class_name"] = true,
}

-- Supported filetypes and their treesitter patterns
local JSX_PATTERN = [[
  (jsx_attribute
    (property_identifier) @attr
    (string) @value)
  (jsx_attribute
    (property_identifier) @attr
    (jsx_expression
      (template_string) @value))
]]

local HTML_PATTERN = [[
  (attribute
    (attribute_name) @attr
    (quoted_attribute_value) @value)
]]

local FILETYPE_CONFIG = {
  tsx = { pattern = JSX_PATTERN },
  javascriptreact = { pattern = JSX_PATTERN },
  typescriptreact = { pattern = JSX_PATTERN },
  javascript = { pattern = JSX_PATTERN },
  typescript = { pattern = JSX_PATTERN },
  html = { pattern = HTML_PATTERN },
  vue = { pattern = HTML_PATTERN },
  svelte = { pattern = HTML_PATTERN },
}

--- Extract class text from a value node, stripping quotes/backticks
local function extract_class_text(bufnr, value_node)
  local raw = vim.treesitter.get_node_text(value_node, bufnr)
  if not raw then
    return nil
  end
  -- Strip leading/trailing quotes or backticks
  return raw:gsub('^["`]', ''):gsub('["`]$', '')
end

--- Render virtual lines for the given buffer
local function render(bufnr)
  vim.api.nvim_buf_clear_namespace(bufnr, ns, 0, -1)

  local ft = vim.bo[bufnr].filetype
  local config = FILETYPE_CONFIG[ft]
  if not config then
    return
  end

  local ok, query = pcall(vim.treesitter.query.parse, ft, config.pattern)
  if not ok then
    return
  end

  local parser = vim.treesitter.get_parser(bufnr)
  if not parser then
    return
  end

  local root = parser:parse()[1]:root()

  -- Collect all matches first so we can skip individual ones without exiting
  local matches = {}
  for _, captures in query:iter_matches(root, bufnr, 0, -1, { all = false }) do
    table.insert(matches, captures)
  end

  -- q.captures is 1-indexed: { "attr", "value" }
  local attr_id, value_id = 1, 2
  for _, captures in ipairs(matches) do
    -- Get attribute name from first capture group
    local attr_node = captures[attr_id] and captures[attr_id][1]
    if not attr_node then
      goto continue
    end
    local attr_text = vim.treesitter.get_node_text(attr_node, bufnr)
    if not CLASS_ATTRS[attr_text] then
      goto continue
    end

    -- Get value node from second capture group
    local value_node = captures[value_id] and captures[value_id][1]
    if not value_node then
      goto continue
    end

    local class_str = extract_class_text(bufnr, value_node)
    if not class_str then
      goto continue
    end

    -- Split into individual classes
    local parts = {}
    for cls in class_str:gmatch("[^%s]+") do
      table.insert(parts, cls)
    end
    if #parts <= 1 then
      goto continue
    end

    -- Build virtual lines
    local virt = {}
    for _, cls in ipairs(parts) do
      table.insert(virt, { cls, "Comment" })
    end

    local row, col = value_node:start()

    vim.api.nvim_buf_set_extmark(bufnr, ns, row, col, {
      virt_lines = { virt },
      hl_mode = "combine",
    })

    ::continue::
  end
end

function M.toggle(bufnr)
  bufnr = bufnr or 0
  _enabled[bufnr] = not _enabled[bufnr]
  vim.notify(
    string.format("Class virtual lines: %s", _enabled[bufnr] and "on" or "off"),
    vim.log.levels.INFO,
    { title = "Class Virtual Lines" }
  )
  if _enabled[bufnr] then
    render(bufnr)
  else
    vim.api.nvim_buf_clear_namespace(bufnr, ns, 0, -1)
    _enabled[bufnr] = nil
  end
end

function M.refresh(bufnr)
  bufnr = bufnr or 0
  if not _enabled[bufnr] then
    return
  end
  if not vim.api.nvim_buf_is_valid(bufnr) then
    _enabled[bufnr] = nil
    return
  end
  render(bufnr)
end

M.ns = ns

return M
