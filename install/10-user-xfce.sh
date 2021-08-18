#!/bin/bash

sudo pacman -S xfce4 xfce4-goodies xorg network-manager-applet lightdm lightdm-gtk-greeter bluez pavucontrol pulseaudio
paru -S menulibre mugshot

sudo systemctl enable lightdm
sudo systemctl enable bluetooth
