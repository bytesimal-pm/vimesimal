-- Claude Code helpers on top of claudecode.nvim (lua/plugins/claude.lua):
--   M.quick()   <leader>ae  popup -> `claude -p`: answers in a float and may
--                           edit the current file (red/green diff, y keep / n undo)
--   M.prompt()  <leader>ac  popup -> sends the prompt (and selection) to the
--                           Claude split (chat)
--   M.config()  :ClaudeConfig  menu for model / permissions / window
-- Settings persist in stdpath("data")/vimesimal-claude.json.

local M = {}

local path = vim.fn.stdpath("data") .. "/vimesimal-claude.json"
-- permission_mode "manual": Claude proposes each edit and waits (reviewed in the code window)
local defaults = { model = "default", permission_mode = "manual", side = "right", width = 0.40 }

-- Settings ---------------------------------------------------------------------

function M.load()
  local ok, data = pcall(function()
    return vim.json.decode(table.concat(vim.fn.readfile(path), "\n"))
  end)
  local settings = vim.tbl_extend("force", vim.deepcopy(defaults), ok and type(data) == "table" and data or {})
  if settings.permission_mode == "default" then settings.permission_mode = "manual" end -- old name
  return settings
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
  cmd = cmd .. " --permission-mode " .. s.permission_mode
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
  input("Claude chat", ctx.first and label(ctx), function(text)
    M.save_all() -- Claude reads files from disk: save what's on screen
    when_connected(function()
      if ctx.first then
        vim.cmd(("ClaudeCodeAdd %s %d %d"):format(vim.fn.fnameescape(ctx.file), ctx.first, ctx.last))
      end
      -- Give the @-mention a moment to land, then type the prompt and press
      -- Enter separately: sent together, Claude reads a long prompt plus the
      -- Enter as one paste and the Enter doesn't submit.
      vim.defer_fn(function()
        local term = require("claudecode.terminal")
        if not term.send_to_terminal(text, { submit = false }) then return end
        vim.defer_fn(function()
          local buf = term.get_active_terminal_bufnr()
          local chan = buf and (vim.b[buf].terminal_job_id or vim.bo[buf].channel)
          if chan and chan > 0 then pcall(vim.fn.chansend, chan, "\r") end
        end, 200)
      end, ctx.first and 300 or 0)
    end)
  end)
end

-- Quick edit / answer (claude -p) ---------------------------------------------
-- With a real file open, Claude may edit it (tools limited to Read + Edit).
-- The change is shown in the code window like VS Code: added/changed lines
-- green, removed lines as red ghost lines, and a small bar at the top with
-- y keep / n undo. Plain questions get a centered answer popup.

local diff_ns = vim.api.nvim_create_namespace("vimesimal.claude.diff")

-- Centered popup with an answer (q/Esc close, y copy)
local function answer_window(lines)
  local buf = vim.api.nvim_create_buf(false, true)
  local width = math.min(100, math.floor(vim.o.columns * 0.75))
  local height = math.min(30, math.max(3, #lines + 1))
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
    footer = " q close · y copy ",
    footer_pos = "right",
  })
  vim.api.nvim_buf_set_lines(buf, 0, -1, false, lines)
  vim.bo[buf].modifiable = false
  vim.bo[buf].bufhidden = "wipe"
  vim.bo[buf].filetype = "markdown"
  vim.wo[win].wrap = true
  vim.wo[win].linebreak = true
  local map = function(lhs, rhs) vim.keymap.set("n", lhs, rhs, { buffer = buf, nowait = true }) end
  local function close()
    if vim.api.nvim_win_is_valid(win) then vim.api.nvim_win_close(win, true) end
  end
  map("q", close)
  map("<Esc>", close)
  map("y", function()
    vim.fn.setreg("+", table.concat(lines, "\n"))
    vim.notify("Answer copied")
  end)
end

-- Inline review ----------------------------------------------------------------
-- Shared by <leader>ae (quick edit) and the chat split: when Claude changes a
-- file that's open, the change shows in the code window (green = added or
-- changed, red ghost lines = removed) with a bar at the top: y keep, n undo.
-- Several edits to one file in a row stay one review against the original.

