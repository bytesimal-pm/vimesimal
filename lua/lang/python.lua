-- Python: pyright (types, completion, go-to) + ruff (lint).
-- Spacing lives in after/ftplugin/python.lua.

return {
  {
    "nvim-treesitter/nvim-treesitter",
    opts = function(_, o) vim.list_extend(o.parsers, { "python" }) end,
  },
  {
    "neovim/nvim-lspconfig",
    opts = {
      servers = {
        pyright = {},
        ruff = {
          -- Leave hover to pyright
          on_attach = function(client) client.server_capabilities.hoverProvider = false end,
        },
      },
    },
  },
}
