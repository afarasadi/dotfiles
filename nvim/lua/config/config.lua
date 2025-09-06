-- /lua/configs/config.lua
local M = {}

-- Define the right scratchpad path dynamically based on the current date
M.vimwiki_today = "~/vimwiki/diary/" .. os.date("%Y-%m-%d") .. ".wiki"

vim.filetype.add({
  extension = {
    mdc = "markdown",
  },
})

return M