local reviews = {} -- bufnr -> { path, before, reply, finish }
local ignore = {} -- path -> uv.now() until which disk changes are ours, not Claude's

-- Top bar: anchored to the top-right of a code window, never takes focus
local bar = { buf = nil, win = nil }

function bar.show(lines, footer, win)
  win = (win and vim.api.nvim_win_is_valid(win)) and win or vim.api.nvim_get_current_win()
  if not (bar.buf and vim.api.nvim_buf_is_valid(bar.buf)) then
    bar.buf = vim.api.nvim_create_buf(false, true)
    vim.bo[bar.buf].bufhidden = "wipe"
  end
  local width = math.min(70, math.max(30, math.floor(vim.api.nvim_win_get_width(win) * 0.6)))
  local height = 0
  for _, l in ipairs(lines) do height = height + math.max(1, math.ceil(vim.fn.strdisplaywidth(l) / width)) end
  local cfg = {
    relative = "win", win = win, anchor = "NE", row = 0, col = vim.api.nvim_win_get_width(win),
    width = width, height = math.min(height, 8),
    style = "minimal", border = "single", focusable = false, zindex = 60,
    title = " Claude ", title_pos = "left",
  }
  if footer then cfg.footer, cfg.footer_pos = " " .. footer .. " ", "right" end
  vim.api.nvim_buf_set_lines(bar.buf, 0, -1, false, lines)
  if bar.win and vim.api.nvim_win_is_valid(bar.win) then
    vim.api.nvim_win_set_config(bar.win, cfg)
  else
    bar.win = vim.api.nvim_open_win(bar.buf, false, cfg)
    vim.wo[bar.win].wrap = true
    vim.wo[bar.win].linebreak = true
  end
end

function bar.close()
  if bar.win and vim.api.nvim_win_is_valid(bar.win) then vim.api.nvim_win_close(bar.win, true) end
  bar.win = nil
end

-- One line per file under review
local function render_bar()
  local lines, win = {}, nil
  for bufnr, r in pairs(reviews) do
    local name = vim.fn.fnamemodify(r.path, ":.")
    local text = r.reply and table.concat(r.reply, " ") or "changed by Claude"
    lines[#lines + 1] = ("%s: %s"):format(name, text)
    local w = vim.fn.bufwinid(bufnr)
    if w ~= -1 then win = w end
  end
  if #lines == 0 then return bar.close() end
  bar.show(lines, "y keep · n undo  (in the file)", win)
end

-- Tabs -> spaces so ghost lines line up with the real code
local function expand(line, ts)
  return (line:gsub("\t", string.rep(" ", ts)))
end

-- Draw old -> new of `bufnr`; returns the first changed row and ghost count above line 1
local function draw(bufnr, before, after)
  local win = vim.fn.bufwinid(bufnr)
  local width = win ~= -1 and vim.api.nvim_win_get_width(win) or vim.o.columns
  local ts = vim.bo[bufnr].tabstop
  local hunks = vim.diff(table.concat(before, "\n") .. "\n", table.concat(after, "\n") .. "\n",
    { result_type = "indices" }) or {}
  vim.api.nvim_buf_clear_namespace(bufnr, diff_ns, 0, -1)
  local first_row, top_ghosts
  for _, h in ipairs(hunks) do
    local sa, ca, sb, cb = h[1], h[2], h[3], h[4]
    -- Added / changed lines: green background, green bar in the gutter
    for row = sb - 1, sb + cb - 2 do
      vim.api.nvim_buf_set_extmark(bufnr, diff_ns, row, 0, {
        line_hl_group = "VimesimalDiffAddLine", sign_text = "┃",
        sign_hl_group = "VimesimalDiffAddSign", priority = 200,
      })
    end
    -- Removed lines: red ghost lines where they used to be
    if ca > 0 then
      local ghost = {}
      for i = sa, sa + ca - 1 do
        local text = expand(before[i], ts)
        ghost[#ghost + 1] = { { text .. string.rep(" ", math.max(0, width - vim.fn.strdisplaywidth(text))),
          "VimesimalDiffDelete" } }
      end
      local row, above = sb - 1, true
      if cb == 0 then row, above = math.max(sb - 1, 0), sb == 0 end -- pure delete: below line sb
      row = math.min(row, vim.api.nvim_buf_line_count(bufnr) - 1)
      vim.api.nvim_buf_set_extmark(bufnr, diff_ns, row, 0, { virt_lines = ghost, virt_lines_above = above })
      if row == 0 and above then top_ghosts = #ghost end
    end
    first_row = first_row or math.max(0, sb - 1)
  end
  return first_row, top_ghosts
