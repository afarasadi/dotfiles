return {
  {
    "shortcuts/no-neck-pain.nvim",
    version = "*", -- Ensures you get the latest version
    config = function()
      require("no-neck-pain").setup({
        width = 120,
        -- buffers = {
        --   left = {
        --     enabled = true, -- Left buffer remains enabled
        --     bo = {
        --       filetype = "md",
        --     },
        --   },
        --   right = {
        --     enabled = true, -- Left buffer remains enabled
        --     bo = {
        --       filetype = "md",
        --     },
        --   },
        -- },
        buffers = {
          scratchPad = {
            enabled = true,
            location = "~/Documents/",
          },
          bo = {
            filetype = "md",
          },
        },
        autocmds = {
          enableOnVimEnter = true,
          enableOnTabEnter = true,
          reloadOnColorSchemeChange = true,
          skipEnteringNoNeckPainBuffer = true,
        },
        mappings = {
          enabled = true,
        },
        integrations = {
          NeoTree = {
            position = "float", -- Set position to 'right'
            -- reopen = true, -- Reopen NeoTree if it was open before enabling NoNeckPain
          },
        },
      })
    end,
  },
}
