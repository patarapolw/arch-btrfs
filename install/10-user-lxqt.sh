#!/bin/bash

sudo pacman -S lxqt sddm xorg connman slock alsa-lib libpulse libstatgrab libsysstat lm_sensors bluez
paru -S lxqt-connman-applet

sudo systemctl enable sddm
sudo systemctl enable bluetooth

sudo cp -r /usr/lib/sddm/sddm.conf.d /etc/

export FILE=/etc/sddm.conf.d/default.conf
TMP=sddm.conf
HEADER='[Theme]' SET='Current=elarun' ./toml-editor.sh > /tmp/$TMP
mv /tmp/$TMP $FILE
