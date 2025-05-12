-- vscode/lazy.lua

-- Install lazy.nvim if not present
local lazypath = vim.fn.stdpath("data") .. "/lazy/lazy.nvim"
if not vim.loop.fs_stat(lazypath) then
    vim.fn.system({
        "git", "clone", "--filter=blob:none",
        "https://github.com/folke/lazy.nvim.git",
        "--branch=stable", -- latest stable release
        lazypath,
    })
end
vim.opt.rtp:prepend(lazypath)

-- Safe, non-UI plugins only
require("lazy").setup({
    -- Surround: like ci" or ds)
    { "echasnovski/mini.surround", version = "*", config = true },

    -- Text objects: ai, a[, i), etc.
    { "echasnovski/mini.ai",       version = "*" },

    -- Pairs: auto-closing brackets/quotes
    { "echasnovski/mini.pairs",    version = "*", config = true },

    -- Move lines/blocks easily
    { "echasnovski/mini.move",     version = "*" },

    -- Commenting with gcc, gc
    { "numToStr/Comment.nvim",     config = true },

    -- Additional repeat support (dot `.`)
    { "tpope/vim-repeat" },

    -- Visual multiple cursors
    { "mg979/vim-visual-multi" },

    -- Extra motions like [b, ]q
    { "tpope/vim-unimpaired" },

    -- Text alignment
    { "junegunn/vim-easy-align" },

    -- Targets: a", i', a|, etc.
    { "wellle/targets.vim" },
})
