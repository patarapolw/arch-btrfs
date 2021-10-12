#!/bin/bash

USER=

if [ -z "$USER" ]; then
    read -r -p "Please choose an admin user to create: " USER
fi

# Create user
useradd -m -g wheel -s /bin/zsh "$USER"
passwd "$USER"
