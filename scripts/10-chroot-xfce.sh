#!/bin/bash
#/usr/bin/arch-chroot /mnt

pacman -S xfce4 xfce4-goodies xorg network-manager-applet lightdm lightdm-gtk-greeter pavucontrol
yay -S menulibre mugshot

systemctl enable lightdm
# systemctl enable bluetooth

# XFCE is causing problems for me in QEMU, right now...
