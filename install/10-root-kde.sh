#!/bin/bash

pacman -S plasma konsole dolphin

systemctl enable sddm
systemctl enable bluetooth

cp -r /usr/lib/sddm/sddm.conf.d /etc/

export FILE=/etc/sddm.conf.d/default.conf
HEADER='[Theme]' SET='Current=breeze' ./toml-editor.sh > $FILE.new
mv $FILE.new $FILE
