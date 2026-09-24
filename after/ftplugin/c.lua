-- C spacing — Linux kernel coding style
-- (Documentation/process/coding-style.rst): hard tabs, 8 wide. No column guide or auto-wrap.

vim.bo.expandtab = false
vim.bo.tabstop = 8
vim.bo.shiftwidth = 8
vim.bo.softtabstop = 8
vim.bo.cindent = true
vim.bo.cinoptions = ":0,l1,t0,g0,(0"
vim.bo.textwidth = 0
vim.bo.formatoptions = vim.bo.formatoptions:gsub("[tc]", "")

-- Color %d / %s / … inside strings
require("vimesimal.cformat").attach(0)

local undo = "setlocal et< ts< sw< sts< tw< fo< cin< cino<"
vim.b.undo_ftplugin = vim.b.undo_ftplugin and (vim.b.undo_ftplugin .. " | " .. undo) or undo
