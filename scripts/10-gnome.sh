#!/bin/bash
#/usr/bin/arch-chroot /mnt

pacman -S gnome gnome-extra

systemctl enable gdm
systemctl enable bluetooth
