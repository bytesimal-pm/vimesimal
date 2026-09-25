-- Lua: lua-language-server, with lazydev teaching it the Neovim API and
-- plugin types when editing this config.
-- Spacing lives in after/ftplugin/lua.lua. (Lua's parser ships with Neovim.)

return {
  {
    "folke/lazydev.nvim",
    ft = "lua",
    opts = {
      library = { { path = "${3rd}/luv/library", words = { "vim%.uv" } } },
    },
  },
  {
    "neovim/nvim-lspconfig",
    opts = {
      servers = {
        lua_ls = {
          settings = {
            Lua = {
              completion = { callSnippet = "Replace" },
              telemetry = { enable = false },
            },
          },
        },
      },
    },
  },
  {
    -- lazydev as a completion source (Neovim API, require paths)
    "saghen/blink.cmp",
    opts = {
      sources = {
        per_filetype = { lua = { inherit_defaults = true, "lazydev" } },
        providers = {
          lazydev = { name = "LazyDev", module = "lazydev.integrations.blink", score_offset = 100 },
        },
      },
    },
  },
}
