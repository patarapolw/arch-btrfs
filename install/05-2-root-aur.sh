#!/bin/bash

USER=polv
AUR=yay

if [ -z "$USER" ]; then
    read -r -p "Please choose an admin user to install AUR helper, yay: " USER
fi

export AUR

su -l $USER <<EOF
    cd /tmp
    git clone --depth=1 https://aur.archlinux.org/$AUR.git
    cd $AUR
    makepkg -si

    touch ~/.zshrc
    #echo 'Installing oh-my-zsh'
    #sh -c "$(curl -fsSL https://raw.github.com/ohmyzsh/ohmyzsh/master/tools/install.sh)"
EOF
