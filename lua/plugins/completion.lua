-- Auto suggest: blink.cmp popup (LSP, paths, buffer words, snippets).
--
-- Menu keys: while typing, j/k/y/n are ordinary letters. Press <Tab> to step
-- into the menu (selects an item); from then on
--   j / k  move down / up    y  accept    n  cancel
-- and any other key keeps typing. <CR> also accepts, <S-Tab> moves up.

-- Run a menu action only once an item is selected; otherwise type the letter.
local function in_menu(action)
  return function(cmp)
    if cmp.is_menu_visible() and cmp.get_selected_item() then
      return cmp[action]()
    end
  end
end

return {
  "saghen/blink.cmp",
  version = "1.*",
  event = { "InsertEnter", "CmdlineEnter" },
  opts = {
    keymap = {
      preset = "none",
      ["<Tab>"] = { "select_next", "snippet_forward", "fallback" },
      ["<S-Tab>"] = { "select_prev", "snippet_backward", "fallback" },
      ["j"] = { in_menu("select_next"), "fallback" },
      ["k"] = { in_menu("select_prev"), "fallback" },
      ["y"] = { in_menu("accept"), "fallback" },
      ["n"] = { in_menu("cancel"), "fallback" },
      ["<CR>"] = { "accept", "fallback" },
      ["<C-Space>"] = { "show", "show_documentation", "hide_documentation" },
      ["<C-e>"] = { "hide", "fallback" },
      ["<C-b>"] = { "scroll_documentation_up", "fallback" },
      ["<C-f>"] = { "scroll_documentation_down", "fallback" },
    },
    completion = {
      list = { selection = { preselect = false, auto_insert = false } },
      documentation = { auto_show = true, auto_show_delay_ms = 300 },
    },
    signature = { enabled = true },
    sources = { default = { "lsp", "path", "snippets", "buffer" } },
    fuzzy = { implementation = "prefer_rust_with_warning" },
  },
}
