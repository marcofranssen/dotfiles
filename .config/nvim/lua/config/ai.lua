-- Auto-selects backend: iTerm2.
local function backend()
  return require("config.ai_iterm")
end

return {
  send_ref = function(opts) backend().send_ref(opts) end,
  send_snippet = function(opts) backend().send_snippet(opts) end,
}
