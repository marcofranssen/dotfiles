local function map(mode, key, cmd, opts)
  opts = opts or {}
  vim.keymap.set(mode, key, cmd, opts)
end

-- Send @file#Lx-Ly reference / snippet to the AI session.
-- Auto-selects tmux backend when inside tmux, iTerm2 otherwise.
map("n", "<leader>ac", function()
  require("config.ai").send_ref({ visual = false })
end, { desc = "[A]I: send [c]laude file reference" })
map("x", "<leader>ac", function()
  vim.cmd('normal! \27')
  require("config.ai").send_ref({ visual = true })
end, { desc = "[A]I: send [c]laude file reference" })
map("n", "<leader>ay", function()
  require("config.ai").send_snippet({ visual = false })
end, { desc = "[A]I: [y]ank snippet to AI pane" })
map("x", "<leader>ay", function()
  vim.cmd('normal! \27')
  require("config.ai").send_snippet({ visual = true })
end, { desc = "[A]I: [y]ank snippet to AI pane" })
