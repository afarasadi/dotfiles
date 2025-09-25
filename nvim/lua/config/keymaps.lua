-- Keymaps are automatically loaded on the VeryLazy event
-- Default keymaps that are always set: https://github.com/LazyVim/LazyVim/blob/main/lua/lazyvim/config/keymaps.lua
-- Add any additional keymaps here

-- harpoon keymaps
-- local mark = require("harpoon.mark")
-- local ui = require("harpoon.ui")
-- vim.keymap.set("n", "<leader>a", mark.add_file)
-- vim.keymap.set("n", "<leader>h", ui.toggle_quick_menu)
-- vim.keymap.set("n", "<C-q>", function()
--   ui.nav_file(1)
-- end)
-- vim.keymap.set("n", "<C-e>", function()
--   ui.nav_file(2)
-- end)
-- vim.keymap.set("n", "<C-t>", function()
--   ui.nav_file(3)
-- end)
-- vim.keymap.set("n", "<C-y>", function()
--   ui.nav_file(4)
-- end)

local neotreeCmd = require("neo-tree.command")
-- Set the custom key mappings using vim.keymap.set
vim.keymap.set("n", "<leader>e", function()
  neotreeCmd.execute({ action = "focus", reveal = true })
end, { desc = "Reveal file in NeoTree" })

vim.keymap.set("n", "<leader>E", function()
  neotreeCmd.execute({ action = "focus", reveal = false })
end, { desc = "Focus non-revealed file in NeoTree" })

-- [vim] tmux-sessionizer
vim.keymap.set("n", "<C-f>", "<cmd>silent !tmux neww tmux-sessionizer<CR>")
