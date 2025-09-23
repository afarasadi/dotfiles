return {
  {
    "mistweaverco/kulala.nvim",
    keys = {
      { "<leader>nk", desc = "Send request" },
      { "<leader>na", desc = "Send all requests" },
      { "<leader>nb", desc = "Open scratchpad" },
    },
    ft = { "http", "rest" },
    opts = {
      -- your configuration comes here
      global_keymaps = true,
      global_keymaps_prefix = "<leader>n",
      kulala_keymaps_prefix = "",
    },
  },
}
