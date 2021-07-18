#!/bin/bash
#/usr/bin/arch-chroot /mnt

pacman -S plasma kde-applications

systemctl enable sddm
systemctl enable bluetooth
