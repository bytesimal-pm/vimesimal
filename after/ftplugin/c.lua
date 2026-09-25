-- C spacing — Linux kernel coding style
-- (Documentation/process/coding-style.rst): hard tabs, 8 wide. No column guide or auto-wrap.

-- Tabs, 8 wide (lua/vimesimal/spacing.lua), plus kernel cindent rules
require("vimesimal.spacing").apply()
vim.bo.cindent = true
vim.bo.cinoptions = ":0,l1,t0,g0,(0"

-- Color %d / %s / … inside strings
require("vimesimal.cformat").attach(0)

local undo = "setlocal cin< cino<"
vim.b.undo_ftplugin = vim.b.undo_ftplugin and (vim.b.undo_ftplugin .. " | " .. undo) or undo
