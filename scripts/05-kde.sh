#!/bin/bash

arch-chroot /mnt /bin/bash -e <<EOF
    pacman -S plasma kde-applications

    systemctl enable sddm
    systemctl enable bluetooth
EOF
