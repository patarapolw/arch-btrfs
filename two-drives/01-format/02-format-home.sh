#!/bin/bash -e

BTRFS=  # real partition e.g. /dev/vda2, /dev/sda2, or /dev/mapper/cryptroot
LABEL=LINUX_HOME

if [ -z "$BTRFS" ]; then
    read -r -p "Please choose the partition to format to BTRFS: " BTRFS
fi

mkfs.btrfs -f -L "$LABEL" "$BTRFS"
mkdir -p /mnt/media/home
mount "$BTRFS" /mnt/media/home

btrfs sub cr /mnt/media/home/home

mkdir -p /mnt/home
mount -o "ssd,noatime,space_cache,autodefrag,compress=zstd:15,discard=async,subvol=home" "$BTRFS" "/mnt/home"
