-- nvim-lspconfig supplies default server configs; languages add entries to
-- `opts.servers` in lua/lang/<name>.lua. A server is only enabled when its
-- binary is on PATH.

return {
  "neovim/nvim-lspconfig",
  event = { "BufReadPre", "BufNewFile" },
  dependencies = { "saghen/blink.cmp" },
  opts = { servers = {} },
  config = function(_, opts)
    vim.lsp.config("*", { capabilities = require("blink.cmp").get_lsp_capabilities() })
    for name, server in pairs(opts.servers) do
      vim.lsp.config(name, server)
      local cmd = vim.lsp.config[name].cmd
      if type(cmd) ~= "table" or vim.fn.executable(cmd[1]) == 1 then
        vim.lsp.enable(name)
      end
    end
  end,
}
