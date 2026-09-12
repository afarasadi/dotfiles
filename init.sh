#!/usr/bin/env bash

set -euo pipefail

DOTFILES_DIR="$(CDPATH= cd -- "$(dirname -- "${BASH_SOURCE[0]}")" && pwd)"
export PATH="$HOME/.local/bin:$PATH"

log() {
  printf ':: %s\n' "$*"
}

fail() {
  printf 'init.sh: %s\n' "$*" >&2
  exit 1
}

run_as_root() {
  if ((EUID == 0)); then
    "$@"
  elif command -v sudo >/dev/null 2>&1; then
    sudo "$@"
  else
    fail "root privileges are required to install packages; install sudo or run init.sh as root"
  fi
}

missing_commands() {
  local command_name

  for command_name in "$@"; do
    if ! command -v "$command_name" >/dev/null 2>&1; then
      printf '%s\n' "$command_name"
    fi
  done
}

bootstrap_linux() {
  local missing
  missing="$(missing_commands curl git zsh unzip tmux)"

  if [ -z "$missing" ]; then
    return
  fi

  log "Installing missing commands: ${missing//$'\n'/, }"

  if command -v apt-get >/dev/null 2>&1; then
    run_as_root apt-get update
    run_as_root env DEBIAN_FRONTEND=noninteractive apt-get install -y \
      ca-certificates curl git unzip zsh tmux
  elif command -v dnf >/dev/null 2>&1; then
    run_as_root dnf install -y ca-certificates curl git unzip zsh tmux
  elif command -v pacman >/dev/null 2>&1; then
    run_as_root pacman -Sy --needed --noconfirm ca-certificates curl git unzip zsh tmux
  elif command -v apk >/dev/null 2>&1; then
    run_as_root apk add ca-certificates curl git unzip zsh tmux
  else
    fail "could not find a supported package manager (apt-get, dnf, pacman, or apk)"
  fi

  missing="$(missing_commands curl git zsh unzip tmux)"
  [ -z "$missing" ] || fail "package installation did not provide: ${missing//$'\n'/, }"
}

bootstrap_macos() {
  local missing
  missing="$(missing_commands curl git zsh unzip tmux)"

  if [ -n "$missing" ]; then
    if command -v brew >/dev/null 2>&1; then
      log "Installing missing commands: ${missing//$'\n'/, }"
      brew install ca-certificates curl git unzip zsh tmux
    else
      fail "missing ${missing//$'\n'/, }; install Xcode Command Line Tools or Homebrew first"
    fi
  fi

  if command -v brew >/dev/null 2>&1 &&
    ! command -v reattach-to-user-namespace >/dev/null 2>&1; then
    brew install reattach-to-user-namespace
  fi
}

install_oh_my_posh() {
  if command -v oh-my-posh >/dev/null 2>&1; then
    return
  fi

  log "Installing Oh My Posh"
  if [ "$(uname -s)" = "Darwin" ] && command -v brew >/dev/null 2>&1; then
    brew install jandedobbeleer/oh-my-posh/oh-my-posh
  else
    curl -fsSL https://ohmyposh.dev/install.sh | bash -s
  fi

  hash -r
  command -v oh-my-posh >/dev/null 2>&1 ||
    [ -x "$HOME/.local/bin/oh-my-posh" ] ||
    fail "Oh My Posh was installed but is not available on PATH"
}

install_zi() {
  export ZI_HOME="$HOME/.zi"
  log "Installing or updating z-shell/zi"
  sh -c "$(curl -fsSL https://get.zshell.dev)" -- -i skip
}

install_tpm() {
  local tpm_dir="$HOME/.tmux/plugins/tpm"

  mkdir -p "$(dirname -- "$tpm_dir")"
  if [ -d "$tpm_dir/.git" ]; then
    log "TPM is already installed"
  elif [ -e "$tpm_dir" ]; then
    fail "$tpm_dir exists but is not a Git checkout"
  else
    git clone https://github.com/tmux-plugins/tpm "$tpm_dir"
  fi
}

link_dotfiles() {
  mkdir -p "$HOME/.config"
  ln -sfn "$DOTFILES_DIR/nvim" "$HOME/.config/nvim"
  ln -sfn "$DOTFILES_DIR/kitty" "$HOME/.config/kitty"
  ln -sfn "$DOTFILES_DIR/opencode" "$HOME/.config/opencode"
  ln -sfn "$DOTFILES_DIR/.wezterm.lua" "$HOME/.wezterm.lua"

  chmod +x "$DOTFILES_DIR/symlink-files.sh"
  zsh "$DOTFILES_DIR/symlink-files.sh"
}

case "$(uname -s)" in
Linux)
  bootstrap_linux
  ;;
Darwin)
  bootstrap_macos
  ;;
*)
  fail "unsupported operating system: $(uname -s)"
  ;;
esac

install_zi
install_oh_my_posh
install_tpm
link_dotfiles

# Load the Zsh configuration in Zsh so zi plugins are initialized correctly.
log "Verifying Zsh startup and loading zi plugins"
zsh -ic ':'

log "Initialization complete. Start a new shell with: exec zsh -l"
