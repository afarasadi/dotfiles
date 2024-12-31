-- plugins.lua
return {
  -- Add Telescope plugin
  {
    "nvim-telescope/telescope.nvim",
    requires = { "nvim-lua/plenary.nvim" },
    config = function()
      -- Function to check if a command exists
      local function command_exists(cmd)
        local handle = io.popen("command -v " .. cmd)
        local result = handle:read("*a")
        handle:close()
        return result ~= ""
      end

      -- Install ripgrep if not installed
      if not command_exists("rg") then
        print("Installing ripgrep...")
        if vim.fn.has("mac") == 1 then
          vim.fn.system("brew install ripgrep")
        elseif vim.fn.has("unix") == 1 then
          vim.fn.system("sudo apt-get install ripgrep")
        elseif vim.fn.has("win32") == 1 then
          vim.fn.system("choco install ripgrep")
        end
      else
        -- print("ripgrep is already installed.")
      end

      -- Install fd if not installed
      if not command_exists("fd") then
        print("Installing fd...")
        if vim.fn.has("mac") == 1 then
          vim.fn.system("brew install fd")
        elseif vim.fn.has("unix") == 1 then
          vim.fn.system("sudo apt-get install fd-find")
        elseif vim.fn.has("win32") == 1 then
          vim.fn.system("choco install fd")
        end
      else
        -- print("fd is already installed.")
      end

      require("telescope").setup({
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
          },
          prompt_prefix = "> ",
          selection_caret = "> ",
          entry_prefix = "  ",
          initial_mode = "insert",
          selection_strategy = "reset",
          sorting_strategy = "descending",
          layout_strategy = "horizontal",
          layout_config = {
            horizontal = {
              mirror = false,
            },
            vertical = {
              mirror = false,
            },
          },
          file_sorter = require("telescope.sorters").get_fuzzy_file,
          file_ignore_patterns = {},
          generic_sorter = require("telescope.sorters").get_generic_fuzzy_sorter,
          path_display = { "truncate" },
          winblend = 0,
          border = {},
          borderchars = { "─", "│", "─", "│", "┌", "┐", "┘", "└" },
          color_devicons = true,
          use_less = true,
          set_env = { ["COLORTERM"] = "truecolor" }, -- default = nil,
          file_previewer = require("telescope.previewers").vim_buffer_cat.new,
          grep_previewer = require("telescope.previewers").vim_buffer_vimgrep.new,
          qflist_previewer = require("telescope.previewers").vim_buffer_qflist.new,
          -- Developer configurations: Not meant for general override
          buffer_previewer_maker = require("telescope.previewers").buffer_previewer_maker,
        },
        pickers = {
          -- Default configuration for builtin pickers goes here
          find_files = {
            find_command = { "rg", "--files", "--hidden", "-g", "!.git" },
            layout_config = {
              -- height = 0.70,
            },
          },
          buffers = {
            show_all_buffers = true,
          },
          -- live_grep = {
          --   previewer = false,
          --   theme = "dropdown",
          -- },
          git_status = {
            git_icons = {
              added = " ",
              changed = " ",
              copied = " ",
              deleted = " ",
              renamed = "➡",
              unmerged = " ",
              untracked = " ",
            },
            previewer = false,
            theme = "dropdown",
          },
        },
        extensions = {
          -- Your extension configuration goes here
        },
      })

      -- Optionally, you can set a key mapping to open Telescope
      -- vim.api.nvim_set_keymap(
      --   "n",
      --   "<leader>ff",
      --   [[:lua require('telescope.builtin').find_files()<CR>]],
      --   { noremap = true, silent = true }
      -- )
      -- vim.api.nvim_set_keymap(
      --   "n",
      --   "<leader>fg",
      --   [[:lua require('telescope.builtin').live_grep()<CR>]],
      --   { noremap = true, silent = true }
      -- )
    end,
  },
}
