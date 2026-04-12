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

- Installs the baseline tools this setup expects, including `neovim`, `tmux`, `starship`, and Ghostty on Omarchy.
- Syncs the tracked home files and config directories into place.
- Avoids failing shell startup when optional local env files are absent.

## Layout

- `Shared/` contains the shared Starship and Neovim configuration.
- `WSL/` contains WSL-specific shell files, package bootstrap, and optional Neovim overlay files.
- `Omarchy/` contains Omarchy-specific shell files, Hyprland config, package bootstrap, and optional Neovim overlay files.

Both update scripts sync `Shared/nvim` first and then sync the environment-specific `nvim` folder on top of it. That keeps most editor logic in one place while still allowing host-specific overrides.

## Neovim

The Neovim setup is built on LazyVim and bootstraps itself on first launch. The shared core includes:

- A SilkCircuit-inspired cyberpunk palette, with the Vibrant variant driving the color choices
- LazyVim extras for C/C++, Go, Python, Rust, TypeScript, and JSON
- Manual support for Roslyn C#, Godot/GDScript, HTML/CSS, Emmet, and formatter/linter wiring

Useful first-run commands:

```bash
nvim --headless "+Lazy! sync" +qa
nvim --headless "+checkhealth" +qa
```

## Theme Notes

The current look is based on SilkCircuit, specifically the Vibrant flavor instead
of the full-send Neon one.

Quick version of the options:

- `SilkCircuit Vibrant` is the default because it still looks loud without making my eyeballs want to commit seppuku.
- `SilkCircuit Neon` rules if you want the colors absolutely screaming at you.
- `Tokyo Night` is cleaner and more restrained, but it loses some of the cyberpunk vibes.
- `Catppuccin Mocha` is good, just softer than the vibe I'm aiming for.

For Neovim, I'm still using `nightfox.nvim` as the engine under the hood and
overriding the palette to match the SilkCircuit direction instead of swapping
the whole stack around.

For terminals, Omarchy uses Ghostty as the default terminal. On Windows and
WSL, this repo assumes you are using Windows Terminal and managing that setup
yourself outside the repo.

## Godot Notes

GDScript language support depends on the Godot editor's built-in language server. Start the Godot editor before expecting Neovim to attach to a GDScript project.

For an external editor workflow, configure Godot to open files in Neovim and keep a server running. The Neovim config in this repo handles filetype support and editor-side setup, but the Godot editor still owns the GDScript language server.

On WSL, the update script also installs `godot-wsl-lsp`. That bridge makes it easier for Neovim inside WSL to talk to the Godot editor when the default localhost behavior is awkward across the Windows/Linux boundary.
