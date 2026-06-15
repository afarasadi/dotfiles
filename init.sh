# install zi without modifying .zshrc (already added)
export ZI_HOME="$HOME/.zi"
sh -c "$(curl -fsSL get.zshell.dev)" -- -i skip

# Install om-my-posh with brew
if command -v brew >/dev/null 2>&1; then
  brew install jandedobbeleer/oh-my-posh/oh-my-posh
fi

if [[ "$(uname)" == "Darwin" ]]; then
  # macOS
  if command -v brew >/dev/null 2>&1; then
    brew install reattach-to-user-namespace
  fi
fi

# install tmux plugin manager
# then enter tmux, source-file ~/.tmux.con
# then prefix + I to install plugins
git clone https://github.com/tmux-plugins/tpm "$HOME/.tmux/plugins/tpm"

ln -s "$HOME/.dotfiles/nvim" "$HOME/.config/nvim"
ln -sf "$HOME/.dotfiles/kitty" "$HOME/.config/kitty"
ln -sf "$HOME/.dotfiles/.wezterm.lua" "$HOME/.wezterm.lua"

# symlink .files
chmod +x "$HOME/.dotfiles/symlink-files.sh"
zsh +x "$HOME/.dotfiles/symlink-files.sh"

source "$HOME/.zshrc"
