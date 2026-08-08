#!/usr/bin/env bash
set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
REPO_ROOT="$(cd "$SCRIPT_DIR/.." && pwd)"
NETWORK_CHECK=0
[[ "${1:-}" == "--network" ]] && NETWORK_CHECK=1

fail() {
  echo "FAIL: $*" >&2
  exit 1
}

echo "Checking shell syntax..."
bash -n \
  "$REPO_ROOT/Arch/updateDotfiles.sh" \
  "$REPO_ROOT/WSL/updateDotfiles.sh" \
  "$REPO_ROOT/Shared/Linux/bootstrap.sh" \
  "$REPO_ROOT/Shared/Linux/home/.bash_profile" \
  "$REPO_ROOT/Shared/Linux/home/.bashrc" \
  "$REPO_ROOT/Shared/Linux/home/.shellrc" \
  "$REPO_ROOT/Legacy/Omarchy/updateDotfiles.sh"
zsh -n "$REPO_ROOT/Shared/Linux/home/.zshrc"

if command -v shellcheck >/dev/null 2>&1; then
  shellcheck -x \
    "$REPO_ROOT/Arch/updateDotfiles.sh" \
    "$REPO_ROOT/WSL/updateDotfiles.sh" \
    "$REPO_ROOT/Shared/Linux/bootstrap.sh" \
    "$REPO_ROOT/Shared/Linux/home/.bash_profile" \
    "$REPO_ROOT/Shared/Linux/home/.bashrc" \
    "$REPO_ROOT/Shared/Linux/home/.shellrc" \
    "$REPO_ROOT/Legacy/Omarchy/updateDotfiles.sh"
else
  echo "SKIP: shellcheck is not installed yet; the bootstrap will install it."
fi

echo "Checking Git and layer ownership..."
git config --file "$REPO_ROOT/Shared/Linux/gitconfig" --list >/dev/null
git config --file "$REPO_ROOT/Arch/.gitconfig" --list >/dev/null
git config --file "$REPO_ROOT/WSL/.gitconfig" --list >/dev/null
for duplicate in .bash_profile .bashrc .gitignore_global .inputrc .shellrc .tmux.conf .zshrc; do
  [[ ! -e "$REPO_ROOT/Arch/$duplicate" ]] || fail "Arch duplicates Shared/Linux/home/$duplicate"
  [[ ! -e "$REPO_ROOT/WSL/$duplicate" ]] || fail "WSL duplicates Shared/Linux/home/$duplicate"
done

echo "Checking Starship themes..."
mapfile -t palettes < <(sed -n -E 's/^\[palettes\.([^]]+)\]$/\1/p' "$REPO_ROOT/Shared/starship.toml")
((${#palettes[@]} == 7)) || fail "expected 7 Starship palettes, found ${#palettes[@]}"
mapfile -t alias_targets < <(sed -n -E "s/^alias theme-[^=]+='theme ([^']+)'$/\1/p" "$REPO_ROOT/Shared/Linux/home/.shellrc")
for target in "${alias_targets[@]}"; do
  printf '%s\n' "${palettes[@]}" | grep -Fxq "$target" || fail "shell shortcut targets missing palette: $target"
done

theme_config="$(mktemp -t glyphforged-starship.XXXXXX)"
theme_home="$(mktemp -d -t glyphforged-theme-home.XXXXXX)"
cleanup_theme_config() {
  rm -f -- "$theme_config"
  if [[ "$theme_home" == /tmp/glyphforged-theme-home.* ]]; then
    rm -rf -- "$theme_home"
  fi
}
trap cleanup_theme_config EXIT
for palette in "${palettes[@]}"; do
  cp "$REPO_ROOT/Shared/starship.toml" "$theme_config"
  sed -i -E "s/^palette = \"[^\"]+\"/palette = \"$palette\"/" "$theme_config"
  STARSHIP_CONFIG="$theme_config" starship prompt >/dev/null || fail "Starship failed to render $palette"
done

mkdir -p "$theme_home/.config"
cp "$REPO_ROOT/Shared/starship.toml" "$theme_home/.config/starship.toml"
HOME="$theme_home" bash --noprofile --norc -c 'source "$1"; theme mechanicus-subtle >/dev/null' _ "$REPO_ROOT/Shared/Linux/home/.shellrc"
grep -Fxq 'palette = "mechanicus-subtle"' "$theme_home/.config/starship.toml" || fail "theme command did not update Starship"
cp "$REPO_ROOT/Shared/starship.toml" "$theme_home/.config/starship.toml"
HOME="$theme_home" GLYPHFORGED_REPO_ROOT="$REPO_ROOT" GLYPHFORGED_ENV_DIR="$REPO_ROOT/Arch" \
  bash --noprofile --norc -c 'source "$1"; glyphforged_apply_saved_theme >/dev/null' _ "$REPO_ROOT/Shared/Linux/bootstrap.sh"
grep -Fxq 'palette = "mechanicus-subtle"' "$theme_home/.config/starship.toml" || fail "bootstrap did not restore the selected theme"

echo "Checking Neovim configuration..."
nvim --clean --headless -u NONE \
  "+lua assert(loadfile([[$REPO_ROOT/Shared/nvim/lua/glyphforged/palette.lua]]))" \
  "+lua assert(loadfile([[$REPO_ROOT/Shared/nvim/lua/plugins/colorscheme.lua]]))" \
  "+lua assert(loadfile([[$REPO_ROOT/Shared/nvim/lua/plugins/lualine.lua]]))" \
  "+lua assert(loadfile([[$REPO_ROOT/Arch/nvim/after/plugin/environment.lua]]))" \
  "+lua assert(loadfile([[$REPO_ROOT/WSL/nvim/after/plugin/environment.lua]]))" +qa
rg -q '"pwsh.exe"' "$REPO_ROOT/WSL/nvim/after/plugin/environment.lua" || fail "WSL clipboard is not using PowerShell 7"
rg -q 'pattern = "VeryLazy"' "$REPO_ROOT/WSL/nvim/after/plugin/environment.lua" || fail "WSL clipboard does not restore unnamedplus after VeryLazy"

echo "Checking README entrypoints..."
for documented_path in Arch/updateDotfiles.sh WSL/updateDotfiles.sh Windows/Bootstrap.ps1 Windows/Test-DevEnvironment.ps1 Tests/Test-Dotfiles.sh; do
  [[ -f "$REPO_ROOT/$documented_path" ]] || fail "README entrypoint is missing: $documented_path"
  windows_style_path="${documented_path//\//\\}"
  if ! rg -Fq "$documented_path" "$REPO_ROOT/README.md" && ! rg -Fq "$windows_style_path" "$REPO_ROOT/README.md"; then
    fail "README does not mention $documented_path"
  fi
done

if command -v pwsh.exe >/dev/null 2>&1; then
  windows_test_path="$(wslpath -w "$REPO_ROOT/Windows/Test-Scripts.ps1")"
  pwsh.exe -NoProfile -ExecutionPolicy Bypass -File "$windows_test_path"
  if command -v powershell.exe >/dev/null 2>&1; then
    powershell.exe -NoProfile -ExecutionPolicy Bypass -File "$windows_test_path"
  fi
fi

if ((NETWORK_CHECK)); then
  echo "Checking GitHub SSH fetch..."
  git ls-remote git@github.com:folke/lazy.nvim.git HEAD >/dev/null
fi

echo "Dotfiles sanity: PASS"
