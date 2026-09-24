-- C plugins: clangd, kernel-style clang-format (<leader>cf), clangd extras.
-- Spacing lives in after/ftplugin/c.lua.

-- Treat .h as C, not C++.
vim.g.c_syntax_for_h = 1

-- Linux kernel style, used when the project has no .clang-format of its own.
local kernel_style = "{" .. table.concat({
  "BasedOnStyle: LLVM",
  "IndentWidth: 8",
  "TabWidth: 8",
  "UseTab: Always",
  "ContinuationIndentWidth: 8",
  "ColumnLimit: 80",
  "BreakBeforeBraces: Linux",
  "IndentCaseLabels: false",
  "AllowShortIfStatementsOnASingleLine: false",
  "AllowShortLoopsOnASingleLine: false",
  "AllowShortFunctionsOnASingleLine: None",
  "AllowShortBlocksOnASingleLine: false",
  "PointerAlignment: Right",
  "SpaceAfterCStyleCast: false",
  "SortIncludes: false",
}, ", ") .. "}"

return {
  {
    "neovim/nvim-lspconfig",
    opts = {
      servers = {
        clangd = {
          cmd = { "clangd", "--background-index", "--header-insertion=never" },
          filetypes = { "c", "cpp" },
        },
      },
    },
  },
  {
    "stevearc/conform.nvim",
    opts = {
      formatters_by_ft = { c = { "clang_format" } },
      formatters = {
        -- --fallback-style only takes a preset name, so pass the inline
        -- kernel style explicitly when no project config is found.
        clang_format = {
          prepend_args = function(_, ctx)
            local found = vim.fs.find({ ".clang-format", "_clang-format" }, { upward = true, path = ctx.dirname })
            return { "--style=" .. (#found > 0 and "file" or kernel_style) }
          end,
        },
      },
    },
  },
  {
    -- :ClangdAST, :ClangdSymbolInfo, :ClangdTypeHierarchy, :ClangdMemoryUsage
    "p00f/clangd_extensions.nvim",
    ft = { "c", "cpp" },
    opts = {},
    keys = {
      { "<leader>a", "<cmd>LspClangdSwitchSourceHeader<cr>", ft = { "c", "cpp" }, desc = "Toggle .c/.h" },
    },
  },
}
