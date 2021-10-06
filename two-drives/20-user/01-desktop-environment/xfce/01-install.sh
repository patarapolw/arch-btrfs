#!/bin/bash -e

sudo pacman -S --needed xfce4 xfce4-goodies xorg network-manager-applet lightdm bluez pavucontrol gvfs imagemagick
paru -S menulibre mugshot lightdm-slick-greeter lightdm-settings

sudo systemctl enable lightdm
sudo systemctl enable bluetooth
