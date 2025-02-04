-- Autocmds are automatically loaded on the VeryLazy event
-- Default autocmds that are always set: https://github.com/LazyVim/LazyVim/blob/main/lua/lazyvim/config/autocmds.lua
-- Add any additional autocmds here

-- vim.api.nvim_create_autocmd("BufWritePre", {
--   pattern = "*.go",
--   callback = function()
--     local params = vim.lsp.util.make_range_params()
--     params.context = { only = { "source.organizeImports" } }
--     -- buf_request_sync defaults to a 1000ms timeout. Depending on your
--     -- machine and codebase, you may want longer. Add an additional
--     -- argument after params if you find that you have to write the file
--     -- twice for changes to be saved.
--     -- E.g., vim.lsp.buf_request_sync(0, "textDocument/codeAction", params, 3000)
--     local result = vim.lsp.buf_request_sync(0, "textDocument/codeAction", params)
--     for cid, res in pairs(result or {}) do
--       for _, r in pairs(res.result or {}) do
--         if r.edit then
--           local enc = (vim.lsp.get_client_by_id(cid) or {}).offset_encoding or "utf-16"
--           vim.lsp.util.apply_workspace_edit(r.edit, enc)
--         end
--       end
--     end
--     vim.lsp.buf.format({ async = false })
--   end,
-- })

vim.api.nvim_create_augroup("FormatOnSave", { clear = true })
vim.api.nvim_create_autocmd("BufWritePost", {
  group = "FormatOnSave",
  pattern = "*",
  callback = function()
    vim.cmd("silent! FormatWrite")
  end,
})
vim.api.nvim_create_autocmd({ "VimResized" }, {
  desc = "Resize Neo-tree if Neovim window is resized",
  group = vim.api.nvim_create_augroup("NeoTreeResize", { clear = true }),
  callback = function()
    local percentage = 30 -- Set the desired percentage
    local ratio = percentage / 100
    local width = math.floor(vim.o.columns * ratio)

    -- Adjust Neo-tree width
    require("neo-tree.sources.manager").set_width("filesystem", width)
  end,
})

-- -- recover from swap file for wiki files
-- -- currently for vimwiki
-- vim.api.nvim_create_autocmd("BufReadPre", {
--   pattern = "*.wiki", -- You can adjust this pattern to match the file types you want
--   callback = function()
--     local swap_file = vim.fn.expand("%:p") .. ".swp"
--     if vim.fn.filereadable(swap_file) == 1 then
--       vim.cmd("recover") -- Run :recover if a swap file exists
--     end
--   end,
-- })
--
-- -- Dynamically generate the right scratchpad path based on the current date
--
-- local config = require("config.config")
-- local right_scratchpad_path = config.vimwiki_today
-- -- Disable swap files for the right scratchpad file
-- vim.cmd(string.format(
--   [[
-- augroup NoSwapFilesRight
--   autocmd!
--   autocmd BufRead,BufNewFile %s setlocal noswapfile
-- augroup END
-- ]],
--   vim.fn.expand(right_scratchpad_path)
-- ))
--
-- -- Automatically recover from swap file conflicts for the right scratchpad file
-- vim.cmd(
--   [[
-- augroup AutoRecoverRight
--   autocmd!
--   autocmd BufReadPre %s if !empty(glob(v:progpath . ".swp")) | recover | endif
-- augroup END
-- ]],
--   vim.fn.expand(right_scratchpad_path)
-- )
