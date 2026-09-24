-- lualine theme: colored mode block, gray segments.

local p = require("vimesimal.palette")

local function mode(accent)
  return {
    a = { fg = p.black, bg = accent, gui = "bold" },
    b = { fg = p.white, bg = p.guide },
    c = { fg = p.faint, bg = p.panel },
  }
end

return {
  normal = mode(p.cyan),
  insert = mode(p.green),
  visual = mode(p.magenta),
  replace = mode(p.red),
  command = mode(p.yellow),
  terminal = mode(p.cyan),
  inactive = {
    a = { fg = p.faint, bg = p.panel },
    b = { fg = p.faint, bg = p.panel },
    c = { fg = p.faint, bg = p.panel },
  },
}
