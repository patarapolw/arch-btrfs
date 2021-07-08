#!/bin/bash

read -r -p "Please choose an admin user: " USER

export AUR="yay"

arch-chroot /mnt /bin/bash -e <<EOF
    sudo $USER
    cd ~
    mkdir -p ~/.local/opt

    git clone --depth=1 https://aur.archlinux.org/$AUR.git
    cd $AUR
    makepkg -si
EOF
