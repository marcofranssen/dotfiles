-- Detect helm templates: yaml files inside a templates/ dir with a Chart.yaml ancestor
vim.api.nvim_create_autocmd({ "BufRead", "BufNewFile" }, {
  pattern = "*/templates/*.yaml",
  group = vim.api.nvim_create_augroup("helm-filetype", { clear = true }),
  callback = function(event)
    local dir = vim.fn.fnamemodify(event.file, ":h")
    while dir ~= "/" do
      dir = vim.fn.fnamemodify(dir, ":h")
      if vim.fn.filereadable(dir .. "/Chart.yaml") == 1 then
        vim.bo[event.buf].filetype = "helm"
        return
      end
    end
  end,
})

-- Highlight when yanking (copying) text
--  Try it with `yap` in normal mode
--  See `:help vim.hl.on_yank()`
vim.api.nvim_create_autocmd("TextYankPost", {
  desc = "Highlight when yanking (copying) text",
  group = vim.api.nvim_create_augroup("highlight-yank", { clear = true }),
  callback = function()
    vim.hl.on_yank()
  end,
})
