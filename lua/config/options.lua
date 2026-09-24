-- Global editor options. Languages override spacing in after/ftplugin/.

local opt = vim.opt

vim.g.mapleader = " "
vim.g.maplocalleader = ","

-- Terminal
opt.termguicolors = true
opt.mouse = "a"
opt.timeoutlen = 500
opt.updatetime = 250
opt.clipboard = "unnamedplus"
opt.winborder = "single"

-- Line
opt.number = true
opt.relativenumber = true
opt.cursorline = true
opt.signcolumn = "yes"
opt.laststatus = 3
opt.showmode = false
opt.scrolloff = 8
opt.sidescrolloff = 8
opt.wrap = false
opt.list = true
opt.listchars = { tab = "  ", trail = "·", nbsp = "␣", extends = "›", precedes = "‹" }
opt.fillchars = { eob = " ", fold = " " }

-- Default spacing (overridden per language)
opt.expandtab = true
opt.tabstop = 4
opt.shiftwidth = 4
opt.softtabstop = 4
opt.smartindent = true

-- Search
opt.ignorecase = true
opt.smartcase = true
opt.inccommand = "split"

-- Completion / command line
opt.completeopt = { "menuone", "noselect", "popup" }
opt.pumheight = 12

-- Windows, files
opt.splitbelow = true
opt.splitright = true
opt.swapfile = false
opt.undofile = true
