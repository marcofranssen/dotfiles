-- Mason registry package names
local mason_packages = {
  -- Language servers
  "gopls",
  "lua-language-server",
  -- LSP-based linters
  "golangci-lint-langserver",
  -- Formatters
  "goimports",
  "stylua",
}

-- lspconfig server names to activate
local lsp_servers = {
  "golangci_lint_ls",
  "gopls",
  "lua_ls",
}

return {
  {
    "whoissethdaniel/mason-tool-installer.nvim",
    dependencies = {
      "mason-org/mason.nvim",
      opts = {
        registries = {
          "github:mason-org/mason-registry",
        },
      },
    },
    opts = {
      ensure_installed = mason_packages,
    },
  },
  {
    "neovim/nvim-lspconfig",
    dependencies = {
      { "j-hui/fidget.nvim", event = "LspAttach", opts = {} },
      "saghen/blink.cmp",
    },
    config = function()
      local capabilities = require("blink.cmp").get_lsp_capabilities()
      for _, server in ipairs(lsp_servers) do
        vim.lsp.config(server, { capabilities = capabilities })
      end
      vim.lsp.enable(lsp_servers)
    end,
  },
}
