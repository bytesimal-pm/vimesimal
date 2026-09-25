-- Claude Code helpers on top of claudecode.nvim (lua/plugins/claude.lua):
--   M.prompt()  <leader>ae  popup -> sends the prompt (and selection) to the
--                           Claude split
--   M.quick()   <leader>aq  popup -> `claude -p`, answer in a floating window
--   M.config()  :ClaudeConfig  menu for model / permissions / window
-- Settings persist in stdpath("data")/vimesimal-claude.json.

local M = {}

local path = vim.fn.stdpath("data") .. "/vimesimal-claude.json"
local defaults = { model = "default", permission_mode = "default", side = "right", width = 0.40 }

-- Settings ---------------------------------------------------------------------

function M.load()
  local ok, data = pcall(function()
    return vim.json.decode(table.concat(vim.fn.readfile(path), "\n"))
  end)
  return vim.tbl_extend("force", vim.deepcopy(defaults), ok and type(data) == "table" and data or {})
end

function M.save(settings)
  vim.fn.mkdir(vim.fn.fnamemodify(path, ":h"), "p")
  vim.fn.writefile({ vim.json.encode(settings) }, path)
end

-- Command line for the Claude split, e.g. "claude --model sonnet"
function M.cmd(s)
  s = s or M.load()
  local cmd = "claude"
  if s.model ~= "default" then cmd = cmd .. " --model " .. s.model end
  if s.permission_mode ~= "default" then cmd = cmd .. " --permission-mode " .. s.permission_mode end
  return cmd
end

-- Options handed to claudecode.nvim's setup()
function M.plugin_opts(s)
  s = s or M.load()
  return {
    terminal_cmd = M.cmd(s),
    terminal = { provider = "native", split_side = s.side, split_width_percentage = s.width },
    diff_opts = { layout = "vertical" },
  }
end

-- Push changed settings into an already-loaded plugin (next session uses them)
local function apply(s)
  if package.loaded["claudecode"] then
    local o = M.plugin_opts(s)
    require("claudecode.terminal").setup(o.terminal, o.terminal_cmd)
  end
end

-- Context ----------------------------------------------------------------------

-- File relative to cwd, plus the selected line range when called from visual mode
local function context()
  local ctx = { file = vim.fn.expand("%:.") }
  local mode = vim.fn.mode()
  if mode == "v" or mode == "V" or mode == "\22" then
    local s, e = vim.fn.line("v"), vim.fn.line(".")
    if s > e then s, e = e, s end
    ctx.first, ctx.last = s, e
    ctx.lines = vim.api.nvim_buf_get_lines(0, s - 1, e, false)
    vim.api.nvim_feedkeys(vim.keycode("<Esc>"), "nx", false)
  end
  if ctx.file == "" then ctx.file = nil end
  return ctx
end

local function label(ctx)
  if not ctx.file then return nil end
  return ctx.first and ("@%s#L%d-%d"):format(ctx.file, ctx.first, ctx.last) or ("@" .. ctx.file)
end

-- Popup input ------------------------------------------------------------------

-- One-line floating input. on_submit(text) runs on <CR> with non-empty text.
local function input(title, footer, on_submit)
  local buf = vim.api.nvim_create_buf(false, true)
  local width = math.min(80, math.floor(vim.o.columns * 0.7))
  local cfg = {
    relative = "editor",
    row = math.floor((vim.o.lines - 3) / 2),
    col = math.floor((vim.o.columns - width) / 2),
    width = width,
    height = 1,
    style = "minimal",
    border = "single",
    title = " " .. title .. " ",
    title_pos = "center",
  }
  if footer then -- footer_pos is only allowed together with a footer
    cfg.footer, cfg.footer_pos = " " .. footer .. " ", "right"
  end
  local win = vim.api.nvim_open_win(buf, true, cfg)
  vim.bo[buf].bufhidden = "wipe"
  vim.wo[win].wrap = true

  local function close()
    vim.cmd.stopinsert()
    if vim.api.nvim_win_is_valid(win) then vim.api.nvim_win_close(win, true) end
  end
  local function submit()
    local text = vim.trim(table.concat(vim.api.nvim_buf_get_lines(buf, 0, -1, false), " "))
    close()
    if text ~= "" then vim.schedule(function() on_submit(text) end) end
  end

  local map = function(mode, lhs, rhs) vim.keymap.set(mode, lhs, rhs, { buffer = buf, nowait = true }) end
  map({ "i", "n" }, "<CR>", submit)
  map("n", "<Esc>", close)
  map("n", "q", close)
  vim.api.nvim_create_autocmd("WinLeave", { buffer = buf, once = true, callback = close })
  vim.cmd.startinsert()
end

-- Send to the Claude split -----------------------------------------------------

