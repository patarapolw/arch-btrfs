#!/bin/bash

pacman -S xfce4 xfce4-goodies xorg network-manager-applet lightdm lightdm-gtk-greeter bluez pavucontrol pulseaudio
paru -S menulibre mugshot

systemctl enable lightdm
systemctl enable bluetooth
