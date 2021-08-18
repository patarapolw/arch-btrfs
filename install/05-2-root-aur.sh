#!/bin/bash

USER=
AUR=paru    # You can also use yay

if [ -z "$USER" ]; then
    read -r -p "Please choose an admin user to install AUR helper, $AUR: " USER
fi

export AUR

su - "$USER" <<EOF
    cd /tmp
    git clone --depth=1 https://aur.archlinux.org/$AUR.git
    cd $AUR
    makepkg -sic --noconfirm
EOF

# fix for paru
sed -i '/BottomUp/s/^#//' /etc/paru.conf
