## keymaps
# ZSH vim

## use vi key bindings
bindkey -v
# avoid the annoying backspace/delete issue
# where backspace stops deleting characters
# bindkey '^?' backward-delete-char

# bindkey -s ^f "tmux-sessionizer\n"

if [[ $- == *i* ]]; then # interactive shell
  ## tmux-sessionizer keybinds
  bindkey -s '^F' 'tmux-sessionizer\n'
fi

# Add `~/bin` to the `$PATH`
export PATH="$HOME/bin:$PATH"

# Load the shell dotfiles
for file in ~/.dotfiles/.{path,zsh_prompt,exports,aliases,functions,extra}; do
  [ -r "$file" ] && [ -f "$file" ] && source "$file"
done
unset file

