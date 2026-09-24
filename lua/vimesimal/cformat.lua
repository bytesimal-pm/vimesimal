-- Highlight printf-style format specifiers (%d, %-8.3lf, %zu, %%) inside
-- C string literals. The tree-sitter C grammar has no node for them, so we
-- scan string_content nodes and lay extmarks over the @string highlight.

local M = {}

local ns = vim.api.nvim_create_namespace("vimesimal.cformat")
local spec = "%%[-+ #0]*[%d%*]*%.?[%d%*]*[hlLqjzt]*[diouxXeEfFgGaAcspn%%]"
local query

local function refresh(buf)
  if not vim.api.nvim_buf_is_valid(buf) then
    return
  end
  vim.api.nvim_buf_clear_namespace(buf, ns, 0, -1)
  local ok, parser = pcall(vim.treesitter.get_parser, buf, "c")
  if not ok or not parser then
    return
  end
  query = query or vim.treesitter.query.parse("c", "(string_content) @content")
  local root = parser:parse()[1]:root()
  for _, node in query:iter_captures(root, buf) do
    local row, col, end_row = node:range()
    if row == end_row then
      local text = vim.treesitter.get_node_text(node, buf)
      local from = 1
      while true do
        local s, e = text:find(spec, from)
        if not s then
          break
        end
        vim.api.nvim_buf_set_extmark(buf, ns, row, col + s - 1, {
          end_col = col + e,
          hl_group = "@string.special",
          priority = 130, -- above tree-sitter (100) and LSP semantic tokens (125)
        })
        from = e + 1
      end
    end
  end
end

function M.attach(buf)
  buf = buf == 0 and vim.api.nvim_get_current_buf() or buf
  if vim.b[buf].vimesimal_cformat then
    return
  end
  vim.b[buf].vimesimal_cformat = true

  local timer = assert(vim.uv.new_timer())
  local function schedule()
    timer:stop()
    timer:start(80, 0, vim.schedule_wrap(function() refresh(buf) end))
  end

  vim.api.nvim_create_autocmd({ "BufWinEnter", "TextChanged", "TextChangedI" }, {
    buffer = buf,
    callback = schedule,
  })
  vim.api.nvim_create_autocmd("BufWipeout", {
    buffer = buf,
    once = true,
    callback = function() timer:close() end,
  })
  schedule()
end

return M
