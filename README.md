# Dotfiles

In the interest of improving the portability of my linux installations, I built
this repository for my configuration files for NeoVim, Wayland, Bash, etc..

## But y tho?

This area is a placeholder. As I make decisions within these configs I want to
keep a record of why I made that choice. You're welcome future Aaron.

## Actually Useful Info

Assumptions:

- Arch Linux
- `sudo` is available for package installation

Extra shit this does:

- Installs `rsync`, `tmux`, and `neovim` if they are not already installed.
- Syncs the tracked home files and config directories into place.
- Avoids failing shell startup when optional local env files are absent.
