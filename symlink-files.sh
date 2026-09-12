#!/bin/sh

# This script creates symbolic links for all dotfiles from the repository
# directory to the user's home directory.

DOTFILES_DIR=$(CDPATH= cd -- "$(dirname -- "$0")" && pwd)

for file in "$DOTFILES_DIR"/.*; do
  # Check if the file is a regular file and not the . or .. directories
  if [ -f "$file" ] && [ "$(basename "$file")" != "." ] && [ "$(basename "$file")" != ".." ]; then
    ln -sf "$file" "$HOME/$(basename "$file")"
    echo "Created symlink for $(basename "$file")"
  fi
done

echo "Symlinking complete."
