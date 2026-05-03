-- Set default project lsp config that can be overriden in .nvim/before.lua
_G.project_lsp_config = {}

-- Load project before config (needs to happen before other config)
local project_config = vim.fn.getcwd() .. "/.nvim/before.lua"
if vim.fn.filereadable(project_config) == 1 then
  dofile(project_config)
end

require("config.lazy")
require("config.options")
require("config.keymaps")
require("config.autocmd")
require("config.diagnostics")

-- Load project after config (needs to happen after other config)
project_config = vim.fn.getcwd() .. "/.nvim/after.lua"
if vim.fn.filereadable(project_config) == 1 then
  dofile(project_config)
end
