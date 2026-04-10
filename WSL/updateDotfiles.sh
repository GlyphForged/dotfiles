#!/usr/bin/env bash
set -euo pipefail

HOME_FILES=(
  ".bashrc"
  ".gitconfig"
  ".gitignore_global"
  ".tmux.conf"
)

CONFIG_DIRS=(
  "nvim"
)

mkdir -p "$HOME/.config"

echo "Updating Dotfiles..."

# Keep a plain list of package names we still need to install.
packages_to_install=""

if command -v rsync >/dev/null 2>&1; then
  echo "Found rsync."
else
  echo "rsync is not installed."
  packages_to_install="$packages_to_install rsync"
fi

if command -v tmux >/dev/null 2>&1; then
  echo "Found tmux."
else
  echo "tmux is not installed."
  packages_to_install="$packages_to_install tmux"
fi

if command -v nvim >/dev/null 2>&1; then
  echo "Found nvim."
else
  echo "nvim is not installed."
  packages_to_install="$packages_to_install neovim"
fi

# Install anything that was missing.
if [[ -n "$packages_to_install" ]]; then
  echo "Installing missing packages:$packages_to_install"
  # shellcheck disable=SC2086
  sudo pacman -S --needed $packages_to_install
else
  echo "All required packages are already installed."
fi

# Copy files from this folder into your home directory one at a time.
for file in "${HOME_FILES[@]}"; do
  if [[ -e "$file" ]]; then
    echo "Syncing $file -> $HOME/$file"
    rsync -a "$file" "$HOME/$file"
  else
    echo "Skipping $file because it does not exist in this folder."
  fi
done

# Copy config folders into ~/.config one at a time.
for dir in "${CONFIG_DIRS[@]}"; do
  if [[ -d "$dir" ]]; then
    echo "Syncing $dir -> $HOME/.config/$dir/"
    rsync -a "$dir/" "$HOME/.config/$dir/"
  else
    echo "Skipping $dir because it does not exist in this folder."
  fi
done

echo "Done."
