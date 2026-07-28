local js_formatters = { "prettierd", "prettier", stop_after_first = true }

return {
  "stevearc/conform.nvim",
  event = "BufWritePre",
  cmd = { "ConformInfo" },
  keys = {
    {
      "<leader>f=",
      function()
        require("conform").format({ async = true })
      end,
      mode = { "n", "v" },
      desc = "[F]ormat code",
    },
    {
      "<leader>fI",
      function()
        require("conform").format({ formatters = { "injected" } })
      end,
      desc = "[F]ormat [I]njected language blocks",
    },
  },
  ---@module "conform"
  ---@type conform.setupOpts
  opts = {
    -- Set up format-on-save automatically
    format_on_save = {
      timeout_ms = 500,
      lsp_format = "fallback",
    },

    formatters_by_ft = {
      lua = { "stylua" },
      sh = { "shfmt" },
      javascript = js_formatters,
      javascriptreact = js_formatters,
      typescript = js_formatters,
      typescriptreact = js_formatters,
      go = { "goimports", "gofmt" },
      yaml = { "yamlfmt", stop_after_first = true },
      html = { "prettierd", "prettier", stop_after_first = true },
      scss = { "prettierd", "prettier", stop_after_first = true },
      css = { "prettierd", "prettier", stop_after_first = true },
      svg = { "xmlformat", stop_after_first = true },
      tex = { "latexindent" },
    },

    default_format_opts = {
      lsp_format = "fallback",
      timeout_ms = 5000,
    },

    -- Customize built-in formatters
    formatters = {
      shfmt = {
        append_args = function(_, ctx)
          -- Use tabs if the buffer uses tabs
          local indent = vim.bo[ctx.buf].expandtab and "2" or "1"
          return { "-i", indent }
        end,
      },
    },

    log_level = vim.log.levels.ERROR,
  },
  init = function()
    vim.o.formatexpr = "v:lua.require'conform'.formatexpr()"
  end,
}
