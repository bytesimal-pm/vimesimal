-- Global keymaps. Plugin keymaps live in their spec under lua/plugins/.

local map = vim.keymap.set

map("n", "<leader>w", "<cmd>write<cr>", { desc = "Save" })
map("n", "<leader>q", "<cmd>bdelete<cr>", { desc = "Close buffer" })
map("n", "<Esc>", "<cmd>nohlsearch<cr>")

-- Windows
map("n", "<C-h>", "<C-w>h")
map("n", "<C-j>", "<C-w>j")
map("n", "<C-k>", "<C-w>k")
map("n", "<C-l>", "<C-w>l")

-- Buffers
map("n", "<S-l>", "<cmd>bnext<cr>", { desc = "Next buffer" })
map("n", "<S-h>", "<cmd>bprevious<cr>", { desc = "Previous buffer" })

-- Keep selection while indenting; move selected lines
map("x", "<", "<gv")
map("x", ">", ">gv")
map("x", "J", ":move '>+1<cr>gv=gv", { silent = true })
map("x", "K", ":move '<-2<cr>gv=gv", { silent = true })
