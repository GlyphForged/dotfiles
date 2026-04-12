#!/usr/bin/env bash
set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
REPO_ROOT="$(cd "$SCRIPT_DIR/.." && pwd)"
SHARED_DIR="$REPO_ROOT/Shared"
HOME_CONFIG_DIR="$HOME/.config"

HOME_FILES=(
  ".bashrc"
  ".gitconfig"
  ".gitignore_global"
  ".tmux.conf"
)

PACMAN_PACKAGES=(
  "base-devel"
  "clang"
  "clang-tools-extra"
  "cmake"
  "curl"
  "dotnet-sdk"
  "fd"
  "gcc"
  "git"
  "go"
  "less"
  "make"
  "neovim"
  "nodejs"
  "npm"
  "python"
  "python-pip"
  "python-virtualenv"
  "ripgrep"
  "rsync"
  "rustup"
  "starship"
  "tmux"
  "unzip"
  "ghostty"
  "wget"
)

copy_home_file() {
  local file_name="$1"
  local source_path="$SCRIPT_DIR/$file_name"
  local destination_path="$HOME/$file_name"

  if [[ -e "$source_path" ]]; then
    echo "Syncing $source_path -> $destination_path"
    rsync -a "$source_path" "$destination_path"
  else
    echo "Skipping $source_path because it does not exist."
  fi
}

copy_config_file() {
  local source_path="$1"
  local destination_name="$2"
  local destination_path="$HOME_CONFIG_DIR/$destination_name"

  if [[ -f "$source_path" ]]; then
    echo "Syncing $source_path -> $destination_path"
    rsync -a "$source_path" "$destination_path"
  else
    echo "Skipping $source_path because it does not exist."
  fi
}

copy_config_dir() {
  local source_path="$1"
  local destination_name="$2"
  local destination_path="$HOME_CONFIG_DIR/$destination_name"

  if [[ -d "$source_path" ]]; then
    echo "Syncing $source_path/ -> $destination_path/"
    mkdir -p "$destination_path"
    rsync -a "$source_path/" "$destination_path/"
  else
    echo "Skipping $source_path because it does not exist."
  fi
}

install_missing_pacman_packages() {
  local packages_to_install=()
  local package_name=""

  for package_name in "${PACMAN_PACKAGES[@]}"; do
    if pacman -Qi "$package_name" >/dev/null 2>&1; then
      echo "Found package: $package_name"
    else
      echo "Missing package: $package_name"
      packages_to_install+=("$package_name")
    fi
  done

  if [[ "${#packages_to_install[@]}" -gt 0 ]]; then
    echo "Installing missing packages with pacman..."
    sudo pacman -S --needed "${packages_to_install[@]}"
  else
    echo "All required pacman packages are already installed."
  fi
}

echo "Updating Omarchy dotfiles..."
mkdir -p "$HOME_CONFIG_DIR"

install_missing_pacman_packages

for file_name in "${HOME_FILES[@]}"; do
  copy_home_file "$file_name"
done

copy_config_file "$SHARED_DIR/starship.toml" "starship.toml"
copy_config_dir "$SHARED_DIR/nvim" "nvim"
copy_config_dir "$SCRIPT_DIR/nvim" "nvim"
copy_config_dir "$SCRIPT_DIR/hypr" "hypr"

echo "Done."
