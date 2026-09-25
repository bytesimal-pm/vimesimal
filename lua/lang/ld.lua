-- Linker scripts (.ld, .lds): linkerscript parser (no language server).
-- Spacing lives in after/ftplugin/ld.lua.

vim.filetype.add({ extension = { lds = "ld" } })

return {
  {
    "nvim-treesitter/nvim-treesitter",
    opts = function(_, o) vim.list_extend(o.parsers, { "linkerscript" }) end,
  },
}
