#!/bin/bash

BTRFS=      # /dev/sda2 or /dev/vda2
microcode=      # amd-ucode or intel-ucode

if [ -z "$BTRFS" ]; then
    read -r -p "Please choose BTRFS partiion: " BTRFS
fi

if [ -z "$microcode" ]; then
    # Checking the microcode to install.
    CPU=$(grep vendor_id /proc/cpuinfo)
    if [[ $CPU == *"AuthenticAMD"* ]]
    then
        microcode=amd-ucode
    else
        microcode=intel-ucode
    fi
fi

PARTUUID=$(sudo blkid "$BTRFS" | grep -oP '(?<=PARTUUID=")([^"]+)' | head -n 1)

paru -S refind-btrfs

sudo cat << EOF >> /boot/efi/EFI/refind/refind.conf

menuentry "Arch Linux - Stable" {
    icon /EFI/refind/icons/os_arch.png
    volume ARCH
    loader /@/boot/vmlinuz-linux
    initrd /@/boot/initramfs-linux.img
    options "root=PARTUUID=$PARTUUID rw add_efi_memmap rootflags=subvol=@ initrd=@\boot\$microcode.img"
    submenuentry "Boot - fallback" {
        initrd /@/boot/initramfs-linux-fallback.img
    }
    submenuentry "Boot - terminal" {
        add_options "systemd.unit=multi-user.target"
    }
}
EOF

refind-btrfs
