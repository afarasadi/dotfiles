personal dotfiles

#
## Create symlink .files to home folder (replace if it exists)
sudo find . -maxdepth 1 -type f -name ".*" -exec sh -c 'ln -sf "$(realpath "$1")" ~' sh {} \;

