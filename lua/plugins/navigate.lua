-- Navigate: fzf-lua pickers + nvim-tree drawer.

local function fzf(cmd)
  return "<cmd>FzfLua " .. cmd .. "<cr>"
end

return {
  {
    "ibhagwan/fzf-lua",
    dependencies = { "nvim-tree/nvim-web-devicons" },
    cmd = "FzfLua",
    keys = {
      { "<leader>f", fzf("files"), desc = "Files" },
      { "<leader>g", fzf("live_grep"), desc = "Grep" },
      { "<leader>b", fzf("buffers"), desc = "Buffers" },
      { "<leader>/", fzf("blines"), desc = "Lines in buffer" },
      { "<leader>r", fzf("oldfiles"), desc = "Recent files" },
      { "<leader>o", fzf("lsp_document_symbols"), desc = "Document symbols" },
      { "<leader>S", fzf("lsp_live_workspace_symbols"), desc = "Workspace symbols" },
      { "<leader>d", fzf("diagnostics_document"), desc = "Diagnostics" },
    },
    opts = {
      fzf_colors = true,
      winopts = { border = "single", preview = { border = "single" } },
    },
  },
  {
    "nvim-tree/nvim-tree.lua",
    dependencies = { "nvim-tree/nvim-web-devicons" },
    cmd = { "NvimTreeToggle", "NvimTreeFindFileToggle" },
    keys = { { "<leader>e", "<cmd>NvimTreeFindFileToggle<cr>", desc = "File tree" } },
    opts = {
      view = { width = 32 },
      renderer = { indent_markers = { enable = true }, root_folder_label = ":~" },
      filters = { dotfiles = false },
      on_attach = function(bufnr)
        local api = require("nvim-tree.api")
        api.config.mappings.default_on_attach(bufnr)
        local map = function(lhs, rhs, desc)
          vim.keymap.set("n", lhs, rhs, { buffer = bufnr, nowait = true, desc = desc })
        end
        map("l", api.node.open.edit, "Open")
        map("h", api.node.navigate.parent_close, "Close folder")
      end,
    },
  },
}
