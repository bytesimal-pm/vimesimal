-- NASM spacing: 8 spaces, no tabs, no auto-wrap.

vim.bo.expandtab = true
vim.bo.tabstop = 8
vim.bo.shiftwidth = 8
vim.bo.softtabstop = 8
vim.bo.textwidth = 0
vim.bo.formatoptions = vim.bo.formatoptions:gsub("[tc]", "")

-- gc / gcc comments with ;
vim.bo.commentstring = "; %s"
vim.bo.comments = ":;"

local undo = "setlocal et< ts< sw< sts< tw< fo< cms< com<"
vim.b.undo_ftplugin = vim.b.undo_ftplugin and (vim.b.undo_ftplugin .. " | " .. undo) or undo
