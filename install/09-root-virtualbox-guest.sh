#!/bin/bash

USER=

pacman -S virtualbox-guest-utils

if [ -z "$USER" ]; then
    read -r -p "Please choose a user to allow folder sharing in VirtualBox: " USER
fi

usermod -aG vboxsf $USER
systemctl enable vboxservice