end

-- Start (or extend) the review of `bufnr`: `before` is what the file was,
-- `after` what Claude made it. The buffer must already show `after`.
local function start_review(bufnr, path, before, after, reply)
  local prev = reviews[bufnr]
  if prev then
    before = prev.before -- keep reviewing against the original
    reply = reply or prev.reply
    prev.finish(true, true)
  end
  if vim.deep_equal(before, after) then return render_bar() end

  local first_row, top_ghosts = draw(bufnr, before, after)
  local win = vim.fn.bufwinid(bufnr)
  if win ~= -1 and first_row then
    vim.api.nvim_win_set_cursor(win, { first_row + 1, 0 })
    vim.api.nvim_win_call(win, function()
      vim.cmd("normal! zz")
      -- Ghost lines above line 1 only show when the view is scrolled to them
      if top_ghosts and vim.fn.line("w0") == 1 then
        vim.fn.winrestview({ topline = 1, topfill = top_ghosts })
      end
    end)
  end

  local group = vim.api.nvim_create_augroup("vimesimal_claude_review_" .. bufnr, { clear = true })
  local done = false
  local function finish(keep, silent)
    if done then return end
    done = true
    reviews[bufnr] = nil
    pcall(vim.api.nvim_del_augroup_by_id, group)
    if vim.api.nvim_buf_is_valid(bufnr) then
      vim.api.nvim_buf_clear_namespace(bufnr, diff_ns, 0, -1)
      pcall(vim.keymap.del, "n", "y", { buffer = bufnr })
      pcall(vim.keymap.del, "n", "n", { buffer = bufnr })
    end
    if not keep then
      ignore[path] = vim.uv.now() + 1500 -- our own write, not Claude's
      vim.fn.writefile(before, path)
      if vim.api.nvim_buf_is_valid(bufnr) then vim.cmd.checktime(bufnr) end
      vim.notify("Claude's change undone: " .. vim.fn.fnamemodify(path, ":."))
    end
    if not silent then render_bar() end
  end
  reviews[bufnr] = { path = path, before = before, reply = reply, finish = finish }

  -- y / n only while the review is open, only in this buffer
  vim.keymap.set("n", "y", function() finish(true) end, { buffer = bufnr, nowait = true, desc = "Keep Claude's change" })
  vim.keymap.set("n", "n", function() finish(false) end, { buffer = bufnr, nowait = true, desc = "Undo Claude's change" })
  -- Editing the file yourself means you kept it. The reload of Claude's edit
  -- fires TextChanged too (later), so only count changes after this point.
  local tick = vim.api.nvim_buf_get_changedtick(bufnr)
  vim.api.nvim_create_autocmd({ "TextChanged", "TextChangedI" }, {
    group = group, buffer = bufnr,
    callback = function()
      if vim.api.nvim_buf_get_changedtick(bufnr) ~= tick then finish(true) end
    end,
  })
  render_bar()
end

-- Watching files for the chat split --------------------------------------------
-- While the Claude split runs, files open in Neovim are watched. On a change
-- the watcher remembers the buffer's text and triggers Neovim's reload; after
-- the reload (FileChangedShellPost) the change is reviewed inline. The
-- FileChangedShell hook below also replaces the W11/W12 prompts for our own
-- writes and for reloads during a review.

local watch = { active = false, dirs = {}, timers = {} }
local pending = {} -- bufnr -> buffer lines just before a reload

local function loaded_buf(path)
  for _, b in ipairs(vim.api.nvim_list_bufs()) do
    if vim.api.nvim_buf_is_loaded(b) and vim.api.nvim_buf_get_name(b) == path then return b end
  end
