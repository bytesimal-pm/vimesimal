-- JavaScript parser. The servers (ts_ls, eslint, tailwind) and Prettier for
-- .js/.jsx come from lua/lang/typescript.lua.
-- Spacing/indent: after/ftplugin/javascript.lua, after/indent/javascript.lua.

return {
  {
    "nvim-treesitter/nvim-treesitter",
    opts = function(_, o) vim.list_extend(o.parsers, { "javascript" }) end,
  },
}
