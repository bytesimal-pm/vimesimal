-- lazy.nvim: global plugins from lua/plugins/, language plugins from lua/lang/.
-- Language specs extend global ones (e.g. add a server to nvim-lspconfig's
-- `opts.servers`); lazy.nvim merges the opts.

local lazypath = vim.fn.stdpath("data") .. "/lazy/lazy.nvim"
if not vim.uv.fs_stat(lazypath) then
  local out = vim.fn.system({
    "git", "clone", "--filter=blob:none", "--branch=stable",
    "https://github.com/folke/lazy.nvim.git", lazypath,
  })
  if vim.v.shell_error ~= 0 then
    error("Failed to clone lazy.nvim:\n" .. out)
  end
end
vim.opt.rtp:prepend(lazypath)

require("lazy").setup({
  spec = {
    { import = "plugins" },
    { import = "lang" },
  },
  install = { colorscheme = { "vimesimal" } },
  ui = { border = "single" },
  rocks = { enabled = false },
  change_detection = { notify = false },
  performance = {
    rtp = { disabled_plugins = { "gzip", "tarPlugin", "tohtml", "tutor", "zipPlugin" } },
  },
})
