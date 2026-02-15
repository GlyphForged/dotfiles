#!/usr/bin/env bash
set -euo pipefail

HOME_FILES=(
  ".bashrc"
  ".gitconfig"
)

CONFIG_DIRS=(
  "nvim"
  # "hypr"
  # "waybar"
  # "wezterm"
)

mkdir -p "$HOME/.config"

echo "Updating Dotfiles..."

# --- Copy HOME files ---
for file in "${HOME_FILES[@]}"; do
  if [[ -e "$file" ]]; then
    echo "Syncing $file -> $HOME/$file"
    rsync -a "$file" "$HOME/$file"
  fi
done

# --- Copy .config dirs ---
for dir in "${CONFIG_DIRS[@]}"; do
  if [[ -d "$dir" ]]; then
    echo "Syncing $dir -> $HOME/.config/"
    rsync -a "$dir/" "$HOME/.config/$dir/"
  fi
done

echo "Done."
