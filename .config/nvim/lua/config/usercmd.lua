vim.api.nvim_create_user_command("LspInfo", function()
  local clients = vim.lsp.get_clients({ bufnr = 0 })
  if #clients == 0 then
    vim.notify("No LSP clients attached to this buffer", vim.log.levels.WARN)
    return
  end
  local lines = {}
  for _, client in ipairs(clients) do
    table.insert(lines, string.format("- %s (id=%d)", client.name, client.id))
  end
  vim.notify("LSP clients:\n" .. table.concat(lines, "\n"), vim.log.levels.INFO)
end, { desc = "Show LSP clients attached to current buffer" })

vim.api.nvim_create_user_command("ReloadConfig", function()
  for name, _ in pairs(package.loaded) do
    if name:match("^config%.") or name:match("^plugins%.") then
      package.loaded[name] = nil
    end
  end
  dofile(vim.fn.stdpath("config") .. "/init.lua")
  vim.notify("Config reloaded", vim.log.levels.INFO)
end, { desc = "Reload the Neovim configuration" })
