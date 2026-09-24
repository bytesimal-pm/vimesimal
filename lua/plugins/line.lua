-- Line: lualine statusline + gitsigns.
-- Slanted separators match kitty's tab bar (needs a Nerd Font).

return {
  {
    "nvim-lualine/lualine.nvim",
    dependencies = { "nvim-tree/nvim-web-devicons" },
    event = "VeryLazy",
    opts = function()
      return {
        options = {
          theme = require("vimesimal.lualine"),
          globalstatus = true,
          section_separators = { left = "\u{e0bc}", right = "\u{e0ba}" },
          component_separators = { left = "\u{e0bb}", right = "\u{e0bb}" },
        },
        sections = {
          lualine_a = { "mode" },
          lualine_b = { "branch", "diff" },
          lualine_c = { { "filename", path = 1 } },
          lualine_x = {
            { "diagnostics", symbols = { error = "✗", warn = "!", info = "i", hint = "·" } },
            "lsp_status",
            "filetype",
          },
          lualine_y = { "progress" },
          lualine_z = { "location" },
        },
        extensions = { "nvim-tree", "lazy", "fzf" },
      }
    end,
  },
  {
    "lewis6991/gitsigns.nvim",
    event = { "BufReadPre", "BufNewFile" },
    opts = {
      on_attach = function(bufnr)
        local gs = require("gitsigns")
        vim.keymap.set("n", "]h", function() gs.nav_hunk("next") end, { buffer = bufnr, desc = "Next hunk" })
        vim.keymap.set("n", "[h", function() gs.nav_hunk("prev") end, { buffer = bufnr, desc = "Previous hunk" })
        vim.keymap.set("n", "<leader>hp", gs.preview_hunk, { buffer = bufnr, desc = "Preview hunk" })
      end,
    },
  },
}