-- Run fn once Claude's IDE connection is up (starts the split if needed)
local function when_connected(fn)
  local cc = require("claudecode")
  if cc.is_claude_connected() then return fn() end
  require("claudecode.terminal").open()
  local waited = 0
  local timer = assert(vim.uv.new_timer())
  timer:start(200, 200, vim.schedule_wrap(function()
    waited = waited + 200
    if cc.is_claude_connected() then
      timer:stop(); timer:close()
      fn()
    elseif waited >= 15000 then
      timer:stop(); timer:close()
      vim.notify("Claude didn't connect within 15s (check :ClaudeCodeStatus)", vim.log.levels.WARN)
    end
  end))
end

function M.prompt()
  local ctx = context()
  input("Ask Claude", ctx.first and label(ctx), function(text)
    when_connected(function()
      if ctx.first then
        vim.cmd(("ClaudeCodeAdd %s %d %d"):format(vim.fn.fnameescape(ctx.file), ctx.first, ctx.last))
      end
      -- Give the @-mention a moment to land before the prompt is submitted
      vim.defer_fn(function()
        require("claudecode.terminal").send_to_terminal(text, { submit = true })
      end, ctx.first and 300 or 0)
    end)
  end)
end

-- Quick answer (claude -p) -----------------------------------------------------

local function answer_window(lines)
  local buf = vim.api.nvim_create_buf(false, true)
  local width = math.min(100, math.floor(vim.o.columns * 0.75))
  local height = math.min(30, math.floor(vim.o.lines * 0.6))
  local win = vim.api.nvim_open_win(buf, true, {
    relative = "editor",
    row = math.floor((vim.o.lines - height) / 2),
    col = math.floor((vim.o.columns - width) / 2),
    width = width,
    height = height,
    style = "minimal",
    border = "single",
    title = " Claude ",
    title_pos = "center",
    footer = " q close · y yank ",
    footer_pos = "right",
  })
  vim.bo[buf].bufhidden = "wipe"
  vim.bo[buf].filetype = "markdown"
  vim.wo[win].wrap = true
  vim.wo[win].linebreak = true
  local function set(l)
    if vim.api.nvim_buf_is_valid(buf) then
      vim.bo[buf].modifiable = true
      vim.api.nvim_buf_set_lines(buf, 0, -1, false, l)
      vim.bo[buf].modifiable = false
    end
  end
  set(lines)
  local map = function(lhs, rhs) vim.keymap.set("n", lhs, rhs, { buffer = buf, nowait = true }) end
  map("q", function() vim.api.nvim_win_close(win, true) end)
  map("<Esc>", function() vim.api.nvim_win_close(win, true) end)
  map("y", function()
    vim.fn.setreg("+", table.concat(vim.api.nvim_buf_get_lines(buf, 0, -1, false), "\n"))
    vim.notify("Answer copied")
  end)
  return set
end

function M.quick()
  local ctx = context()
  input("Quick answer", label(ctx), function(text)
    local prompt = text
    if ctx.lines then
      prompt = ("%s\n\nContext: %s lines %d-%d:\n```\n%s\n```"):format(
        text, ctx.file or "buffer", ctx.first, ctx.last, table.concat(ctx.lines, "\n"))
    elseif ctx.file then
      prompt = ("%s\n\n(I'm editing %s)"):format(text, ctx.file)
    end
    local s = M.load()
    local cmd = { "claude", "-p", prompt }
    if s.model ~= "default" then vim.list_extend(cmd, { "--model", s.model }) end

    local set = answer_window({ "Thinking…" })
    vim.system(cmd, { text = true }, vim.schedule_wrap(function(res)
      local out = res.code == 0 and res.stdout or ("Error (exit " .. res.code .. "):\n" .. (res.stderr or ""))
      set(vim.split(vim.trim(out), "\n"))
    end))
  end)
end

-- :ClaudeConfig ----------------------------------------------------------------

local choices = {
  { key = "model", name = "Model", values = { "default", "opus", "sonnet", "haiku" } },
  { key = "permission_mode", name = "Permission mode", values = { "default", "acceptEdits", "plan" } },
  { key = "side", name = "Window side", values = { "right", "left" } },
  { key = "width", name = "Window width", values = { 0.30, 0.40, 0.50 } },
}

local function show(v)
  return type(v) == "number" and (math.floor(v * 100 + 0.5) .. "%") or tostring(v)
end

function M.config()
  local s = M.load()
  local items = vim.tbl_map(function(c) return c.name .. ": " .. show(s[c.key]) end, choices)
  vim.ui.select(items, { prompt = "Claude settings" }, function(_, idx)
    if not idx then return end
    local c = choices[idx]
    vim.ui.select(c.values, { prompt = c.name, format_item = show }, function(value)
      if value == nil then return end
      s[c.key] = value
      M.save(s)
      apply(s)
      vim.notify(("Claude %s: %s (applies to the next session; <leader>aa twice restarts)")
        :format(c.name:lower(), show(value)))
    end)
  end)
end

return M
