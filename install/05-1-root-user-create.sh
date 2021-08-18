#!/bin/bash

USER=
BTRFS=      # /dev/sda2 or /dev/vda2

if [ -z "$USER" ]; then
    read -r -p "Please choose an admin user to create: " USER
fi

# Create user
useradd -m -g wheel -s /bin/zsh "$USER"
passwd "$USER"
