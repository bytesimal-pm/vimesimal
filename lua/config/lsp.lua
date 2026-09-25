-- LSP UI: diagnostics look + keymaps for any attached server. Servers
-- themselves are declared per language in lua/lang/<name>.lua.

local sev = vim.diagnostic.severity

vim.diagnostic.config({
  severity_sort = true,
  virtual_text = { prefix = "‹" },
  float = { source = true },
  signs = {
    text = {
      [sev.ERROR] = "✗",
      [sev.WARN] = "!",
      [sev.INFO] = "i",
      [sev.HINT] = "·",
    },
  },
})

-- Color previews (Tailwind classes, CSS colors) as a small swatch before the
-- text, instead of painting the text's background (bg-white became a white box).
vim.lsp.document_color.enable(true, nil, { style = "virtual" })

-- Neovim already maps: K hover, grn rename, gra code action, grr references,
-- gri implementation, gO symbols, [d ]d diagnostics, <C-s> signature help.
vim.api.nvim_create_autocmd("LspAttach", {
  group = vim.api.nvim_create_augroup("vimesimal_lsp", { clear = true }),
  callback = function(ev)
    local map = function(lhs, rhs, desc)
      vim.keymap.set("n", lhs, rhs, { buffer = ev.buf, desc = desc })
    end
    map("gd", vim.lsp.buf.definition, "Definition")
    map("gD", vim.lsp.buf.declaration, "Declaration")
    map("gy", vim.lsp.buf.type_definition, "Type definition")
    map("<leader>rn", vim.lsp.buf.rename, "Rename")
    map("<leader>ca", vim.lsp.buf.code_action, "Code action")
  end,
})
