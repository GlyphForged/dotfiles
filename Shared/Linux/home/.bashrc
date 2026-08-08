# shellcheck shell=bash disable=SC1091
case "$-" in
  *i*) ;;
  *) return ;;
esac

[[ -f "$HOME/.shellrc" ]] && source "$HOME/.shellrc"
[[ -f "$HOME/.bashrc.local" ]] && source "$HOME/.bashrc.local"

if command -v starship >/dev/null 2>&1; then
  eval "$(starship init bash)"
fi
