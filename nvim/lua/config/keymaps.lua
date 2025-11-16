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

-- [vim] tmux-sessionizer
vim.keymap.set("n", "<C-f>", "<cmd>silent !tmux neww tmux-sessionizer<CR>")
