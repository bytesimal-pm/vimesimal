-- Nest: indent guides with current-scope highlight (tree-sitter aware,
-- works with tab indentation).

return {
  "lukas-reineke/indent-blankline.nvim",
  main = "ibl",
  event = { "BufReadPost", "BufNewFile" },
  opts = {
    indent = { char = "│", tab_char = "│" },
    scope = { show_start = false, show_end = false },
    exclude = { filetypes = { "help", "NvimTree", "lazy" } },
  },
}
