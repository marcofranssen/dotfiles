return {
  settings = {
    Lua = {
      format = {
        enable = false, -- let conform handle the formatting
      },
      completion = {
        callSnippet = "Replace",
      },
      runtime = {
        version = "LuaJIT",
      },
      -- Make the server aware of Neovim runtime files
      workspace = {
        checkThirdParty = false,
        library = {
          vim.env.VIMRUNTIME,
          "${3rd}/luv/library",
        },
        diagnostics = {
          globals = {
            "Snacks",
          },
          disable = {
            "missing-fields",
          },
        },
      },
    },
  },
}
