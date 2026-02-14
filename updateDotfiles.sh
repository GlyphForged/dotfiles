#!/usr/bin/env bash
set -euo pipefail


DEST=$HOME/.config
mkdir -p "$DEST"

echo "Updating Dotfiles..."
for dir in */; do
  [ -d "$dir" ] || continue
  echo "Copying $dir -> $DEST"
  cp -a "$dir" "$DEST/"
done
echo "Dotfiles have been updated."
