## keymaps
# ZSH vim

## use vi key bindings
bindkey -v
# avoid the annoying backspace/delete issue
# where backspace stops deleting characters
# bindkey '^?' backward-delete-char


# Add `~/bin` to the `$PATH`
export PATH="$HOME/bin:$PATH"

# if [[ "$TERM_PROGRAM" == "vscode" ]]; then
#   export ZSH_THEME=""
#   PROMPT='%n@%m:%~%# '
#   RPROMPT=''
#   return  # Skip the rest of .zshrc
# fi

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

# --- History Settings ---
HISTFILE="$HOME/.zsh_history"
HISTSIZE=100000
SAVEHIST=100000

setopt APPEND_HISTORY
setopt INC_APPEND_HISTORY
setopt SHARE_HISTORY
setopt HIST_EXPIRE_DUPS_FIRST
setopt HIST_IGNORE_DUPS
setopt HIST_IGNORE_ALL_DUPS
setopt HIST_REDUCE_BLANKS
setopt HIST_FIND_NO_DUPS
setopt HIST_SAVE_NO_DUPS
setopt HIST_VERIFY

# --- Usability ---
setopt AUTO_CD                  # 'myfolder' = cd myfolder
setopt AUTO_PUSHD               # Push old dir to stack when using cd
setopt PUSHD_IGNORE_DUPS        # Avoid duplicates in directory stack
setopt PUSHD_SILENT             # Don't print directory stack after cd
setopt EXTENDED_GLOB            # Use **/*.js and other advanced globs
setopt NO_FLOW_CONTROL          # Disable Ctrl-S/Ctrl-Q freeze
setopt INTERACTIVE_COMMENTS     # Allow # in interactive commands

# --- Completion & Suggestions ---
autoload -Uz compinit && compinit
zstyle ':completion:*' menu select
zstyle ':completion:*' group-name ''
zstyle ':completion:*' matcher-list 'm:{a-z}={A-Za-z}'
zstyle ':completion:*' list-colors ${(s.:.)LS_COLORS}

# Enable command correction (zsh will suggest correct command)
setopt CORRECT
CORRECT_IGNORE='rm'             # Don’t correct dangerous commands like rm
## need to be last
eval "$(oh-my-posh init zsh --config $HOME/.dotfiles/omp.json)"


#THIS MUST BE AT THE END OF THE FILE FOR SDKMAN TO WORK!!!
export SDKMAN_DIR="/Users/afarasadi/.sdkman"
[[ -s "/Users/afarasadi/.sdkman/bin/sdkman-init.sh" ]] && source "/Users/afarasadi/.sdkman/bin/sdkman-init.sh"

# Add RVM to PATH for scripting. Make sure this is the last PATH variable change.
export PATH="$PATH:$HOME/.rvm/bin"

# # >>> conda initialize >>>
# # !! Contents within this block are managed by 'conda init' !!
# __conda_setup="$('/usr/local/Caskroom/miniconda/base/bin/conda' 'shell.zsh' 'hook' 2> /dev/null)"
# if [ $? -eq 0 ]; then
#     eval "$__conda_setup"
# else
#     if [ -f "/usr/local/Caskroom/miniconda/base/etc/profile.d/conda.sh" ]; then
#         . "/usr/local/Caskroom/miniconda/base/etc/profile.d/conda.sh"
#     else
#         export PATH="/usr/local/Caskroom/miniconda/base/bin:$PATH"
#     fi
# fi
# unset __conda_setup
# # <<< conda initialize <<<


[[ "$TERM_PROGRAM" == "kiro" ]] && . "$(kiro --locate-shell-integration-path zsh)"

if [[ -n "$npm_config_yes" ]] || [[ -n "$CI" ]] || [[ "$-" != *i* ]]; then
  export AGENT_MODE=true
else
  export AGENT_MODE=false
fi

if [[ "$AGENT_MODE" == "true" ]]; then
  # Ensure non-interactive mode
  export DEBIAN_FRONTEND=noninteractive
  export NONINTERACTIVE=1
fi

if [[ "$AGENT_MODE" == "true" ]]; then
  ZSH_THEME=""  # Disable theme for agents
fi

# Later in your .zshrc - minimal prompt for agents
if [[ "$AGENT_MODE" == "true" ]]; then
  PROMPT='%n@%m:%~%# '
  RPROMPT=''
  unsetopt CORRECT
  unsetopt CORRECT_ALL
  setopt NO_BEEP
  setopt NO_HIST_BEEP  
  setopt NO_LIST_BEEP
  
  # Agent-friendly aliases to avoid interactive prompts
  alias npm='npm --no-fund --no-audit'
  alias yarn='yarn --non-interactive'
  alias pip='pip --quiet'
  alias git='git -c advice.detachedHead=false'
fi

.

export NVM_DIR="$HOME/.nvm"
[ -s "$NVM_DIR/nvm.sh" ] && \. "$NVM_DIR/nvm.sh"  # This loads nvm
[ -s "$NVM_DIR/bash_completion" ] && \. "$NVM_DIR/bash_completion"  # This loads nvm bash_completion

# pnpm
export PNPM_HOME="/Users/afarasadi/Library/pnpm"
case ":$PATH:" in
  *":$PNPM_HOME:"*) ;;
  *) export PATH="$PNPM_HOME:$PATH" ;;
esac
# pnpm end

export PATH=$PATH:$HOME/.maestro/bin
