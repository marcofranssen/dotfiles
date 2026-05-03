local M = {}

local function notify_err(msg)
  vim.notify(msg, vim.log.levels.ERROR, { title = "ai_iterm" })
end

local function relative_path(abs)
  local dir = vim.fn.fnamemodify(abs, ":h")
  local out = vim.fn.systemlist({ "git", "-C", dir, "rev-parse", "--show-toplevel" })
  local git_root
  if vim.v.shell_error == 0 and out[1] and out[1] ~= "" then
    git_root = vim.fs.normalize(out[1])
  end

  local cwd = vim.fs.normalize(vim.fn.getcwd())
  local path = vim.fs.normalize(abs)

  -- In a workspace (cwd is above the sub-repo git root), use cwd as the base
  -- so the repo folder name is preserved in the reference.
  local base
  if git_root and cwd ~= git_root and cwd:len() < git_root:len()
    and git_root:sub(1, #cwd + 1) == cwd .. "/" then
    base = cwd
  elseif git_root then
    base = git_root
  else
    base = cwd
  end

  if path:sub(1, #base + 1) == base .. "/" then
    return path:sub(#base + 2)
  end
  return vim.fn.fnamemodify(abs, ":.")
end

local _cache = nil
local AI_NAMES = { "claude", "opencode", "codex" }

-- Return all ttys in the current tab of the frontmost iTerm2 window.
-- This avoids needing to know nvim's own tty (which is unreliable since
-- nvim puts the terminal in raw mode and ps / $TTY are often unset).
local function current_tab_ttys()
  local script = [[
tell application "iTerm2"
  set w to current window
  set t to current tab of w
  set ttys to {}
  repeat with s in sessions of t
    set end of ttys to tty of s
  end repeat
  set AppleScript's text item delimiters to linefeed
  return ttys as text
end tell]]
  local out = vim.fn.system({ "osascript", "-e", script })
  if vim.v.shell_error ~= 0 then return {} end
  local result = {}
  for line in vim.trim(out):gmatch("[^\n]+") do
    table.insert(result, line)
  end
  return result
end

local function find_claude_tty()
  if _cache then
    vim.fn.system({ "kill", "-0", tostring(_cache.pid) })
    if vim.v.shell_error == 0 then
      return _cache.tty
    end
    _cache = nil
  end

  local ttys = current_tab_ttys()
  for _, tty in ipairs(ttys) do
    local short = tty:gsub("^/dev/", "")
    local procs = vim.fn.systemlist({ "ps", "-wwt", short, "-o", "pid=,args=" })
    if vim.v.shell_error == 0 then
      for _, line in ipairs(procs) do
        local pid, args = line:match("^%s*(%d+)%s+(.*)$")
        if pid and args then
          local lower = args:lower()
          for _, name in ipairs(AI_NAMES) do
            if lower == name
              or lower:match("^" .. name .. "%s")
              or lower:match("^" .. name .. "$")
              or lower:match("[/%s]" .. name .. "$")
              or lower:match("[/%s]" .. name .. "%s")
              or lower:match("/" .. name .. "/")
            then
              _cache = { pid = tonumber(pid), tty = tty }
              return tty
            end
          end
        end
      end
    end
  end

  return nil
end

-- Send text to a specific iTerm2 session identified by tty.
-- Uses pbcopy + `do shell script "pbpaste"` because `the clipboard` is not
-- reliably accessible inside a `tell application "iTerm2"` block.
local function iterm_send(tty, text)
  vim.fn.system("pbcopy", text)
  if vim.v.shell_error ~= 0 then
    return false
  end

  local script = string.format(
    [[
tell application "iTerm2"
  repeat with w in windows
    repeat with t in tabs of w
      repeat with s in sessions of t
        if tty of s = %q then
          tell s
            write text (do shell script "pbpaste") newline NO
          end tell
          return "ok"
        end if
      end repeat
    end repeat
  end repeat
  return "not_found"
end tell]],
    tty
  )

  local out = vim.fn.system({ "osascript", "-e", script })
  return vim.v.shell_error == 0 and vim.trim(out) == "ok"
end

function M.send_ref(opts)
  opts = opts or {}
  local abs = vim.api.nvim_buf_get_name(0)
  if abs == "" then
    notify_err("Buffer has no file name")
    return
  end

  local lstart, lend
  if opts.visual then
    lstart = vim.fn.getpos("'<")[2]
    lend = vim.fn.getpos("'>")[2]
  else
    lstart = vim.fn.line(".")
    lend = lstart
  end
  if lstart > lend then
    lstart, lend = lend, lstart
  end

  local rel = relative_path(abs)
  local token
  if lstart == lend then
    token = string.format("@%s#L%d ", rel, lstart)
  else
    token = string.format("@%s#L%d-L%d ", rel, lstart, lend)
  end

  local tty = find_claude_tty()
  if not tty then
    notify_err("No iTerm2 session running claude/opencode/codex")
    return
  end

  if not iterm_send(tty, token) then
    notify_err("iTerm2 write text failed")
    return
  end
  vim.notify("Sent " .. token:gsub("%s+$", "") .. " → iTerm2", vim.log.levels.INFO, { title = "ai_iterm" })
end

local function detect_lang(abs)
  local ft = vim.filetype.match({ filename = abs }) or vim.bo.filetype
  return ft or ""
end

function M.send_snippet(opts)
  opts = opts or {}
  local abs = vim.api.nvim_buf_get_name(0)
  if abs == "" then
    notify_err("Buffer has no file name")
    return
  end

  local lstart, lend
  if opts.visual then
    lstart = vim.fn.getpos("'<")[2]
    lend = vim.fn.getpos("'>")[2]
  else
    lstart = vim.fn.line(".")
    lend = lstart
  end
  if lstart > lend then
    lstart, lend = lend, lstart
  end

  local lines = vim.api.nvim_buf_get_lines(0, lstart - 1, lend, false)
  local rel = relative_path(abs)
  local header
  if lstart == lend then
    header = string.format("%s:L%d", rel, lstart)
  else
    header = string.format("%s:L%d-L%d", rel, lstart, lend)
  end

  local lang = detect_lang(abs)
  local body = table.concat(lines, "\n")
  local snippet = string.format("`%s`\n```%s\n%s\n```\n", header, lang, body)

  local tty = find_claude_tty()
  if not tty then
    notify_err("No iTerm2 session running claude/opencode/codex")
    return
  end

  if not iterm_send(tty, snippet) then
    notify_err("iTerm2 write text failed")
    return
  end
  vim.notify("Sent snippet " .. header .. " → iTerm2", vim.log.levels.INFO, { title = "ai_iterm" })
end

M.find_tty = find_claude_tty
M.current_tab_ttys = current_tab_ttys
M.invalidate_cache = function() _cache = nil end

function M.debug()
  local ttys = current_tab_ttys()
  local lines = { "current tab ttys: " .. #ttys }
  for _, tty in ipairs(ttys) do
    local short = tty:gsub("^/dev/", "")
    local procs = vim.fn.systemlist({ "ps", "-wwt", short, "-o", "pid=,args=" })
    table.insert(lines, "  tty=" .. tty .. " procs=" .. #procs)
    for _, p in ipairs(procs) do
      table.insert(lines, "    " .. p)
    end
  end
  vim.notify(table.concat(lines, "\n"), vim.log.levels.INFO, { title = "ai_iterm debug" })
end

return M
