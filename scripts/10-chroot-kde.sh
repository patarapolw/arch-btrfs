#!/bin/bash
#/usr/bin/arch-chroot /mnt

pacman -S plasma konsole dolphin konsole

systemctl enable sddm
systemctl enable bluetooth

cp -r /usr/lib/sddm/sddm.conf.d /etc/

export FILE=/etc/sddm.conf.d/default.conf
HEADER='[Theme]' SET='Current=elarun' ./10-toml-editor.sh > $FILE.new
mv $FILE.new $FILE
