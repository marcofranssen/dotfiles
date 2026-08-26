local function map(mode, key, cmd, opts)
  opts = opts or {}
  vim.keymap.set(mode, key, cmd, opts)
end

-- Change delete, change, and paste to not yank text
map("x", "p", '"_dP', { noremap = true, silent = true })
map({ "n", "x" }, "d", '"_d', { noremap = true, silent = true })
map({ "n", "x" }, "c", '"_c', { noremap = true, silent = true })

-- Clear highlights on search when pressing <Esc> in normal mode
--  See `:help hlsearch`
map("n", "<Esc>", "<cmd>nohlsearch<CR>")

-- NOTE: Some terminals have colliding keymaps or are not able to send distinct keycodes
-- map("n", "<C-S-h>", "<C-w>H", { desc = "Move window to the left" })
-- map("n", "<C-S-l>", "<C-w>L", { desc = "Move window to the right" })
-- map("n", "<C-S-j>", "<C-w>J", { desc = "Move window to the lower" })
-- map("n", "<C-S-k>", "<C-w>K", { desc = "Move window to the upper" })
