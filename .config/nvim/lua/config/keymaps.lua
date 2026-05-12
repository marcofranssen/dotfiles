local function map(mode, key, cmd, opts)
  opts = opts or {}
  vim.keymap.set(mode, key, cmd, opts)
end

