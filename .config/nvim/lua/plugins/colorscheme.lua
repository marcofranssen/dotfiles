return {
  {
    "zaldih/themery.nvim",
    cmd = "Themery",
    opts = {
      themes = {
        { name = "Catppuccin Mocha", colorscheme = "catppuccin-mocha" },
        { name = "Kanagawa", colorscheme = "kanagawa" },
        { name = "Tokyo Night", colorscheme = "tokyonight-night" },
        { name = "Sonokai Atlantis", colorscheme = "sonokai" },
      },
      livePreview = true,
      globalAfter = "",
    },
  },
  {
    "catppuccin/nvim",
    name = "catppuccin",
    lazy = false,
    priority = 1000,
    config = function()
      vim.cmd([[colorscheme catppuccin-mocha]])
    end,
    specs = {
      {
        "akinsho/bufferline.nvim",
        optional = true,
        opts = function(_, opts)
          if (vim.g.colors_name or ""):find("catppuccin") then
            opts.highlights = require("catppuccin.special.bufferline").get_theme()
          end
        end,
      },
    },
  },
  {
    "rebelot/kanagawa.nvim",
    name = "kanagawa",
    lazy = true,
    priority = 1000,
    config = function()
      vim.cmd([[colorscheme kanagawa]])
    end,
  },
  {
    "folke/tokyonight.nvim",
    name = "tokyonight",
    lazy = true,
    priority = 1000,
    config = function()
      require("tokyonight").setup({
        on_colors = function(colors)
          colors.bg = "#14191e"
        end,
      })
      vim.cmd([[colorscheme tokyonight-night]])
    end,
  },
  {
    "sainnhe/sonokai",
    lazy = true,
    priority = 1000,
    config = function()
      -- Optionally configure and load the colorscheme
      -- directly inside the plugin declaration.
      vim.g.sonokai_enable_italic = false
      vim.g.sonokai_style = "atlantis"
      vim.cmd.colorscheme("sonokai")
    end,
  },
}
