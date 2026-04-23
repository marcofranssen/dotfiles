-- Mason registry package names
local mason_packages = {
  -- Language servers
  "bash-language-server",
  "buf",
  "css-lsp",
  "dockerfile-language-server",
  "gopls",
  "graphql-language-service-cli",
  "html-lsp",
  "json-lsp",
  "lua-language-server",
  "postgres-language-server",
  "rust-analyzer",
  "tailwindcss-language-server",
  "tofu-ls",
  "vtsls",
  "yaml-language-server",
  -- LSP-based linters
  "eslint-lsp",
  "golangci-lint-langserver",
  -- Formatters
  "goimports",
  "markdownlint",
  "prettierd",
  "stylua",
}

-- lspconfig server names to activate
local lsp_servers = {
  "bashls",
  "cssls",
  "dockerls",
  "eslint",
  "golangci_lint_ls",
  "gopls",
  "html",
  "jsonls",
  "lua_ls",
  "rust_analyzer",
  "tailwindcss",
  "tofu_ls",
  "yamlls",
}

return {
  {
    "folke/lazydev.nvim",
    ft = "lua",
    opts = {
      library = {
        { path = "${3rd}/luv/library", words = { "vim%.uv" } },
      },
    },
  },
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
