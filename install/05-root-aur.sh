#!/bin/bash
#/usr/bin/arch-chroot /mnt

read -r -p "Please choose an admin user to install AUR helper, yay: " USER
export AUR="yay"

su -l $USER <<EOF
    cd /tmp
    git clone --depth=1 https://aur.archlinux.org/$AUR.git
    cd $AUR
    makepkg -si

    echo 'Installing oh-my-zsh'
    read -n 1
    sh -c "$(curl -fsSL https://raw.github.com/ohmyzsh/ohmyzsh/master/tools/install.sh)"
EOF
