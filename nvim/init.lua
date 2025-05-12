-- bootstrap lazy.nvim, LazyVim and your plugins
if vim.g.vscode then
  require("config.config")
  require("user.keymaps")
  require("user.lazy")
else
  require("config.config")
  require("config.lazy")
end
