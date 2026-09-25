-- Jump to any visible word: press f, type as much of the word as you like,
-- then Enter (jumps to the highlighted match) or the label shown on a match.
--   f bord <Enter>   -> border
-- Labels never use a letter that could continue the word, so typing more is
-- safe. This replaces Vim's one-character f; F, t, T and ; , are unchanged.

return {
  "folke/flash.nvim",
  event = "VeryLazy",
  opts = {
    -- No autojump: it would jump mid-word and run the rest of the typed
    -- letters as commands (typing "f border" turned border into dorder).
    jump = { autojump = false },
    modes = {
      char = { enabled = false }, -- leave F/t/T exactly as Vim does them
    },
  },
  keys = {
    { "f", mode = { "n", "x", "o" }, function() require("flash").jump() end, desc = "Jump to word" },
    { "S", mode = { "n", "x", "o" }, function() require("flash").treesitter() end, desc = "Select code block" },
  },
}
