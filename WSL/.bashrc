# If not running interactively, don't do anything (leave this at the top of this file)
if [[ $- != *i* ]]; then
  return
fi

# Aliases
alias p='python'
alias r='rust'
alias code="cd ~/Development"

# PendejOS helper commands.
alias makepos='cd "$HOME/PendejOS" && sudo rm -rf work/* && sudo mkarchiso -v -w "$PWD/work" -o "$PWD/out" "$PWD/profile/archiso"'
alias mkpos=makepos

alias bootpos='cd "$HOME/PendejOS" && VARS="$PWD/work/OVMF_VARS.fd" && if [ ! -f "$VARS" ]; then cp /usr/share/edk2/x64/OVMF_VARS.4m.fd "$VARS"; fi && qemu-system-x86_64 -enable-kvm -m 4096 -smp 4 -cpu host -machine q35 -device virtio-gpu-pci -device virtio-keyboard-pci -device virtio-mouse-pci -drive if=pflash,format=raw,readonly=on,file=/usr/share/edk2/x64/OVMF_CODE.4m.fd -drive if=pflash,format=raw,file="$VARS" -cdrom out/pendejos-0.0.1-x86_64.iso'

# Reload source
alias src='source "$HOME/.bashrc"'
