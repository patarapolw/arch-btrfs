#!/bin/bash

read -r -p "Please choose an admin user: " USER

export AUR="yay"

arch-chroot /mnt /bin/bash -e <<EOF
    su $USER
    mkdir -p ~/.local/opt

    cd ~/.local/opt
    git clone --depth=1 https://aur.archlinux.org/$AUR.git
    cd $AUR
    makepkg -si
EOF
