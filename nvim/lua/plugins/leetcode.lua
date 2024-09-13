local leet_arg = "leetcode.nvim"
return {
  {
    "kawre/leetcode.nvim",
    lazy = leet_arg ~= vim.fn.argv()[1],
    opts = {
      arg = leet_arg,
      lang = "cpp",
      injector = { ---@type table<lc.lang, lc.inject>
        ["cpp"] = {
          before = { "#include <vector>", "using namespace std;" },
          after = "int main() {}",
        },
        ["java"] = {
          before = "import java.util.*;",
        },
      },
    },
    build = ":TSUpdate html",
    dependencies = {
      "nvim-telescope/telescope.nvim",
      "nvim-lua/plenary.nvim", -- required by telescope
      "MunifTanjim/nui.nvim",

      -- optional
      "nvim-treesitter/nvim-treesitter",
      "rcarriga/nvim-notify",
      "nvim-tree/nvim-web-devicons",
    },
    keys = {
      { "<leader>lq", mode = { "n" }, "<cmd>Leet tabs<cr>" },
      { "<leader>lm", mode = { "n" }, "<cmd>Leet menu<cr>" },
      { "<leader>lc", mode = { "n" }, "<cmd>Leet console<cr>" },
      { "<leader>li", mode = { "n" }, "<cmd>Leet info<cr>" },
      { "<leader>ll", mode = { "n" }, "<cmd>Leet lang<cr>" },
      { "<leader>ld", mode = { "n" }, "<cmd>Leet desc<cr>" },
      { "<leader>lr", mode = { "n" }, "<cmd>Leet run<cr>" },
      { "<leader>ls", mode = { "n" }, "<cmd>Leet submit<cr>" },
      { "<leader>ly", mode = { "n" }, "<cmd>Leet yank<cr>" },
      { "<leader>lp", mode = { "n" }, "<cmd>Leet list<cr>" },
    },
  },
}
