#!/bin/bash

pacman -S cinnamon blueberry gnome-terminal gnome-screenshot xorg lightdm
paru -S lightdm-slick-greeter

systemctl enable lightdm
systemctl enable bluetooth

FILE=/etc/lightdm/lightdm.conf
HEADER='[Seat:*]' SET='greeter-session=lightdm-slick-greeter' ./toml-editor.sh > $FILE.new
mv $FILE.new $FILE
