-- Lua: lua-language-server, with lazydev teaching it the Neovim API and
-- plugin types when editing this config.
-- Spacing lives in after/ftplugin/lua.lua. (Lua's parser ships with Neovim.)

return {
  {
    "folke/lazydev.nvim",
    ft = "lua",
    opts = {
      library = {
        { path = "${3rd}/luv/library", words = { "vim%.uv" } },
        -- Hyprland's Lua config API (hl.*), shipped with the hyprland package
        { path = "/usr/share/hypr/stubs", words = { "hl%." } },
      },
    },
  },
  {
    "neovim/nvim-lspconfig",
    opts = {
      servers = {
        lua_ls = {
          -- Also check lone .lua files and symlinked configs (hyprland.lua)
          root_dir = require("vimesimal.root").project_or_dir({
            ".luarc.json", ".luarc.jsonc", ".stylua.toml", "stylua.toml", ".git",
          }, { follow_symlinks = true }),
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
