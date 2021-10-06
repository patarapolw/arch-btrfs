#!/bin/bash -e

sudo pacman -S --needed xfce4 xfce4-goodies xorg network-manager-applet lightdm bluez pavucontrol gvfs
paru -S menulibre mugshot lightdm-slick-greeter lightdm-settings

sudo systemctl enable lightdm
sudo systemctl enable bluetooth

export FILE=/etc/lightdm/lightdm.conf
TMP=lightdm.conf
HEADER='[Seat:*]' SET='greeter-session=lightdm-slick-greeter' ./_toml-editor.sh > /tmp/$TMP
sudo mv /tmp/$TMP $FILE
