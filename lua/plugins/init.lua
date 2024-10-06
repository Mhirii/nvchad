return {

  {
    "stevearc/conform.nvim",
    event = "BufWritePre", -- uncomment for format on save
    opts = require "configs.conform",
  },

  {
    "neovim/nvim-lspconfig",
    config = function()
      require "configs.lspconfig"
    end,
  },
  {
    "nvim-tree/nvim-tree.lua",
    cmd = { "NvimTreeToggle", "NvimTreeFocus" },
    opts = function()
      return require "configs.nvimtree"
    end,
  },

  { import = "configs.editor.persistence" },
  { import = "configs.editor.todo" },
  { import = "configs.editor.trouble" },
  { import = "configs.editor.workspaces" },

  { import = "configs.ui.copilot_chat" },

  { import = "configs.lang.ts" },
  { import = "configs.lang.go" },

  { import = "configs.utils.mini" },
  { import = "configs.utils.split" },
  { import = "configs.utils.tardis" },
  { import = "configs.utils.toggler" },

  -- {
  -- "nvim-treesitter/nvim-treesitter",
  -- 	opts = {
  -- 		ensure_installed = {
  -- 			"vim", "lua", "vimdoc",
  --      "html", "css"
  -- 		},
  -- 	},
  -- },
}
