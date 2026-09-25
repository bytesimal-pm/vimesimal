-- Global keymaps. Plugin keymaps live in their spec under lua/plugins/.

local map = vim.keymap.set

map("n", "<leader>w", "<cmd>write<cr>", { desc = "Save" })
map("n", "<leader>q", "<cmd>bdelete<cr>", { desc = "Close buffer" })
map("n", "<Esc>", "<cmd>nohlsearch<cr>")

-- Diagnostics (errors/warnings) under the cursor, in any buffer.
-- <leader>D lists all of them (lua/plugins/navigate.lua).
map("n", "<leader>d", vim.diagnostic.open_float, { desc = "Line diagnostics" })

-- Windows: <C-h/j/k/l> is in lua/plugins/tmux.lua (works across tmux panes)

-- Buffers
map("n", "<S-l>", "<cmd>bnext<cr>", { desc = "Next buffer" })
map("n", "<S-h>", "<cmd>bprevious<cr>", { desc = "Previous buffer" })

-- Keep selection while indenting; move selected lines
map("x", "<", "<gv")
map("x", ">", ">gv")
map("x", "J", ":move '>+1<cr>gv=gv", { silent = true })
map("x", "K", ":move '<-2<cr>gv=gv", { silent = true })
