-- NASM (x86/x86-64) plugins: asm-lsp for instruction/register completion,
-- hover docs and diagnostics. Its settings live in asm-lsp/.asm-lsp.toml.
-- Spacing lives in after/ftplugin/nasm.lua. Highlighting comes from
-- Neovim's bundled syntax/nasm.vim (no tree-sitter parser exists).

vim.filetype.add({
  extension = { asm = "nasm", nasm = "nasm", inc = "nasm" },
})

return {
  {
    "neovim/nvim-lspconfig",
    opts = {
      servers = {
        -- Enabled automatically once `asm-lsp` is on PATH
        -- (sudo pacman -S rust && cargo install asm-lsp).
        asm_lsp = { filetypes = { "nasm", "asm" } },
      },
    },
  },
}