end

local function on_disk_change(path)
  local bufnr = loaded_buf(path)
  if not bufnr then return end
  -- An unmodified buffer is reloaded by 'autoread' without FileChangedShell,
  -- so remember its text here; FileChangedShellPost then starts the review.
  local ours = ignore[path] and vim.uv.now() < ignore[path]
  if not ours and not vim.bo[bufnr].modified and not pending[bufnr] then
    local ok, new = pcall(vim.fn.readfile, path)
    local old = vim.api.nvim_buf_get_lines(bufnr, 0, -1, false)
    if ok and not vim.deep_equal(old, new) then pending[bufnr] = old end
  end
  vim.cmd.checktime(bufnr)
end

local fcs = vim.api.nvim_create_augroup("vimesimal_claude_fcs", { clear = true })
vim.api.nvim_create_autocmd("FileChangedShell", {
  group = fcs,
  callback = function(ev)
    local path = vim.api.nvim_buf_get_name(ev.buf)
    local reason = vim.v.fcs_reason
    if ignore[path] and vim.uv.now() < ignore[path] then
      vim.v.fcs_choice = "reload" -- our own write (undo / quick edit)
    elseif reason == "changed" and (watch.active or reviews[ev.buf]) then
      pending[ev.buf] = vim.api.nvim_buf_get_lines(ev.buf, 0, -1, false)
      vim.v.fcs_choice = "reload"
    elseif reason == "changed" or reason == "mode" or reason == "time" then
      vim.v.fcs_choice = "reload" -- same as 'autoread' for an unmodified buffer
    else
      vim.v.fcs_choice = "ask" -- conflict with your unsaved edits, or deleted: let Neovim ask
    end
  end,
})
vim.api.nvim_create_autocmd("FileChangedShellPost", {
  group = fcs,
  callback = function(ev)
    local old = pending[ev.buf]
    pending[ev.buf] = nil
    if not old then return end
    local new = vim.api.nvim_buf_get_lines(ev.buf, 0, -1, false)
    local before = reviews[ev.buf] and reviews[ev.buf].before or old
    start_review(ev.buf, vim.api.nvim_buf_get_name(ev.buf), before, new, nil)
  end,
})

local function watch_dir(dir)
  if watch.dirs[dir] then return end
  local handle = vim.uv.new_fs_event()
  if not handle then return end
  local ok = pcall(handle.start, handle, dir, {}, function(err, fname)
    if err or not fname then return end
    local path = dir .. "/" .. fname
    vim.schedule(function()
      -- Editors and tools write in bursts; react once it settles
      local t = watch.timers[path] or vim.uv.new_timer()
      watch.timers[path] = t
      t:stop()
      t:start(150, 0, vim.schedule_wrap(function() on_disk_change(path) end))
    end)
  end)
  if ok then watch.dirs[dir] = handle else handle:close() end
end

local function watch_buf(bufnr)
  local name = vim.api.nvim_buf_get_name(bufnr)
  if name ~= "" and vim.bo[bufnr].buftype == "" then watch_dir(vim.fs.dirname(name)) end
end

function M.watch_start()
  if watch.active then return end
  watch.active = true
  for _, b in ipairs(vim.api.nvim_list_bufs()) do
    if vim.api.nvim_buf_is_loaded(b) then watch_buf(b) end
  end
  vim.api.nvim_create_autocmd({ "BufReadPost", "BufNewFile" }, {
    group = vim.api.nvim_create_augroup("vimesimal_claude_watch", { clear = true }),
    callback = function(ev) watch_buf(ev.buf) end,
  })
end

function M.watch_stop()
  watch.active = false
  pcall(vim.api.nvim_del_augroup_by_name, "vimesimal_claude_watch")
  for dir, handle in pairs(watch.dirs) do
    handle:stop(); handle:close()
    watch.dirs[dir] = nil
  end
  for path, t in pairs(watch.timers) do
    t:stop(); t:close()
    watch.timers[path] = nil
  end
end

