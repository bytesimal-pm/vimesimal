-- Shell (sh, bash, zsh): bash-language-server, which runs shellcheck for
-- lint warnings when it's installed.
-- Spacing lives in after/ftplugin/sh.lua (bash.lua and zsh.lua reuse it).

return {
  {
    "nvim-treesitter/nvim-treesitter",
    opts = function(_, o) vim.list_extend(o.parsers, { "bash", "zsh" }) end,
  },
  {
    "neovim/nvim-lspconfig",
    opts = {
      servers = {
        bashls = { filetypes = { "sh", "bash" } },
      },
    },
  },
}
