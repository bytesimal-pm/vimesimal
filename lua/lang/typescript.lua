-- TypeScript / TSX / JSX (Next.js, React): typescript-language-server,
-- Tailwind class completion, ESLint warnings, Prettier on <leader>cf.
-- The servers and prettier prefer the project's own node_modules/.bin copy.
-- Spacing lives in after/ftplugin/typescript.lua (tsx/jsx reuse it).

return {
  {
    "nvim-treesitter/nvim-treesitter",
    opts = function(_, o) vim.list_extend(o.parsers, { "typescript", "tsx", "html" }) end,
  },
  {
    "neovim/nvim-lspconfig",
    opts = {
      servers = {
        -- cmd is a function in lspconfig, so name the binary for the PATH check
        ts_ls = { bin = "typescript-language-server" },
        tailwindcss = { bin = "tailwindcss-language-server" },
        -- npm install -g --prefix ~/.local vscode-langservers-extracted
        eslint = { bin = "vscode-eslint-language-server" },
      },
    },
  },
  {
    "stevearc/conform.nvim",
    opts = {
      formatters_by_ft = {
        typescript = { "prettier" },
        typescriptreact = { "prettier" },
        javascript = { "prettier" },
        javascriptreact = { "prettier" },
        css = { "prettier" },
        json = { "prettier" },
        jsonc = { "prettier" },
      },
    },
  },
}
