#!/bin/bash
#/usr/bin/arch-chroot /mnt

read -r -p "Please choose an admin user: " USER

export AUR="yay"

su $USER -c "
    sh -c "$(curl -fsSL https://raw.github.com/ohmyzsh/ohmyzsh/master/tools/install.sh)"

    mkdir -p ~/.local/opt

    cd ~/.local/opt
    git clone --depth=1 https://aur.archlinux.org/$AUR.git
    cd $AUR
    makepkg -si --noconfirm
"