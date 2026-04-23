return {
  {
    "nvim-neo-tree/neo-tree.nvim",
    branch = "v3.x",
    dependencies = {
      "nvim-lua/plenary.nvim",
      "MunifTanjim/nui.nvim",
      "nvim-tree/nvim-web-devicons", -- optional, but recommended
    },
    lazy = false, -- neo-tree will lazily load itself
    keys = {
      { "<leader>e", "<cmd>Neotree reveal<cr>", desc = "Toggle [E]xplorer" },
    },
    opts = {
      filesystem = {
	filtered_items = {
	  hide_dotfiles = false,
	  hide_gitignored = true,
	  hide_by_name = {
	    "node_modules",
	    ".DS_Store",
	  },
	},
      },
      reveal = true,
    },
  }
}
