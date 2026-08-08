# shellcheck shell=bash disable=SC1091
# Load the interactive Bash config for login shells too.
if [[ -f "$HOME/.bashrc" ]]; then
  source "$HOME/.bashrc"
fi
