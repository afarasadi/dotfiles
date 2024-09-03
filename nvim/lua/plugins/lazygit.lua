return {
  -- Add LazyGit plugin
  {
    "kdheepak/lazygit.nvim",
    config = function()
      -- Optional: Additional configuration for LazyGit
      vim.api.nvim_set_keymap("n", "<leader>gg", ":LazyGit<CR>", { noremap = true, silent = true })

      -- Function to check if LazyGit is installed
      local function ensure_lazygit_installed()
        local handle = io.popen("lazygit --version")
        if handle == nil then
          return
        end
        local result = handle:read("*a")
        handle:close()

        if result == "" then
          print("Installing LazyGit...")
          vim.fn.system("brew install lazygit") -- or use the appropriate package manager
        else
          print("LazyGit is already installed.")
        end
      end

      -- Ensure LazyGit is installed
      ensure_lazygit_installed()
    end,
  },
}
