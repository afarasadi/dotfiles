-- Options are automatically loaded before lazy.nvim startup
-- Default options that are always set: https://github.com/LazyVim/LazyVim/blob/main/lua/lazyvim/config/options.lua
-- Add any additional options here

-- Show buffer file info
vim.opt.winbar = "%=%m %f"

-- https://www.reddit.com/r/neovim/comments/1ajpdrx/lazyvim_weird_live_grep_root_dir_functionality_in/
-- always use cwd as root_dir
vim.g.root_spec = { "cwd" }
vim.opt.colorcolumn = "72"
vim.cmd([[highlight ColorColumn ctermbg=lightgrey guibg=lightgrey]])
