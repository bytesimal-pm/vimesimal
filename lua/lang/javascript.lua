-- JavaScript: tree-sitter parser only (no node, so no language server).
-- Spacing lives in after/ftplugin/javascript.lua.

return {
  {
    "nvim-treesitter/nvim-treesitter",
    opts = function(_, o) vim.list_extend(o.parsers, { "javascript" }) end,
  },
}
