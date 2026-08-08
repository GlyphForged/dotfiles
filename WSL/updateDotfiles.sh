#!/usr/bin/env bash
set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
GLYPHFORGED_REPO_ROOT="$(cd "$SCRIPT_DIR/.." && pwd)"
GLYPHFORGED_ENV_DIR="$SCRIPT_DIR"
export GLYPHFORGED_REPO_ROOT GLYPHFORGED_ENV_DIR

glyphforged_environment_install() {
  if command -v godot-wsl-lsp >/dev/null 2>&1; then
    echo "Found godot-wsl-lsp."
  else
    echo "Installing godot-wsl-lsp with npm."
    sudo npm install --global godot-wsl-lsp
  fi
}

glyphforged_environment_check() {
  local command_name failed=0 missing_commands=()
  local required_commands=(ssh.exe ssh-add.exe clip.exe pwsh.exe op-ssh-sign-wsl.exe)
  for command_name in "${required_commands[@]}"; do
    command -v "$command_name" >/dev/null 2>&1 || missing_commands+=("$command_name")
  done
  command -v godot-wsl-lsp >/dev/null 2>&1 || missing_commands+=(godot-wsl-lsp)
  if ((${#missing_commands[@]})); then
    echo "Missing WSL integration commands: ${missing_commands[*]}"
    echo "Run Windows/Bootstrap.ps1, unlock 1Password, and confirm WSL interop is enabled."
    failed=1
  else
    echo "Windows SSH, PowerShell 7, clipboard, signing, and Godot integration: PASS"
  fi
  return "$failed"
}

# shellcheck disable=SC1091
source "$GLYPHFORGED_REPO_ROOT/Shared/Linux/bootstrap.sh"
glyphforged_main "$@"
