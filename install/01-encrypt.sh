#!/bin/bash

CRYPTROOT=

if [ ! -z "$CRYPTROOT" ]; then
    read -n -p "Please choose a partition to be formatted to LUKS: " CRYPTROOT
fi

cryptsetup luksFormat $CRYPTROOT
cryptsetup open $CRYPTROOT cryptroot
