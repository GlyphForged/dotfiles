#!/usr/bin/env bash
set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
GLYPHFORGED_REPO_ROOT="$(cd "$SCRIPT_DIR/.." && pwd)"
GLYPHFORGED_ENV_DIR="$SCRIPT_DIR"
export GLYPHFORGED_REPO_ROOT GLYPHFORGED_ENV_DIR

glyphforged_environment_install() { :; }
glyphforged_environment_check() {
  echo "Plain Arch environment overlay: PASS"
}

# shellcheck disable=SC1091
source "$GLYPHFORGED_REPO_ROOT/Shared/Linux/bootstrap.sh"
glyphforged_main "$@"
