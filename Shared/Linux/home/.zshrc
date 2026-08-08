[[ -o interactive ]] || return
[[ -f "$HOME/.shellrc" ]] && source "$HOME/.shellrc"

HISTFILE="$HOME/.zsh_history"
HISTSIZE=10000
SAVEHIST=10000
setopt append_history hist_ignore_dups hist_reduce_blanks share_history

# Choose the keymap before Starship starts. Restarting prevents stacked ZLE
# wrappers and keeps vi mode opt-in instead of surprising fresh installs.
ZSH_KEYMAP_FILE="${XDG_STATE_HOME:-$HOME/.local/state}/zsh/keymap"
zsh_set_keymap() {
  local keymap="$1"

  case "$keymap" in
    emacs|vi) ;;
    *)
      echo "Usage: zvim | zemacs"
      return 2
      ;;
  esac

  mkdir -p "${ZSH_KEYMAP_FILE:h}"
  print -r -- "$keymap" > "$ZSH_KEYMAP_FILE"
  echo "Zsh command-line editing: $keymap (restarting shell)"
  exec zsh -l
}
zvim() { zsh_set_keymap vi; }
zemacs() { zsh_set_keymap emacs; }

if [[ -r "$ZSH_KEYMAP_FILE" ]] && [[ "$(<"$ZSH_KEYMAP_FILE")" == "vi" ]]; then
  bindkey -v
else
  bindkey -e
fi

autoload -Uz compinit
fpath=(/usr/share/zsh/site-functions $fpath)
compinit
[[ -r /usr/share/fzf/key-bindings.zsh ]] && source /usr/share/fzf/key-bindings.zsh
command -v starship >/dev/null 2>&1 && eval "$(starship init zsh)"
[[ -r /usr/share/zsh/plugins/zsh-autosuggestions/zsh-autosuggestions.zsh ]] && source /usr/share/zsh/plugins/zsh-autosuggestions/zsh-autosuggestions.zsh
# Syntax highlighting must load last.
[[ -r /usr/share/zsh/plugins/zsh-syntax-highlighting/zsh-syntax-highlighting.zsh ]] && source /usr/share/zsh/plugins/zsh-syntax-highlighting/zsh-syntax-highlighting.zsh
