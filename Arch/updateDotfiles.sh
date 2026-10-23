#!/usr/bin/env bash
set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
GLYPHFORGED_REPO_ROOT="$(cd "$SCRIPT_DIR/.." && pwd)"
GLYPHFORGED_ENV_DIR="$SCRIPT_DIR"
export GLYPHFORGED_REPO_ROOT GLYPHFORGED_ENV_DIR

DESKTOP_PACKAGES="$GLYPHFORGED_ENV_DIR/desktop/packages.txt"

glyphforged_desktop_missing_packages() {
  local package_name

  while IFS= read -r package_name; do
    pacman -Qq "$package_name" &>/dev/null ||
      printf '%s\n' "$package_name"
  done < <(sed -E '/^[[:space:]]*(#|$)/d' "$DESKTOP_PACKAGES")
}

glyphforged_environment_install() {
  local missing_packages=()

  [[ -f "$DESKTOP_PACKAGES" ]] || {
    echo "Missing desktop package manifest: $DESKTOP_PACKAGES"
    return 1
  }

  mapfile -t missing_packages < <(glyphforged_desktop_missing_packages)

  if ((${#missing_packages[@]})); then
    sudo pacman -S --needed "${missing_packages[@]}"
  else
    echo "All desktop packages are installed."
  fi
}

glyphforged_environment_check() {
  local missing_packages=()

  [[ -f "$DESKTOP_PACKAGES" ]] || {
    echo "Missing desktop package manifest: $DESKTOP_PACKAGES"
    return 1
  }

  mapfile -t missing_packages < <(glyphforged_desktop_missing_packages)

  if ((${#missing_packages[@]})); then
    printf 'Missing desktop packages: %s\n' "${missing_packages[*]}"
    return 1
  fi

  echo "Arch desktop package parity: PASS"
}

# shellcheck disable=SC1091
source "$GLYPHFORGED_REPO_ROOT/Shared/Linux/bootstrap.sh"
glyphforged_main "$@"
