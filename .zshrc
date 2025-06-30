## keymaps
# ZSH vim

## use vi key bindings
bindkey -v
# avoid the annoying backspace/delete issue
# where backspace stops deleting characters
# bindkey '^?' backward-delete-char


# Add `~/bin` to the `$PATH`
export PATH="$HOME/bin:$PATH"

if [[ "$TERM_PROGRAM" == "vscode" ]]; then
  export ZSH_THEME=""
  PROMPT='%n@%m:%~%# '
  RPROMPT=''
  return  # Skip the rest of .zshrc
fi

# bindkey -s ^f "tmux-sessionizer\n"
if [[ $- == *i* ]]; then # interactive shell
  ## tmux-sessionizer keybinds
  bindkey -s '^F' 'tmux-sessionizer\n'
fi


# Load the shell dotfiles
for file in ~/.dotfiles/.{path,zsh_prompt,zirc,exports,aliases,functions,extra}; do
  [ -r "$file" ] && [ -f "$file" ] && source "$file"
done
unset file

# tab completion case-insensitive
zstyle ':completion:*' matcher-list '' 'm:{a-zA-Z}={A-Za-z}'


## need to be last
eval "$(oh-my-posh init zsh --config $HOME/.dotfiles/omp.json)"
