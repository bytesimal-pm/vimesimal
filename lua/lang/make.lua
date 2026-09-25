-- Makefile: tree-sitter parser only (no language server).
-- Spacing lives in after/ftplugin/make.lua.

return {
  {
    "nvim-treesitter/nvim-treesitter",
    opts = function(_, o) vim.list_extend(o.parsers, { "make" }) end,
  },
}
