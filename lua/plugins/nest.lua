-- Nest: indent guides with current-scope highlight + rainbow brackets
-- (both tree-sitter aware, and work with tab indentation).

return {
  {
    "lukas-reineke/indent-blankline.nvim",
    main = "ibl",
    event = { "BufReadPost", "BufNewFile" },
    opts = {
      indent = { char = "│", tab_char = "│" },
      scope = { show_start = false, show_end = false },
      exclude = { filetypes = { "help", "NvimTree", "lazy" } },
    },
  },
  {
    -- Attaches on FileType; the README advises against lazy-loading.
    "HiPhish/rainbow-delimiters.nvim",
    lazy = false,
  },
}
