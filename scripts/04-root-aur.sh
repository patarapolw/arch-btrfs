#!/bin/bash
#/usr/bin/arch-chroot /mnt

echo 'Installing oh-my-zsh'
sh -c "$(curl -fsSL https://raw.github.com/ohmyzsh/ohmyzsh/master/tools/install.sh)"

read -r -p "Please choose an admin user: " USER

export AUR="yay"

su $USER -c -i "
    sh -c "$(curl -fsSL https://raw.github.com/ohmyzsh/ohmyzsh/master/tools/install.sh)"

    mkdir -p ~/.local/opt

    cd ~/.local/opt
    git clone --depth=1 https://aur.archlinux.org/$AUR.git
    cd $AUR
    makepkg -si
"