# WSL delegates host integration to Windows. PowerShell 7 is installed on the
# host by Windows/Bootstrap.ps1; no PowerShell package belongs inside Arch.
if command -v ssh.exe >/dev/null 2>&1; then
  alias ssh='ssh.exe'
  export GIT_SSH_COMMAND=ssh.exe
fi
command -v ssh-add.exe >/dev/null 2>&1 && alias ssh-add='ssh-add.exe'
command -v explorer.exe >/dev/null 2>&1 && alias openhere='explorer.exe .'

if command -v wslpath >/dev/null 2>&1; then
  winpath() { wslpath -w "$PWD"; }
fi

if command -v wslpath >/dev/null 2>&1 && command -v clip.exe >/dev/null 2>&1; then
  cwinpath() {
    wslpath -w "$PWD" | tr -d '\n' | clip.exe
    echo "Copied Windows path for the current directory."
  }
fi
