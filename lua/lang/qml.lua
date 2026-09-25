-- QML (Quickshell): qmljs parser + qmlls.
-- Spacing lives in after/ftplugin/qml.lua.
-- For Quickshell types, keep an empty .qmlls.ini in the shell folder;
-- Quickshell fills in the import paths when it runs.

return {
  {
    "nvim-treesitter/nvim-treesitter",
    opts = function(_, o) vim.list_extend(o.parsers, { "qmljs" }) end,
  },
  {
    "neovim/nvim-lspconfig",
    opts = {
      servers = {
        -- Arch names the binary qmlls6 (qt6-declarative)
        qmlls = { cmd = { "qmlls6" } },
      },
    },
  },
}
