# If this is not an interactive shell, stop here.
case "$-" in
*i*) ;;
*) return ;;
esac

# Load personal machine-specific shell settings if they exist.
if [[ -f "$HOME/.bashrc.local" ]]; then
  source "$HOME/.bashrc.local"
fi

# Basic aliases.
alias p='python'
alias r='rust'
alias src='source "$HOME/.bashrc"'

# Use the 1Password SSH agent when it is available.
if [[ -S "$HOME/.1password/agent.sock" ]]; then
  export SSH_AUTH_SOCK="$HOME/.1password/agent.sock"
fi

# Jump to your main development folder if it exists.
if [[ -d "$HOME/code" ]]; then
  alias code='cd "$HOME/code"'
fi

# Open the current Linux folder in Windows Explorer.
if command -v explorer.exe >/dev/null 2>&1; then
  alias openhere='explorer.exe .'
fi

# Print the current directory as a Windows path.
if command -v wslpath >/dev/null 2>&1; then
  winpath() {
    wslpath -w "$PWD"
  }
fi

# Copy the current directory as a Windows path.
if command -v wslpath >/dev/null 2>&1; then
  if command -v clip.exe >/dev/null 2>&1; then
    cwinpath() {
      wslpath -w "$PWD" | tr -d '\n' | clip.exe
      echo "Copied Windows path for the current directory."
    }
  fi
fi

# Load the curated shell prompt when Starship is installed.
if command -v starship >/dev/null 2>&1; then
  eval "$(starship init bash)"
fi
