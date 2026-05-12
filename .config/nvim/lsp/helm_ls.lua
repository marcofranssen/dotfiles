return {
  settings = {
    ["helm-ls"] = {
      yamlls = {
        enabled = true,
        path = "yaml-language-server",
        config = {
          schemas = {
            kubernetes = "templates/**",
          },
          completion = true,
          hover = true,
        },
      },
    },
  },
}
