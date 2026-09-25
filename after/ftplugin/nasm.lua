-- NASM spacing (see lua/vimesimal/spacing.lua): 8 spaces, no tabs, no auto-wrap.
require("vimesimal.spacing").apply()

-- gc / gcc comments with ;
vim.bo.commentstring = "; %s"
vim.bo.comments = ":;"

local undo = "setlocal cms< com<"
vim.b.undo_ftplugin = vim.b.undo_ftplugin and (vim.b.undo_ftplugin .. " | " .. undo) or undo
