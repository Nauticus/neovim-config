local M = {}

--- Run full plugin setup
function M.setup()
  require("nvim-treesitter-textobjects").setup({
    select = {
      lookahead = true,
      selection_modes = {
        ["@parameter.outer"] = "v",
        ["@function.outer"] = "V",
        ["@class.outer"] = "V",
      },
      include_surrounding_whitespace = false,
    },
    move = { set_jumps = true },
  })
  M.setup_select_keys()
  M.setup_move_keys()
  M.setup_swap_keys()
  M.setup_repeat_keys()
end

function M.setup_select_keys()
  local select = require("nvim-treesitter-textobjects.select")
  local sel = {
    { "af", "@function.outer", "Full function" },
    { "if", "@function.inner", "Function body" },
    { "ac", "@class.outer", "Full class" },
    { "ic", "@class.inner", "Class body" },
    { "ai", "@conditional.outer", "Full conditional" },
    { "ii", "@conditional.inner", "Conditional body" },
    { "al", "@loop.outer", "Full loop" },
    { "il", "@loop.inner", "Loop body" },
    { "ak", "@block.outer", "Full block" },
    { "ik", "@block.inner", "Block body" },
    { "a?", "@call.outer", "Full call" },
    { "i?", "@call.inner", "Call args" },
    { "aa", "@parameter.outer", "Full parameter" },
    { "ia", "@parameter.inner", "Parameter" },
    { "ad", "@comment.outer", "Full comment" },
    { "aA", "@attribute.outer", "Full attribute" },
    { "iA", "@attribute.inner", "Attribute value" },
  }
  for _, entry in ipairs(sel) do
    local keys, query, desc = entry[1], entry[2], entry[3]
    vim.keymap.set({ "x", "o" }, keys, function()
      select.select_textobject(query, "textobjects")
    end, { desc = desc })
  end
end

function M.setup_move_keys()
  local move = require("nvim-treesitter-textobjects.move")
  local modes = { "n", "x", "o" }
  local mv = {
    { "]m", "@function.outer", "Next function", move.goto_next_start },
    { "[m", "@function.outer", "Prev function", move.goto_previous_start },
    { "]M", "@class.outer", "Next class", move.goto_next_start },
    { "[M", "@class.outer", "Prev class", move.goto_previous_start },
  }
  for _, entry in ipairs(mv) do
    local keys, query, desc, fn = entry[1], entry[2], entry[3], entry[4]
    vim.keymap.set(modes, keys, function()
      fn(query, "textobjects")
    end, { desc = desc })
  end
end

function M.setup_swap_keys()
  local swap = require("nvim-treesitter-textobjects.swap")
  vim.keymap.set("n", ")a", function()
    swap.swap_next("@parameter.inner")
  end, { desc = "Swap to next param" })
  vim.keymap.set("n", ")A", function()
    swap.swap_previous("@parameter.inner")
  end, { desc = "Swap to prev param" })
end

function M.setup_repeat_keys()
  local repeat_move = require("nvim-treesitter-textobjects.repeatable_move")
  vim.keymap.set({ "n", "x", "o" }, ";", repeat_move.repeat_last_move_next, {
    desc = "Repeat move forward",
  })
  vim.keymap.set({ "n", "x", "o" }, ",", repeat_move.repeat_last_move_previous, {
    desc = "Repeat move backward",
  })
end

return {
  -- nvim-treesitter: parser + query installation (Neovim 0.12+)
  -- Highlighting, folds, indent are built into Neovim 0.12.
  -- This plugin provides queries and :TSInstall / :TSUpdate commands.
  -- Per docs: "This plugin does not support lazy-loading."
  {
    "nvim-treesitter/nvim-treesitter",
    lazy = false,
    build = ":TSUpdate",
    opts = {}, -- setup() is called automatically by lazy.nvim with opts
  },

  -- nvim-treesitter-textobjects: vaf, daF, ]m, [m, etc.
  -- Docs: ~/.local/share/nvim/lazy/nvim-treesitter-textobjects/README.md
  {
    "nvim-treesitter/nvim-treesitter-textobjects",
    event = "VeryLazy",
    init = function()
      vim.g.no_plugin_maps = true
    end,
    config = function()
      M.setup()
    end,
  },
}
