-- Lua spacing: 2 spaces; 4 for the Hyprland config (hypr/).
local path = vim.api.nvim_buf_get_name(0)
require("vimesimal.spacing").set({ width = path:find("/hypr/", 1, true) and 4 or 2 })
