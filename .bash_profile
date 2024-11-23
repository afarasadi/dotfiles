# Add `~/bin` to the `$PATH`
export PATH="$HOME/bin:$PATH"

# ZSH vim
## use vi key bindings
bindkey -v
# avoid the annoying backspace/delete issue
# where backspace stops deleting characters
bindkey -v '^?' backward-delete-char

# Load the shell dotfiles, and then some:
# * ~/.path can be used to extend `$PATH`.
# * ~/.extra can be used for other settings you don’t want to commit.
for file in ~/.dotfiles/.{path,bash_prompt,exports,aliases,functions,extra}; do
  [ -r "$file" ] && [ -f "$file" ] && source "$file"
done
unset file

# Added by LM Studio CLI (lms)
export PATH="$PATH:/Users/afarasadi/.cache/lm-studio/bin"
