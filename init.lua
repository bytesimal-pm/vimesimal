-- vimesimal — entry point
--
--   lua/config/          global options, keymaps, autocmds, LSP UI, lazy.nvim
--   lua/plugins/         global plugins
--   colors/              global theme
--   lua/lang/<name>.lua  per-language plugins (LSP server, formatter, extras)
--   after/ftplugin/      per-language spacing / indent style

require("config.options")
require("config.keymaps")
require("config.autocmds")
require("config.lsp")
require("config.lazy")

vim.cmd.colorscheme("vimesimal")
