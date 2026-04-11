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
- The shared editor and prompt live in `Shared/`
- Environment-specific overrides live in `WSL/` and `Omarchy/`

Extra shit this does:

- Installs `rsync`, `tmux`, and `neovim` if they are not already installed.
- Syncs the tracked home files and config directories into place.
- Avoids failing shell startup when optional local env files are absent.

## Layout

- `Shared/` contains the shared Starship and Neovim configuration.
- `WSL/` contains WSL-specific shell files, package bootstrap, and optional Neovim overlay files.
- `Omarchy/` contains Omarchy-specific shell files, Hyprland config, package bootstrap, and optional Neovim overlay files.

Both update scripts sync `Shared/nvim` first and then sync the environment-specific `nvim` folder on top of it. That keeps most editor logic in one place while still allowing host-specific overrides.

## Neovim

The Neovim setup is built on LazyVim and bootstraps itself on first launch. The shared core includes:

- A Starship-inspired cyberpunk palette
- LazyVim extras for C/C++, Go, Python, Rust, TypeScript, and JSON
- Manual support for Roslyn C#, Godot/GDScript, HTML/CSS, Emmet, and formatter/linter wiring

Useful first-run commands:

```bash
nvim --headless "+Lazy! sync" +qa
nvim --headless "+checkhealth" +qa
```

## Godot Notes

GDScript language support depends on the Godot editor's built-in language server. Start the Godot editor before expecting Neovim to attach to a GDScript project.

For an external editor workflow, configure Godot to open files in Neovim and keep a server running. The Neovim config in this repo handles filetype support and editor-side setup, but the Godot editor still owns the GDScript language server.

On WSL, the update script also installs `godot-wsl-lsp`. That bridge makes it easier for Neovim inside WSL to talk to the Godot editor when the default localhost behavior is awkward across the Windows/Linux boundary.
