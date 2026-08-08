#!/usr/bin/env bash

# Shared implementation sourced by Arch and WSL entrypoints.

GLYPHFORGED_SHARED_LINUX="$GLYPHFORGED_REPO_ROOT/Shared/Linux"
GLYPHFORGED_HOME_CONFIG="$HOME/.config"
GLYPHFORGED_STATE_DIR="${XDG_STATE_HOME:-$HOME/.local/state}/glyphforged"
GLYPHFORGED_CONFIG_DIR="$GLYPHFORGED_HOME_CONFIG/glyphforged"

glyphforged_read_packages() {
  sed -E '/^[[:space:]]*(#|$)/d' "$GLYPHFORGED_SHARED_LINUX/packages.txt"
}

glyphforged_validate_source_tree() {
  local failed=0 source_file
  local required_files=(
    "$GLYPHFORGED_SHARED_LINUX/packages.txt"
    "$GLYPHFORGED_SHARED_LINUX/gitconfig"
    "$GLYPHFORGED_SHARED_LINUX/home/.bash_profile"
    "$GLYPHFORGED_SHARED_LINUX/home/.bashrc"
    "$GLYPHFORGED_SHARED_LINUX/home/.gitignore_global"
    "$GLYPHFORGED_SHARED_LINUX/home/.inputrc"
    "$GLYPHFORGED_SHARED_LINUX/home/.shellrc"
    "$GLYPHFORGED_SHARED_LINUX/home/.tmux.conf"
    "$GLYPHFORGED_SHARED_LINUX/home/.zshrc"
    "$GLYPHFORGED_ENV_DIR/.gitconfig"
    "$GLYPHFORGED_ENV_DIR/shell/environment.sh"
    "$GLYPHFORGED_REPO_ROOT/Shared/starship.toml"
    "$GLYPHFORGED_REPO_ROOT/Shared/nvim/init.lua"
  )

  for source_file in "${required_files[@]}"; do
    if [[ ! -f "$source_file" ]]; then
      echo "Missing source file: $source_file"
      failed=1
    fi
  done
  return "$failed"
}

glyphforged_missing_packages() {
  local package_name
  while IFS= read -r package_name; do
    pacman -Qi "$package_name" >/dev/null 2>&1 || printf '%s\n' "$package_name"
  done < <(glyphforged_read_packages)
}

