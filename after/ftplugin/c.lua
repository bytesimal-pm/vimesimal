-- C spacing — Linux kernel coding style
-- (Documentation/process/coding-style.rst): hard tabs, 8 wide, 80 columns.

vim.bo.expandtab = false
vim.bo.tabstop = 8
vim.bo.shiftwidth = 8
vim.bo.softtabstop = 8
vim.bo.textwidth = 80
vim.bo.cindent = true
vim.bo.cinoptions = ":0,l1,t0,g0,(0"
vim.wo.colorcolumn = "81"

local undo = "setlocal et< ts< sw< sts< tw< cin< cino< cc<"
vim.b.undo_ftplugin = vim.b.undo_ftplugin and (vim.b.undo_ftplugin .. " | " .. undo) or undo
