-- Claude Code in a split, via claudecode.nvim (Claude's IDE protocol: it sees
-- the current file/selection). Claude proposes each edit in the code window
-- (green/red, y apply / n reject) before it's written; see lua/vimesimal/claude.lua.
-- Prompt popup, quick answers and :ClaudeConfig live in lua/vimesimal/claude.lua.

local function claude(fn)
  return function() require("vimesimal.claude")[fn]() end
end

return {
  "coder/claudecode.nvim",
  cmd = {
    "ClaudeCode", "ClaudeCodeFocus", "ClaudeCodeSelectModel", "ClaudeCodeAdd",
    "ClaudeCodeSend", "ClaudeCodeSendText", "ClaudeCodeStatus", "ClaudeCodeOpen",
    "ClaudeCodeClose",
  },
  keys = {
    { "<leader>ae", claude("quick"), mode = { "n", "x" }, desc = "Claude: edit / quick answer (popup)" },
    { "<leader>ac", claude("prompt"), mode = { "n", "x" }, desc = "Claude: chat (popup -> split)" },
    { "<leader>aa", "<cmd>ClaudeCode<cr>", desc = "Claude: toggle window" },
    { "<leader>ar", "<cmd>ClaudeCode --continue<cr>", desc = "Claude: resume last chat" },
    { "<leader>af", "<cmd>ClaudeCodeAdd %<cr>", desc = "Claude: add current file" },
    { "<leader>as", "<cmd>ClaudeCodeSend<cr>", mode = "x", desc = "Claude: send selection" },
    { "<leader>am", "<cmd>ClaudeCodeSelectModel<cr>", desc = "Claude: pick model" },
  },
  init = function()
    vim.api.nvim_create_user_command("ClaudeConfig", claude("config"), { desc = "Claude settings menu" })

    local group = vim.api.nvim_create_augroup("vimesimal_claude_term", { clear = true })
    local function is_claude(buf) return vim.api.nvim_buf_get_name(buf):find("claude", 1, true) ~= nil end
    vim.api.nvim_create_autocmd("TermOpen", {
      group = group,
      callback = function(ev)
        if not is_claude(ev.buf) then return end
        -- Ctrl-h / Ctrl-l leave the Claude terminal like any split
        -- (Esc stays with Claude: it interrupts a response)
        for _, key in ipairs({ "h", "l" }) do
          vim.keymap.set("t", "<C-" .. key .. ">", "<C-\\><C-n><C-w>" .. key, { buffer = ev.buf })
        end
        -- Watch open files so Claude's edits get the inline review
        require("vimesimal.claude").watch_start()
        -- Save open files when you go to Claude, so it edits what you see
        -- (unsaved edits would conflict with Claude's change on disk)
        vim.api.nvim_create_autocmd({ "BufEnter", "TermEnter" }, {
          group = group, buffer = ev.buf,
          callback = function() require("vimesimal.claude").save_all() end,
        })
      end,
    })
    vim.api.nvim_create_autocmd("TermClose", {
      group = group,
      callback = function(ev)
        if is_claude(ev.buf) then require("vimesimal.claude").watch_stop() end
      end,
    })
  end,
  opts = function()
    return require("vimesimal.claude").plugin_opts()
  end,
  config = function(_, opts)
    require("claudecode").setup(opts)
    -- Proposed edits show in the real file (green/red) and wait for y / n,
    -- instead of claudecode's side-by-side diff (lua/vimesimal/claude.lua)
    require("vimesimal.claude").register_tools()
  end,
}
