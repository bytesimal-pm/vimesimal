-- lualine theme: white mode block, gray segments, a muted accent per mode.

local p = require("vimesimal.palette")

local function mode(accent)
  return {
    a = { fg = p.black, bg = accent, gui = "bold" },
    b = { fg = p.white, bg = p.guide },
    c = { fg = p.faint, bg = p.panel },
  }
end

return {
  normal = mode(p.white),
  insert = mode(p.sage),
  visual = mode(p.steel),
  replace = mode(p.rose),
  command = mode(p.sand),
  terminal = mode(p.teal),
  inactive = {
    a = { fg = p.faint, bg = p.panel },
    b = { fg = p.faint, bg = p.panel },
    c = { fg = p.faint, bg = p.panel },
  },
}
