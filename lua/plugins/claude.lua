-- Claude Code in a split, via claudecode.nvim (Claude's IDE protocol: it sees
-- the current file/selection, and its edits open as diffs to accept/reject).
-- Prompt popup, quick answers and :ClaudeConfig live in lua/vimesimal/claude.lua.

local function claude(fn)
  return function() require("vimesimal.claude")[fn]() end
end

return {
  "coder/claudecode.nvim",
  cmd = {
    "ClaudeCode", "ClaudeCodeFocus", "ClaudeCodeSelectModel", "ClaudeCodeAdd",
    "ClaudeCodeSend", "ClaudeCodeSendText", "ClaudeCodeStatus", "ClaudeCodeOpen",
    "ClaudeCodeClose", "ClaudeCodeDiffAccept", "ClaudeCodeDiffDeny",
  },
  keys = {
    { "<leader>ae", claude("prompt"), mode = { "n", "x" }, desc = "Claude: ask (popup)" },
    { "<leader>aq", claude("quick"), mode = { "n", "x" }, desc = "Claude: quick answer" },
    { "<leader>aa", "<cmd>ClaudeCode<cr>", desc = "Claude: toggle window" },
    { "<leader>ac", "<cmd>ClaudeCode --continue<cr>", desc = "Claude: continue last chat" },
    { "<leader>af", "<cmd>ClaudeCodeAdd %<cr>", desc = "Claude: add current file" },
    { "<leader>as", "<cmd>ClaudeCodeSend<cr>", mode = "x", desc = "Claude: send selection" },
    { "<leader>am", "<cmd>ClaudeCodeSelectModel<cr>", desc = "Claude: pick model" },
    { "<leader>ay", "<cmd>ClaudeCodeDiffAccept<cr>", desc = "Claude: accept diff" },
    { "<leader>an", "<cmd>ClaudeCodeDiffDeny<cr>", desc = "Claude: reject diff" },
  },
  init = function()
    vim.api.nvim_create_user_command("ClaudeConfig", claude("config"), { desc = "Claude settings menu" })

    -- In the Claude terminal, Ctrl-h / Ctrl-l leave it like any split.
    -- (Esc stays with Claude: it interrupts a response.)
    vim.api.nvim_create_autocmd("TermOpen", {
      group = vim.api.nvim_create_augroup("vimesimal_claude_term", { clear = true }),
      callback = function(ev)
        if vim.api.nvim_buf_get_name(ev.buf):find("claude", 1, true) then
          for _, key in ipairs({ "h", "l" }) do
            vim.keymap.set("t", "<C-" .. key .. ">", "<C-\\><C-n><C-w>" .. key, { buffer = ev.buf })
          end
        end
      end,
    })
  end,
  opts = function()
    return require("vimesimal.claude").plugin_opts()
  end,
}