glyphforged_install_packages() {
  local missing_packages=()
  mapfile -t missing_packages < <(glyphforged_missing_packages)
  if ((${#missing_packages[@]})); then
    echo "Installing missing packages: ${missing_packages[*]}"
    sudo pacman -S --needed "${missing_packages[@]}"
  else
    echo "All required pacman packages are installed."
  fi
}

glyphforged_install_rust() {
  if ! rustup toolchain list | grep -q '^stable'; then
    rustup toolchain install stable
  fi
  rustup default stable
}

glyphforged_apply_saved_theme() {
  local config_file="$GLYPHFORGED_HOME_CONFIG/starship.toml"
  local state_file="$GLYPHFORGED_STATE_DIR/starship-theme"
  local theme_name
  [[ -r "$state_file" ]] || return 0
  theme_name="$(<"$state_file")"
  if grep -Fxq "[palettes.$theme_name]" "$config_file"; then
    sed -i -E "s/^palette = \"[^\"]+\"/palette = \"$theme_name\"/" "$config_file"
    echo "Restored Starship theme: $theme_name"
  else
    echo "Ignoring stale Starship theme selection: $theme_name"
  fi
}

glyphforged_sync_home() {
  local file_name source_path
  local home_files=(.bash_profile .bashrc .gitignore_global .inputrc .shellrc .tmux.conf .zshrc)
  for file_name in "${home_files[@]}"; do
    source_path="$GLYPHFORGED_SHARED_LINUX/home/$file_name"
    echo "Syncing $source_path -> $HOME/$file_name"
    rsync -a "$source_path" "$HOME/$file_name"
  done

  mkdir -p "$GLYPHFORGED_CONFIG_DIR/shell"
  rsync -a "$GLYPHFORGED_SHARED_LINUX/gitconfig" "$GLYPHFORGED_CONFIG_DIR/gitconfig"
  rsync -a "$GLYPHFORGED_ENV_DIR/.gitconfig" "$HOME/.gitconfig"
  rsync -a "$GLYPHFORGED_ENV_DIR/shell/environment.sh" "$GLYPHFORGED_CONFIG_DIR/shell/environment.sh"
  rsync -a "$GLYPHFORGED_REPO_ROOT/Shared/starship.toml" "$GLYPHFORGED_HOME_CONFIG/starship.toml"
  glyphforged_apply_saved_theme
}

glyphforged_backup_nvim_once() {
  local target="$GLYPHFORGED_HOME_CONFIG/nvim"
  local marker="$GLYPHFORGED_STATE_DIR/nvim-authoritative-sync"
  local backup_dir
  [[ -d "$target" && ! -e "$marker" ]] || return 0
  backup_dir="$GLYPHFORGED_CONFIG_DIR/backups/nvim-$(date +%Y%m%d%H%M%S)"
  mkdir -p "$backup_dir" "$GLYPHFORGED_STATE_DIR"
  rsync -a "$target/" "$backup_dir/"
  : > "$marker"
  echo "Backed up the previous Neovim config to $backup_dir"
}

glyphforged_sync_nvim() {
  local staging_dir target_dir
  staging_dir="$(mktemp -d -t glyphforged-nvim.XXXXXX)"
  target_dir="$GLYPHFORGED_HOME_CONFIG/nvim"

  cleanup_glyphforged_nvim_staging() {
    if [[ -n "${staging_dir:-}" && "$staging_dir" == /tmp/glyphforged-nvim.* ]]; then
      rm -rf -- "$staging_dir"
    fi
  }
  trap cleanup_glyphforged_nvim_staging RETURN

  rsync -a "$GLYPHFORGED_REPO_ROOT/Shared/nvim/" "$staging_dir/"
  if [[ -d "$GLYPHFORGED_ENV_DIR/nvim" ]]; then
    rsync -a "$GLYPHFORGED_ENV_DIR/nvim/" "$staging_dir/"
  fi

  glyphforged_backup_nvim_once
  mkdir -p "$target_dir"
  rsync -a --delete "$staging_dir/" "$target_dir/"
  trap - RETURN
  cleanup_glyphforged_nvim_staging
}

glyphforged_set_zsh_shell() {
  local target_user="${SUDO_USER:-$USER}" target_shell current_shell
  target_shell="$(command -v zsh)"
  current_shell="$(getent passwd "$target_user" | cut -d: -f7)"
  if [[ "$current_shell" == "$target_shell" ]]; then
    echo "Zsh is already the login shell for $target_user."
    return 0
  fi
  sudo chsh -s "$target_shell" "$target_user"
  echo "Zsh is now the login shell. Open a new terminal."
}

glyphforged_check_core() {
  local failed=0 missing_packages=()
  glyphforged_validate_source_tree || failed=1
  mapfile -t missing_packages < <(glyphforged_missing_packages)
  if ((${#missing_packages[@]})); then
    echo "Missing pacman packages: ${missing_packages[*]}"
    failed=1
  else
    echo "Pacman package parity: PASS"
  fi
  if ! rustup toolchain list | grep -q '^stable'; then
    echo "Missing stable Rust toolchain."
    failed=1
  else
    echo "Stable Rust toolchain: PASS"
  fi
  git config --file "$GLYPHFORGED_ENV_DIR/.gitconfig" --list >/dev/null || failed=1
  STARSHIP_CONFIG="$GLYPHFORGED_REPO_ROOT/Shared/starship.toml" starship prompt >/dev/null || failed=1
  return "$failed"
}

glyphforged_main() {
  local mode="${1:-apply}" failed=0
  if [[ "$mode" == "--check" ]]; then
    glyphforged_check_core || failed=1
    glyphforged_environment_check || failed=1
    return "$failed"
  fi
  if [[ "$mode" != "apply" ]]; then
    echo "Usage: $0 [--check]"
    return 2
  fi

  glyphforged_validate_source_tree
  mkdir -p "$GLYPHFORGED_HOME_CONFIG" "$GLYPHFORGED_STATE_DIR"
  glyphforged_install_packages
  glyphforged_install_rust
  glyphforged_environment_install
  glyphforged_sync_home
  glyphforged_sync_nvim
  glyphforged_environment_check || echo "Environment integration is incomplete; see warnings above."
  glyphforged_set_zsh_shell
  echo "Done."
}
