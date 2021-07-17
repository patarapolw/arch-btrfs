#!/bin/bash

arch-chroot /mnt /bin/bash -e <<EOF
    pacman -S gnome gnome-extra

    systemctl enable gdm
    systemctl enable bluetooth
EOF