-- Proposed edits (chat split, permission mode "manual") -------------------------
-- Claude's IDE tool `openDiff` is replaced so a proposed edit shows in the real
-- file: the buffer displays the new text (disk untouched) with green/red marks,
-- Claude waits; y answers FILE_SAVED (Claude then writes the file) and n
-- restores the buffer and answers DIFF_REJECTED.

local proposals = {} -- tab_name -> { bufnr, path, before, finish }

-- Save modified files so Claude (which reads from disk) sees what's on screen,
-- except files showing a proposal: that text isn't accepted yet
function M.save_all()
  local previewing = {}
  for _, p in pairs(proposals) do previewing[p.bufnr] = true end
  for _, b in ipairs(vim.api.nvim_list_bufs()) do
    if vim.api.nvim_buf_is_loaded(b) and vim.bo[b].modified and vim.bo[b].buftype == ""
      and vim.api.nvim_buf_get_name(b) ~= "" and not previewing[b] then
      vim.api.nvim_buf_call(b, function() vim.cmd("silent! write") end)
    end
  end
end

-- Most recent normal editing window (not the Claude terminal, not a float)
local function code_window()
  local prev = vim.fn.win_getid(vim.fn.winnr("#"))
  local function ok(w)
    return w ~= 0 and vim.api.nvim_win_is_valid(w) and vim.api.nvim_win_get_config(w).relative == ""
      and vim.bo[vim.api.nvim_win_get_buf(w)].buftype == ""
  end
  if ok(vim.api.nvim_get_current_win()) then return vim.api.nvim_get_current_win() end
  if ok(prev) then return prev end
  for _, w in ipairs(vim.api.nvim_tabpage_list_wins(0)) do
    if ok(w) then return w end
  end
end

local function to_lines(text)
  local lines = vim.split(text, "\n", { plain = true })
  if #lines > 0 and lines[#lines] == "" then table.remove(lines) end
  return lines
end

