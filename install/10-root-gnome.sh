#!/bin/bash
#/usr/bin/arch-chroot /mnt

pacman -S gnome

systemctl enable gdm
systemctl enable bluetooth
