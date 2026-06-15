-- plugins.lua
return {
  -- Add Telescope plugin
  {
    "nvim-telescope/telescope.nvim",
    requires = { "nvim-lua/plenary.nvim" },
    opts = {
      defaults = {
        -- Default configuration for Telescope goes here
        vimgrep_arguments = {
          "rg",
          "--color=never",
          "--no-heading",
          "--with-filename",
          "--line-number",
          "--column",
          "--smart-case",
          "--hidden",
          "-g",
          "!.git",
        },

        layout_strategy = "horizontal",
        sorting_strategy = "ascending",
        layout_config = {
          height = 0.5,
          -- prompt_position = "top",
          -- vertical = {
          --   mirror = true,
          -- },
        },
        color_devicons = true,
        use_less = true,
        set_env = { ["COLORTERM"] = "truecolor" }, -- default = nil,
      },
      extensions = {
        -- Your extension configuration goes here
      },
    },
    config = function(_, opts)
      require("telescope").setup(opts)

      local map = vim.api.nvim_set_keymap
      local default_opts = { noremap = true }
      map("n", "<leader>\\", ":NvimTreeToggle<CR>", { noremap = true, silent = true })
      map("n", "<leader><bar>", ":NvimTreeFindFile<CR>", { noremap = true, silent = true })
      map(
        "n",
        "<leader>ff",
        "<cmd>lua require'telescope.builtin'.find_files({ find_command = {'rg', '--files', '--hidden', '-g', '!.git' }})<cr>",
        default_opts
      )
      map(
        "n",
        "<leader>fr",
        "<cmd>lua require'telescope.builtin'.buffers({ show_all_buffers = true })<cr>",
        default_opts
      )
      map("n", "<leader>fg", "<cmd>lua require'telescope.builtin'.git_status()<cr>", default_opts)
      map("n", "<leader>f?", ":TodoTelescope<cr>", default_opts)
      map("n", "<leader>/", ":silent grep ", default_opts)
      map("n", "<leader>_", "<cmd>lua require'telescope.builtin'.live_grep()<cr>", default_opts)
    end,
  },
}
