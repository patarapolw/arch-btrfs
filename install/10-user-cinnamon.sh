#!/bin/bash

sudo pacman -S cinnamon blueberry gnome-terminal gnome-screenshot xorg lightdm
paru -S lightdm-slick-greeter

sudo systemctl enable lightdm
sudo systemctl enable bluetooth

FILE=/etc/lightdm/lightdm.conf
TMP=lightdm.conf
HEADER='[Seat:*]' SET='greeter-session=lightdm-slick-greeter' ./toml-editor.sh > /tmp/$TMP
sudo mv /tmp/$TMP $FILE