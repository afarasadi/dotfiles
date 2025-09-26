#!/bin/sh

# This script creates symbolic links for all dotfiles from the ~/.dotfiles
# directory to the user's home directory.

for file in "$HOME"/.dotfiles/.*; do
  # Check if the file is a regular file and not the . or .. directories
  if [ -f "$file" ] && [ "$(basename "$file")" != "." ] && [ "$(basename "$file")" != ".." ]; then
    ln -sf "$file" "$HOME/$(basename "$file")"
    echo "Created symlink for $(basename "$file")"
  fi
done

echo "Symlinking complete."
