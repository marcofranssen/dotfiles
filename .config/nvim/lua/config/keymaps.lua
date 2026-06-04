local function map(mode, key, cmd, opts)
  opts = opts or {}
  vim.keymap.set(mode, key, cmd, opts)
end

-- Change delete, change, and paste to not yank text
map("x", "p", '"_dP', { noremap = true, silent = true })
map({ "n", "x" }, "d", '"_d', { noremap = true, silent = true })
map({ "n", "x" }, "c", '"_c', { noremap = true, silent = true })
