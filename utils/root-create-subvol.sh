#!/bin/bash

# snapper list
# btrfs sub list /

# Please confirm that @/ subvolid is 5.

USER=polv
BTRFS=/dev/sda5
FOLDER="/home/$USER/.local/share/Trash"

MNT="${FOLDER:1}"
MNT="${MNT//\//_}"

shopt -s dotglob

mkdir -p $FOLDER
mount $BTRFS -o subvolid=5 /mnt
btrfs sub create /mnt/@/$MNT
chattr +C /mnt/@/$MNT
chown -R $USER /mnt/@/$MNT
mv $FOLDER/* /mnt/@/$MNT
umount /mnt

echo "$BTRFS $FOLDER   btrfs   rw,noatime,compress=zstd:15,ssd,space_cache,subvolid=$(btrfs sub list / | grep "@/$MNT" | grep -oP '(?<=ID )[0-9]+'),subvol=/@/$MNT,discard=async,nodatacow 0 0" >> /etc/fstab
mount -a

echo "Consider changing from $BTRFS to blkid in /etc/fstab."
