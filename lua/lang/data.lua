-- Data / config / shader files: JSON(C), TOML, CSS (+ Qt .qss), GLSL.
-- They use the global default spacing (4 spaces), so no ftplugin files.

vim.filetype.add({ extension = { qss = "css" } })

return {
  {
    "nvim-treesitter/nvim-treesitter",
    opts = function(_, o) vim.list_extend(o.parsers, { "json", "toml", "css", "glsl" }) end,
  },
  {
    "neovim/nvim-lspconfig",
    opts = {
      servers = {
        jsonls = { bin = "vscode-json-language-server" },
        taplo = {},
      },
    },
  },
}
