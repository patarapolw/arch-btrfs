#!/bin/bash
#/usr/bin/arch-chroot /mnt

pacman -S plasma konsole dolphin konsole

systemctl enable sddm
systemctl enable bluetooth

cp -r /usr/lib/sddm/sddm.conf.d /etc/
# sed -i -E '/Current=/s/Current=.*$/Current=breeze/s' /etc/sddm.conf.d/default.conf
./10-toml-editor.py --set='Current=breeze' --header='[Theme]' /etc/sddm.conf.d/default.conf > /etc/sddm.conf.d/default.conf
