#!/bin/bash

arch-chroot /mnt /bin/bash -e <<EOF
    pacman -S xfce4 xfce4-goodies network-manager-applet lightdm lightdm-gtk-greeter

    systemctl enable lightdm
    systemctl enable bluetooth
EOF
