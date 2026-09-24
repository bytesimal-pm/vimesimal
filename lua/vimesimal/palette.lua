-- Shared palette for colors/vimesimal.lua and the lualine theme.
-- UI grays follow the kitty theme (black transparent background, white
-- text); accents are the Linux console's bright colors, full contrast.
-- To restyle syntax, change the roles at the bottom.

local c = {
  -- UI
  black = "#000000",
  white = "#ffffff",
  dim = "#c8c8c8",
  gray = "#a0a0a0",
  mute = "#808080",
  faint = "#707070",
  guide = "#3a3a3a",
  select = "#34394a",
  line = "#262626",
  panel = "#1a1a1a",

  -- Linux console, bright
  red = "#ff5555",
  green = "#55ff55",
  yellow = "#ffff55",
  blue = "#5c5cff",
  magenta = "#ff55ff",
  cyan = "#55ffff",
}

-- Syntax roles (Vim's classic console mapping)
c.keyword = c.yellow
c.func = c.cyan
c.type = c.green
c.string = c.magenta
c.number = c.magenta
c.preproc = c.blue
c.special = c.red
c.escape = c.cyan -- \n, \t inside strings
c.format = c.yellow -- %d, %s inside strings
c.operator = c.red -- = < ++ -> (moonfly-style: operators colored, variables white)
c.param = "#ff87d7" -- function parameters
c.member = "#afafff" -- struct fields
c.comment = c.mute

return c
