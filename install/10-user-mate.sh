#!/bin/bash

sudo pacman -S mate mate-extra mate-media blueman xorg network-manager-applet lightdm
paru -S lightdm-slick-greeter

sudo systemctl enable lightdm
sudo systemctl enable bluetooth

export FILE=/etc/lightdm/lightdm.conf
TMP=lightdm.conf
HEADER='[Seat:*]' SET='greeter-session=lightdm-slick-greeter' ./toml-editor.sh > /tmp/$TMP
sudo mv /tmp/$TMP $FILE
