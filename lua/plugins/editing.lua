-- Editing helpers. Commenting (gc / gcc) is built into Neovim.

return {
  { "windwp/nvim-autopairs", event = "InsertEnter", opts = {} },
  { "kylechui/nvim-surround", version = "^3.0.0", event = "VeryLazy", opts = {} },
  {
    -- Formatters are registered per language via opts.formatters_by_ft.
    "stevearc/conform.nvim",
    cmd = "ConformInfo",
    keys = {
      {
        "<leader>cf",
        function() require("conform").format({ async = true, lsp_format = "fallback" }) end,
        mode = { "n", "x" },
        desc = "Format",
      },
    },
    opts = { formatters_by_ft = {}, formatters = {} },
  },
  { "folke/which-key.nvim", event = "VeryLazy", opts = { win = { border = "single" } } },
}