function M.propose(params, done)
  local path = vim.fs.normalize(params.old_file_path)
  local tab = params.tab_name
  if proposals[tab] then proposals[tab].finish(false) end -- replaced by a new one

  local from_win = vim.api.nvim_get_current_win()
  local win = code_window()
  if not win then
    vim.cmd("topleft vsplit")
    win = vim.api.nvim_get_current_win()
  end
  local is_new = vim.uv.fs_stat(path) == nil
  vim.api.nvim_win_call(win, function() vim.cmd.edit(vim.fn.fnameescape(path)) end)
  local bufnr = vim.api.nvim_win_get_buf(win)
  for t, p in pairs(proposals) do -- another pending proposal for this file
    if p.bufnr == bufnr then p.finish(false) ; proposals[t] = nil end
  end
  if reviews[bufnr] then reviews[bufnr].finish(true) end
  if vim.bo[bufnr].modified and not is_new then
    ignore[path] = vim.uv.now() + 1500
    vim.api.nvim_buf_call(bufnr, function() vim.cmd("silent write") end)
  end

  local before = is_new and {} or vim.api.nvim_buf_get_lines(bufnr, 0, -1, false)
  local after = to_lines(params.new_file_contents)
  vim.api.nvim_buf_set_lines(bufnr, 0, -1, false, after)

  local function redraw()
    local now = vim.api.nvim_buf_get_lines(bufnr, 0, -1, false)
    return draw(bufnr, before, now)
  end
  local first_row, top_ghosts = redraw()
  vim.api.nvim_set_current_win(win)
  if first_row then
    vim.api.nvim_win_set_cursor(win, { first_row + 1, 0 })
    vim.cmd("normal! zz")
    if top_ghosts and vim.fn.line("w0") == 1 then vim.fn.winrestview({ topline = 1, topfill = top_ghosts }) end
  end

  local group = vim.api.nvim_create_augroup("vimesimal_claude_proposal_" .. bufnr, { clear = true })
  local settled = false
  local function finish(apply)
    if settled then return end
    settled = true
    proposals[tab] = nil
    pcall(vim.api.nvim_del_augroup_by_id, group)
    local text
    if vim.api.nvim_buf_is_valid(bufnr) then
      vim.api.nvim_buf_clear_namespace(bufnr, diff_ns, 0, -1)
      pcall(vim.keymap.del, "n", "y", { buffer = bufnr })
      pcall(vim.keymap.del, "n", "n", { buffer = bufnr })
      if apply then
        -- Claude writes the file itself after FILE_SAVED (writing it here too
        -- applied the edit twice). Keep showing the new text; its write then
        -- reloads silently.
        local lines = vim.api.nvim_buf_get_lines(bufnr, 0, -1, false)
        text = table.concat(lines, "\n") .. (#lines > 0 and "\n" or "")
        ignore[path] = vim.uv.now() + 5000
        vim.bo[bufnr].modified = false
      elseif is_new then
        pcall(vim.api.nvim_buf_delete, bufnr, { force = true })
      else
        vim.api.nvim_buf_set_lines(bufnr, 0, -1, false, before)
        vim.bo[bufnr].modified = false
      end
    end
    bar.close()
    render_bar()
    if vim.api.nvim_win_is_valid(from_win) and from_win ~= win then vim.api.nvim_set_current_win(from_win) end
    if apply then
      done({ content = { { type = "text", text = "FILE_SAVED" }, { type = "text", text = text or params.new_file_contents } } })
    else
      done({ content = { { type = "text", text = "DIFF_REJECTED" }, { type = "text", text = tab } } })
    end
  end
  proposals[tab] = { bufnr = bufnr, path = path, before = before, finish = finish }

  vim.keymap.set("n", "y", function() finish(true) end, { buffer = bufnr, nowait = true, desc = "Apply Claude's edit" })
  vim.keymap.set("n", "n", function() finish(false) end, { buffer = bufnr, nowait = true, desc = "Reject Claude's edit" })
  -- You may adjust the proposal before applying it: keep the marks current
  vim.api.nvim_create_autocmd({ "TextChanged", "TextChangedI" }, { group = group, buffer = bufnr, callback = redraw })

  bar.show({ ("%s: Claude wants to make this change"):format(vim.fn.fnamemodify(path, ":.")) },
    "y apply · n reject", win)
end

-- Claude answered in its own terminal prompt (or moved on): drop our preview
local function drop_proposal(tab)
  local p = proposals[tab]
  if not p then return false end
  proposals[tab] = nil
  ignore[p.path] = vim.uv.now() + 3000 -- Claude may write the file itself now
  if vim.api.nvim_buf_is_valid(p.bufnr) then
    vim.api.nvim_buf_clear_namespace(p.bufnr, diff_ns, 0, -1)
    pcall(vim.keymap.del, "n", "y", { buffer = p.bufnr })
    pcall(vim.keymap.del, "n", "n", { buffer = p.bufnr })
    pcall(vim.api.nvim_del_augroup_by_name, "vimesimal_claude_proposal_" .. p.bufnr)
    vim.api.nvim_buf_set_lines(p.bufnr, 0, -1, false, p.before)
    vim.bo[p.bufnr].modified = false
    vim.defer_fn(function()
      if vim.api.nvim_buf_is_valid(p.bufnr) then vim.cmd.checktime(p.bufnr) end
    end, 800)
  end
  bar.close()
  render_bar()
  return true
end

function M.register_tools()
  -- The server requires "claudecode.tools.init" (not "claudecode.tools"), and
  -- Lua keeps those as two separate module tables: register in the one it uses
  local tools = require("claudecode.tools.init")
  local original = tools.tools.openDiff
  tools.register({
    name = "openDiff",
    schema = original and original.schema,
    requires_coroutine = true,
    handler = function(params)
      for _, k in ipairs({ "old_file_path", "new_file_path", "new_file_contents", "tab_name" }) do
        if not params[k] then
          error({ code = -32602, message = "Invalid params", data = "Missing required parameter: " .. k })
        end
      end
      local co = coroutine.running()
      vim.schedule(function()
        M.propose(params, function(result)
          local ok, res = coroutine.resume(co, result)
          local send = _G.claude_deferred_responses and _G.claude_deferred_responses[tostring(co)]
          if send then
            _G.claude_deferred_responses[tostring(co)] = nil
            send(ok and res or { error = { code = -32603, message = "Internal error", data = tostring(res) } })
          end
        end)
      end)
      return coroutine.yield()
    end,
  })

  local close = tools.tools.close_tab
  if close and not close.vimesimal then
    local orig_handler = close.handler
    close.handler = function(params, ...)
      if params and params.tab_name and drop_proposal(params.tab_name) then
        return { content = { { type = "text", text = "TAB_CLOSED" } } }
      end
      return orig_handler(params, ...)
    end
    close.vimesimal = true
  end
end

vim.api.nvim_create_autocmd("VimLeavePre", {
  group = vim.api.nvim_create_augroup("vimesimal_claude_proposals", { clear = true }),
  callback = function()
    for _, p in pairs(proposals) do pcall(p.finish, false) end
  end,
})

function M.quick()
  local ctx = context()
  -- A real file on disk that Claude may edit
  local bufnr = vim.api.nvim_get_current_buf()
  local path = vim.api.nvim_buf_get_name(bufnr)
  local editable = vim.bo[bufnr].buftype == "" and path ~= "" and vim.uv.fs_stat(path) ~= nil

  input("Claude edit", label(ctx), function(text)
    local prompt = text
    if ctx.lines then
      prompt = ("%s\n\nContext: %s lines %d-%d:\n```\n%s\n```"):format(
        text, ctx.file or "buffer", ctx.first, ctx.last, table.concat(ctx.lines, "\n"))
    elseif ctx.file then
      prompt = ("%s\n\n(I'm editing %s)"):format(text, ctx.file)
    end

    local s = M.load()
    local cmd = { "claude", "-p" }
    local before
    if editable then
      if vim.bo[bufnr].modified then
        vim.api.nvim_buf_call(bufnr, function() vim.cmd("silent write") end)
      end
      before = vim.fn.readfile(path)
      prompt = prompt .. ("\n\nIf this asks for a change, apply it directly to %s with the Edit tool "
        .. "(don't just describe it), then reply in one short sentence."):format(path)
      -- Only Read and Edit exist for this run, pre-approved so -p doesn't refuse
      vim.list_extend(cmd, { "--tools", "Read,Edit", "--allowedTools", "Read,Edit" })
      ignore[path] = math.huge -- this edit is reviewed below, not by the watcher
    end
    table.insert(cmd, 3, prompt)
    if s.model ~= "default" then vim.list_extend(cmd, { "--model", s.model }) end

    local win = vim.api.nvim_get_current_win()
    bar.show({ "Working on it…" }, nil, win)
    vim.system(cmd, { text = true }, vim.schedule_wrap(function(res)
      if editable then ignore[path] = vim.uv.now() + 1500 end
      local out = res.code == 0 and res.stdout or ("Error (exit " .. res.code .. "):\n" .. (res.stderr or ""))
      local reply = vim.split(vim.trim(out), "\n")
      local after = editable and vim.fn.readfile(path) or nil
      if not (after and not vim.deep_equal(before, after)) then
        render_bar() -- back to any other open reviews (or closed)
        return answer_window(reply)
      end
      -- Claude edited the file: reload it and review the change inline
      if vim.api.nvim_buf_is_valid(bufnr) then vim.cmd.checktime(bufnr) end
      start_review(bufnr, path, before, after, reply)
    end))
  end)
end

-- :ClaudeConfig ----------------------------------------------------------------

local choices = {
  { key = "model", name = "Model", values = { "default", "opus", "sonnet", "haiku" } },
  { key = "permission_mode", name = "Permission mode", values = { "manual", "acceptEdits", "auto", "plan" },
    describe = {
      manual = "manual: review every edit in Neovim first (y apply / n reject)",
      acceptEdits = "acceptEdits: Claude edits directly; you review afterwards (y keep / n undo)",
      auto = "auto: Claude decides; edits reviewed afterwards (y keep / n undo)",
      plan = "plan: Claude only plans, no edits",
    } },
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
    local fmt = function(v) return c.describe and c.describe[v] or show(v) end
    vim.ui.select(c.values, { prompt = c.name, format_item = fmt }, function(value)
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
