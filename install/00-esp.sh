#!/bin/bash

# fdisk -l

PART=
# PART=/dev/vda

if [ ! -z "$PART" ]; then
    read -r -p "Please choose the partition name: " PART
fi

parted $PART -- mklabel gpt

parted $PART -- mkpart ESP fat32 1MiB 512MiB
parted $PART -- mkpart primary 512MiB 100%

lsblk

mkfs.vfat "${PART}1"
