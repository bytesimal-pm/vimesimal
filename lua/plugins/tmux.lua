-- Ctrl-h/j/k/l moves between Neovim splits and, at the edge, into the next
-- tmux pane. Needs the matching bindings in tmux/tmux.conf; outside tmux it
-- behaves like plain <C-w>h/j/k/l.

return {
  "christoomey/vim-tmux-navigator",
  cmd = { "TmuxNavigateLeft", "TmuxNavigateDown", "TmuxNavigateUp", "TmuxNavigateRight" },
  keys = {
    { "<C-h>", "<cmd>TmuxNavigateLeft<cr>", desc = "Window/pane left" },
    { "<C-j>", "<cmd>TmuxNavigateDown<cr>", desc = "Window/pane down" },
    { "<C-k>", "<cmd>TmuxNavigateUp<cr>", desc = "Window/pane up" },
    { "<C-l>", "<cmd>TmuxNavigateRight<cr>", desc = "Window/pane right" },
  },
  init = function()
    vim.g.tmux_navigator_no_mappings = 1
  end,
}
