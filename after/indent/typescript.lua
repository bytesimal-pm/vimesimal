-- Indent from tree-sitter, which understands JSX. This lives in after/indent/
-- because Neovim's own indent/typescript.vim loads after ftplugins and would
-- otherwise override it (its regex indent flattens JSX on =).
vim.bo.indentexpr = "v:lua.require'nvim-treesitter'.indentexpr()"
vim.b.undo_indent = (vim.b.undo_indent and vim.b.undo_indent .. " | " or "") .. "setlocal indentexpr<"
