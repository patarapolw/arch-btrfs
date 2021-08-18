#!/bin/bash

pacman -S lxqt sddm xorg connman slock alsa-lib libpulse libstatgrab libsysstat lm_sensors bluez
paru -S lxqt-connman-applet

systemctl enable sddm
systemctl enable bluetooth

cp -r /usr/lib/sddm/sddm.conf.d /etc/

FILE=/etc/sddm.conf.d/default.conf
HEADER='[Theme]' SET='Current=elarun' ./toml-editor.sh > $FILE.new
mv $FILE.new $FILE
