return {
  {
    "nvim-neo-tree/neo-tree.nvim",
    version = "*",
    -- init = function()
    --   -- Disable NeoTree's automatic behavior here (noop)
    -- end,
    config = function()
      require("neo-tree").setup({
        window = {
          position = "float", -- Make NeoTree open in a floating window
          width = 40, -- Set the width of the floating window
          height = 30, -- Set the height of the floating window
          auto_resize = true, -- Auto resize to fit the content
        },
        filesystem = {
          filtered_items = {
            visible = true, -- Show hidden files (can be set to false if you want to hide dotfiles)
          },
        },
        -- Disable opening NeoTree automatically on startup
        auto_open = false,

        -- Custom Key Mappings to replace defaults
        mapping = {
          -- Leader + e to toggle reveal (open) file in NeoTree
          ["<leader>e"] = function()
            require("neo-tree.command").execute({ action = "focus", reveal = true })
          end,

          -- Leader + E to toggle non-revealed file in NeoTree
          ["<leader>E"] = function()
            require("neo-tree.command").execute({ action = "focus", reveal = false })
          end,
        },
      })

      -- Optionally, map a key to toggle NeoTree visibility
      vim.api.nvim_set_keymap("n", "<leader>n", ":Neotree toggle<CR>", { noremap = true, silent = true })
    end,
  },
}
