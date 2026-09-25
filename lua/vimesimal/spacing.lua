-- Shared helper for after/ftplugin/<lang>.lua:
--   require("vimesimal.spacing").set({ width = 4 })              -- 4 spaces
--   require("vimesimal.spacing").set({ width = 8, tabs = true }) -- hard tabs
-- Also turns off auto-wrap and registers the undo for filetype changes.

local M = {}

function M.set(opts)
  local bo = vim.bo
  bo.expandtab = not opts.tabs
  bo.tabstop = opts.width
  bo.shiftwidth = opts.width
  bo.softtabstop = opts.width
  bo.textwidth = 0
  bo.formatoptions = bo.formatoptions:gsub("[tc]", "")

  local undo = "setlocal et< ts< sw< sts< tw< fo<"
  vim.b.undo_ftplugin = vim.b.undo_ftplugin and (vim.b.undo_ftplugin .. " | " .. undo) or undo
end

return M
