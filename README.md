# Dotfiles

In the interest of improving the portability of my Linux installations, I
built this repository for my configuration files for Neovim, Zsh, Windows
Terminal, etc..

The goal is to eventually be able to run this on a fresh Arch install, whether
that is bare metal or WSL, and get something that feels like my machine without
having to remember every little decision I made along the way.

## But y tho?

As I make decisions within these configs I want to keep a record of why I made
that choice. You're welcome future Aaron.

Also, I forget shit. If I solve something annoying once, it should probably
stay solved.

## Actually Useful Info

Assumptions:

- Arch Linux is the native Linux target.
- Arch under WSL is the WSL target.
- `sudo` is available for package installation.
- PowerShell 7, 1Password, OpenSSH, Windows Terminal, and Godot live on the
  Windows side of WSL.
- PowerShell 5.1 gets compatibility support, but it is not the target.

On a Windows machine, do the Windows setup first. From PowerShell in the repo
root:

```powershell
Set-ExecutionPolicy -Scope Process Bypass
.\Windows\Bootstrap.ps1
```

This installs PowerShell 7 if needed, relaunches the bootstrap under `pwsh.exe`,
installs Starship and the Nerd Font, updates Windows Terminal, and adds the
managed profile loader to both PowerShell 7 and Windows PowerShell 5.1.

Windows Terminal labels these **PowerShell 7** and **Windows PowerShell 5.1
(legacy)**. If 5.1 was the default it gets replaced with 7; an existing WSL
default is left alone.

Then run the Linux setup that matches the machine:

```bash
# Bare-metal Arch
./Arch/updateDotfiles.sh

# Arch under WSL
./WSL/updateDotfiles.sh
```

Both scripts can be run again without reinstalling or resetting everything.
They install missing packages, sync the managed files, set up the stable Rust
toolchain, and move the login shell to Zsh. Open a new terminal after the first
run.

To check things without changing the machine:

```bash
./Arch/updateDotfiles.sh --check
./WSL/updateDotfiles.sh --check
./Tests/Test-Dotfiles.sh
```

`--check` does not use sudo, npm, rsync, or chsh. The repository sanity check is
offline unless `--network` is passed.

## Layout

- `Shared/Linux/` contains the shared package list, shell files, Git defaults,
  and common Arch bootstrap logic.
- `Shared/nvim/` and `Shared/starship.toml` contain the shared editor and prompt
  configuration.
- `Arch/` contains the plain Arch environment overrides.
- `WSL/` contains the Windows integration: SSH, signing, clipboard, path
  helpers, and the Godot bridge.
- `Windows/` contains the PowerShell, Windows Terminal, font, and Starship
  setup.
- `Legacy/Omarchy/` contains the old Omarchy desktop setup. It is not part of
  the normal bootstrap anymore, but I am keeping it around for now.

The shared Linux layer is meant to be boring. Arch and WSL should only contain
what is actually different between them. Windows executables do not belong in
the plain Arch setup.

Neovim is built from `Shared/nvim` plus the current environment overlay in a
temporary directory before it is synced to `~/.config/nvim`. The first managed
sync backs up the existing directory. Later runs remove stale managed files so
old plugin configs do not hang around and waste my time.

Private or machine-specific settings go here:

- `~/.shellrc.local`
- `~/.gitconfig.local`

Neither file is managed by this repository. Private host aliases stay out of
Git, which is a lesson I apparently needed to write down.

## Development Setup

The shared Arch package list and Neovim config cover:

- C/C++ and Raylib: GCC, Clang, clangd, clang-format, CMake, GDB, pkgconf, and
  Raylib.
- Rust: rustup and the stable toolchain.
- Go: Go, gopls, goimports, and gofumpt.
- Python: Python, pip, virtual environments, Pyright, and Ruff.
- Web: Node/npm, HTML, CSS, JavaScript, JSON, Emmet, and Prettier.
- Godot/GDScript: native Godot LSP on Arch, or Windows Godot through
  `godot-wsl-lsp` under WSL.
- The regular useful stuff: Neovim, Git, Ripgrep, fd, fzf, Lazygit, tmux,
  Starship, Zsh, completions, autosuggestions, syntax highlighting, and
  ShellCheck.

TypeScript support is still available when a project needs it. I am not making
it the default or pretending I like it.

## Shell Notes

Zsh is the default login shell. It starts with Emacs-style line editing because
I have not sat down and properly learned vi mode yet.

- `zvim` switches to vi command-line editing and restarts the shell.
- `zemacs` switches back to Emacs editing and restarts the shell.
- `src` restarts the current login shell instead of repeatedly sourcing config
  and stacking Starship/ZLE hooks.

The selected editing mode is stored locally and survives new terminals. Emacs
mode is the fresh-install default.

## Theme Notes

The original look was based on SilkCircuit, specifically the Vibrant flavor
instead of the full-send Neon one. That has grown into a few related Starship
palettes:

- `cyberpunk-subtle`, `cyberpunk-vibrant`, `cyberpunk-neon`
- `mechanicus-subtle`, `mechanicus-vibrant`, `mechanicus-neon`
- `orkz`

