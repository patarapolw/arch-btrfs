#!/bin/bash

pacman -S mate mate-extra mate-media blueman xorg network-manager-applet lightdm
paru -S lightdm-slick-greeter

systemctl enable lightdm
systemctl enable bluetooth

FILE=/etc/lightdm/lightdm.conf
HEADER='[Seat:*]' SET='greeter-session=lightdm-slick-greeter' ./toml-editor.sh > $FILE.new
mv $FILE.new $FILE
