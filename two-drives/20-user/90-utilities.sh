#!/bin/bash -e

APPS=(
    firefox
    pipewire pipewire-pulse
    vlc
    neofetch
    gnome-keyring
    openssh
    gparted
    conky
    tree
)

sudo pacman -S --needed "${APPS[@]}"
