vim.g.loaded_perl_provider = 0
vim.g.loaded_ruby_provider = 0
vim.g.loaded_python_provider = 0

vim.g.mapleader = vim.api.nvim_replace_termcodes("<Space>", true, true, true)
vim.g.maplocalleader = "\\"

require("config.lazy")
require("config.lsp")

require("config.core.opts")
require("config.core.autocmd")
require("config.core.mappings")
