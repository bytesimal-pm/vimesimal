local group = vim.api.nvim_create_augroup("vimesimal", { clear = true })

-- Tree-sitter highlighting for every filetype that has a parser installed.
-- Neovim ships C, Lua, Vim, Markdown and query parsers; more come from
-- `pacman -S tree-sitter-<lang>`.
vim.api.nvim_create_autocmd("FileType", {
  group = group,
  callback = function(ev)
    pcall(vim.treesitter.start, ev.buf)
  end,
})

vim.api.nvim_create_autocmd("TextYankPost", {
  group = group,
  callback = function()
    vim.hl.on_yank({ timeout = 150 })
  end,
})