Quick version:

- Cyberpunk is the original cyan/magenta setup at three saturation levels.
- Mechanicus is warmer: rust, brass, and forge heat.
- Orkz is green and loud, as Gork and Mork intended.

`cyberpunk-vibrant` is still the default because it looks loud without making
my eyeballs want to commit seppuku.

Use `theme <palette>` or one of the shortcuts in Bash, Zsh, or PowerShell:

```text
theme-subtle                 theme-mechanicus-subtle
theme-vibrant                theme-mechanicus-vibrant
theme-neon                   theme-mechanicus-neon
theme-orkz
```

Theme names are discovered from `Shared/starship.toml`; there is not a second
hard-coded list in each shell. The selected theme is stored locally and is
reapplied after future bootstrap runs.

Neovim keeps its own cyberpunk-vibrant/Nightfox palette regardless of the
terminal theme.

## Windows and PowerShell

PowerShell 7 is the preferred Windows shell. Windows PowerShell 5.1 still loads
the managed profile, but its older PSReadLine does not handle this multiline
Starship prompt correctly. If input appears below the `サムライ >>` line, check:

```powershell
$PSVersionTable.PSVersion
(Get-Process -Id $PID).Path
```

Major version 7 and a path ending in `pwsh.exe` are what I want.

The Windows bootstrap supports:

```text
-SkipPowerShellInstall  -SkipStarshipInstall  -SkipFontInstall
-SkipTerminalSettings   -SkipPowerShellProfile
```

Skipped components report `SKIP` during validation instead of producing a
false failure.

Windows Terminal gets CaskaydiaCove Nerd Font Mono and the retro CRT effect in
`profiles.defaults`, so the settings apply to both PowerShell and WSL. The
script makes a timestamped backup before changing `settings.json`.

If the Terminal settings contain comments, the script refuses to rewrite them.
Manually merge `Windows/windows-terminal.settings.jsonc` instead. Flattening a
hand-edited file just to make the script simpler would be a dick move.

The managed PowerShell profile lives at:

```text
%USERPROFILE%\.config\glyphforged\Microsoft.PowerShell_profile.ps1
```

The normal PowerShell profiles only get a small loader block. Existing profiles
are backed up and otherwise left alone.

Windows validation:

```powershell
.\Windows\Test-DevEnvironment.ps1
```

## WSL Notes

Before running the WSL bootstrap:

1. Run the Windows bootstrap and open a new PowerShell 7 tab.
2. Install and unlock 1Password for Windows, then enable its SSH agent.
3. Confirm `ssh-add.exe -l` shows the expected key.
4. Confirm WSL can find `pwsh.exe`, `ssh.exe`, `clip.exe`, and
   `op-ssh-sign-wsl.exe`.

Git and LazyVim use `ssh.exe`, so the Windows 1Password agent handles SSH. There
is no fake Linux `SSH_AUTH_SOCK` to keep alive. Neovim copies through `clip.exe`
and pastes through Windows `pwsh.exe`; `unnamedplus` is restored after LazyVim's
`VeryLazy` event.

Useful helpers:

- `openhere` opens the current directory in Explorer.
- `winpath` prints the Windows form of the current path.
- `cwinpath` copies that path to the Windows clipboard.
- `lg` starts Lazygit.

Godot still runs on Windows for this setup. Start the editor before expecting
GDScript completion; `godot-wsl-lsp` is the bridge between it and Neovim in
WSL.

## Neovim

The Neovim setup is built on LazyVim. The shared config includes the language
support above, formatting/linting, Roslyn for C#, Godot/GDScript support, the
custom Nightfox palette, and katakana lualine labels. WSL adds the Windows
clipboard provider; plain Arch stays Linux-native.

Useful first-run and sanity checks:

```bash
nvim --headless "+checkhealth" +qa
pkgconf --modversion raylib
rustc --version
cargo --version
go version
python --version
node --version
rg --version
lazygit --version
```

For the whole repository:

```bash
./Tests/Test-Dotfiles.sh
./Tests/Test-Dotfiles.sh --network  # also checks GitHub SSH auth
```

## When Shit Breaks

- WSL Git says `Permission denied (publickey)`: unlock 1Password, run
  `ssh-add.exe -l`, then `./WSL/updateDotfiles.sh --check`.
- WSL clipboard is dead: confirm `pwsh.exe` and `clip.exe` resolve, restart
  Neovim, and check `:checkhealth provider`.
- Zsh changes are missing: open a new terminal or run `src`.
- Godot completion is dead: start the Windows Godot editor and confirm
  `godot-wsl-lsp` exists in WSL.
- PowerShell input appears on a third prompt line: make sure the tab is
  **PowerShell 7**, not **Windows PowerShell 5.1 (legacy)**.
- The Terminal script rejects `settings.json`: it found comments. Use the
  tracked manual-merge fragment instead.

This is still a work in progress, but it is getting close to the original goal:
run one thing on fresh Arch and get a useful machine without spending the rest
of the night trying to remember how past me set it up.
