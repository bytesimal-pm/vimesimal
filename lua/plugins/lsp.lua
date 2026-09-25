-- nvim-lspconfig supplies default server configs; languages add entries to
-- `opts.servers` in lua/lang/<name>.lua. A server is only enabled when its
-- binary is on PATH. When a config's `cmd` is a function (so the binary can't
-- be read from it), the language names it with `bin = "..."`.

return {
  "neovim/nvim-lspconfig",
  event = { "BufReadPre", "BufNewFile" },
  dependencies = { "saghen/blink.cmp" },
  opts = { servers = {} },
  config = function(_, opts)
    vim.lsp.config("*", { capabilities = require("blink.cmp").get_lsp_capabilities() })
    for name, server in pairs(opts.servers) do
      local bin = server.bin
      server.bin = nil
      vim.lsp.config(name, server)
      local cmd = vim.lsp.config[name].cmd
      bin = bin or (type(cmd) == "table" and cmd[1])
      if not bin or vim.fn.executable(bin) == 1 then
        vim.lsp.enable(name)
      end
    end
  end,
}
