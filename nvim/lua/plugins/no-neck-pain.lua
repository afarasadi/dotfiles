return {}

-- return {
--   {
--     "shortcuts/no-neck-pain.nvim",
--     version = "*", -- Ensures you get the latest version
--     config = function()
--       local config = require("config.config")
--       require("no-neck-pain").setup({
--         width = 120,
--         -- buffers = {
--         --   left = {
--         --     enabled = true, -- Left buffer remains enabled
--         --     bo = {
--         --       filetype = "md",
--         --     },
--         --   },
--         --   right = {
--         --     enabled = true, -- Left buffer remains enabled
--         --     bo = {
--         --       filetype = "md",
--         --     },
--         --   },
--         -- },
--
--         buffers = {
--           scratchPad = {
--             -- fileName = "scratchPad",
--             enabled = false,
--           },
--           -- left = {
--           --   scratchPad = {
--           --     -- pathToFile = right_file_path,
--           --     -- pathToFile = "~/.config/nvim/lua/plugins/no-neck-pain/scratch-pad-left.md",
--           --
--           --     fileName = "scratchPad",
--           --   },
--           -- },
--           -- right = {
--           --   scratchPad = {
--           --     -- pathToFile = "~/.config/nvim/lua/plugins/no-neck-pain/scratch-pad-right.md",
--           --     -- fileName = "scratchPad",
--           --     --
--           --     pathToFile = config.vimwiki_today,
--           --   },
--           -- },
--           bo = {
--             filetype = "md",
--           },
--         },
--         autocmds = {
--           enableOnVimEnter = true,
--           enableOnTabEnter = true,
--           reloadOnColorSchemeChange = true,
--           skipEnteringNoNeckPainBuffer = true,
--         },
--         mappings = {
--           enabled = true,
--         },
--         integrations = {
--           NeoTree = {
--             position = "float", -- Set position to 'right'
--             -- reopen = true, -- Reopen NeoTree if it was open before enabling NoNeckPain
--           },
--         },
--       })
--     end,
--   },
-- }
