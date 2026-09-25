-- Indentation per filetype: the single source of truth, used by
-- after/ftplugin/<lang>.lua (M.apply) and by Claude (M.describe for its
-- instructions, M.normalize for its proposed edits).
--   require("vimesimal.spacing").apply()   -- in an ftplugin
-- Filetypes not listed use the global default from lua/config/options.lua.

local M = {}

M.default = { width = 4 }

M.styles = {
  c = { width = 8, tabs = true },
  make = { width = 8, tabs = true },
  ld = { width = 8, tabs = true },
  nasm = { width = 8 },
  python = { width = 4 },
  qml = { width = 4 },
  sh = { width = 4 },
  bash = { width = 4 },
  zsh = { width = 4 },
  lua = { width = 2, paths = { ["/hypr/"] = { width = 4 } } },
  javascript = { width = 2 },
  javascriptreact = { width = 2 },
  typescript = { width = 2 },
  typescriptreact = { width = 2 },
}

-- Plain-language names for Claude's instructions
local names = {
  c = "C (.c, .h)", make = "Makefiles", ld = "linker scripts (.ld, .lds)", nasm = "NASM assembly (.asm)",
  python = "Python", qml = "QML", sh = "shell scripts", bash = "bash", zsh = "zsh", lua = "Lua",
  javascript = "JavaScript", javascriptreact = "JSX", typescript = "TypeScript", typescriptreact = "TSX",
}

-- Style for a filetype, honoring path rules (e.g. hypr/ Lua uses 4 spaces)
function M.style(ft, path)
  local s = M.styles[ft] or M.default
  for pattern, override in pairs(s.paths or {}) do
    if path and path:find(pattern, 1, true) then return override end
  end
  return s
end

function M.set(opts)
  local bo = vim.bo
  bo.expandtab = not opts.tabs
  bo.tabstop = opts.width
  bo.shiftwidth = opts.width
  bo.softtabstop = opts.width
  bo.textwidth = 0
  bo.formatoptions = bo.formatoptions:gsub("[tc]", "")

  local undo = "setlocal et< ts< sw< sts< tw< fo<"
  vim.b.undo_ftplugin = vim.b.undo_ftplugin and (vim.b.undo_ftplugin .. " | " .. undo) or undo
end

-- Apply the configured style to the current buffer
function M.apply(ft)
  M.set(M.style(ft or vim.bo.filetype, vim.api.nvim_buf_get_name(0)))
end

local function words(s)
  return s.tabs and ("hard tabs (tab width " .. s.width .. ")") or (s.width .. " spaces")
end

-- The rules as plain text, for Claude's instructions
function M.describe()
  local by_style = {}
  local order = {}
  for ft, s in pairs(M.styles) do
    local key = words(s)
    if not by_style[key] then by_style[key] = {} ; order[#order + 1] = key end
    local label = names[ft] or ft
    for pattern, override in pairs(s.paths or {}) do
      label = ("%s (but %s for files under %s)"):format(label, words(override), pattern)
    end
    table.insert(by_style[key], label)
  end
  table.sort(order)
  local lines = {}
  for _, key in ipairs(order) do
    table.sort(by_style[key])
    lines[#lines + 1] = ("- %s: %s"):format(table.concat(by_style[key], ", "), key)
  end
  lines[#lines + 1] = ("- anything else: %s"):format(words(M.default))
  return "Indent code with the user's editor settings, even where a file currently uses "
    .. "something else:\n" .. table.concat(lines, "\n")
end

-- Re-indent `lines` (only the indexes in `rows`, or all) to style `s`.
-- The unit the text was written with (e.g. 4 spaces) is detected from the
-- leading spaces, and each level becomes one tab or `s.width` spaces;
-- leftover spaces (alignment) are kept.
function M.normalize(lines, s, rows)
  rows = rows or vim.tbl_keys(lines)
  local function gcd(a, b) while b > 0 do a, b = b, a % b end return a end
  local unit = 0
  for _, i in ipairs(rows) do
    local spaces = lines[i]:match("^\t*( *)%S")
    if spaces and #spaces > 0 then unit = gcd(unit, #spaces) end
  end
  if unit == 1 then unit = 0 end -- odd alignment, not a real indent unit
  local out = vim.deepcopy(lines)
  for _, i in ipairs(rows) do
    local tabs, spaces, rest = lines[i]:match("^(\t*)( *)(.*)$")
    local levels, extra = #tabs, #spaces
    if unit > 0 then levels, extra = levels + math.floor(#spaces / unit), #spaces % unit end
    if rest ~= "" then
      local indent = s.tabs and string.rep("\t", levels) or string.rep(" ", levels * s.width)
      out[i] = indent .. string.rep(" ", extra) .. rest
    end
  end
  return out
end

return M
