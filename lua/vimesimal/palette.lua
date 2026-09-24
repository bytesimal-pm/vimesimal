-- Shared palette for colors/vimesimal.lua and the lualine theme.
-- UI grays follow the kitty theme (black transparent background, white
-- text); accents are neon versions of the Linux console colors.
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

  -- Neon: Linux console hues at full saturation
  red = "#ff2e4c",
  green = "#39ff14",
  yellow = "#ffff00",
  blue = "#001bff", -- neon blue: #0014bf hue at full brightness
  magenta = "#ff00ff",
  cyan = "#00ffff",
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
c.param = "#ff6ec7" -- function parameters
c.member = "#b98cff" -- struct fields
c.comment = c.mute

return c
