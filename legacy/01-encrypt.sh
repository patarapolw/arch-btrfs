#!/bin/bash

CRYPTROOT=  # /dev/vda2 for qemu

if [ -z "$CRYPTROOT" ]; then
    read -n -p "Please choose a partition to be formatted to LUKS: " CRYPTROOT
fi

# https://wiki.archlinux.org/title/GRUB#Encrypted_/boot
# Warning: GRUB 2.0.6 has limited support for LUKS2. See GRUB bug #55093. 
cryptsetup luksFormat --type luks1 "$CRYPTROOT"
cryptsetup open "$CRYPTROOT" cryptroot
