return {
  -- { "arzg/vim-colors-xcode" },
  -- { "rebelot/kanagawa.nvim" },
  -- {
  --   "LazyVim/LazyVim",
  --   opts = {
  --     colorscheme = "kanagawa-dragon",
  --   },
  -- },

  {
    "LazyVim/LazyVim",
    opts = {
      colorscheme = function()
        -- require("tokyonight").load()
        require("catppuccin").load()
      end,
    },
  },
  -- {
  --   "folke/tokyonight.nvim",
  --   lazy = false,
  --   priority = 1000,
  --   opts = {},
  -- },
  {
    "catppuccin/nvim",
    name = "catppuccin",
    priority = 1000,
    opts = {
      no_italic = true,
      term_colors = true,
      transparent_background = true,
      styles = {
        comments = {},
        conditionals = {},
        loops = {},
        functions = {},
        keywords = {},
        strings = {},
        variables = {},
        numbers = {},
        booleans = {},
        properties = {},
        types = {},
      },
      color_overrides = {
        mocha = {
          base = "#000000",
          mantle = "#000000",
          crust = "#000000",
        },
      },
      integrations = {
        telescope = {
          enabled = true,
          style = "nvchad",
        },
        dropbar = {
          enabled = true,
          color_mode = true,
        },
      },
    },
  },
}
