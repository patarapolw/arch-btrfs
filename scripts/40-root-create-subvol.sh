#!/bin/bash

# snapper list
# btrfs sub list /

USER=polv
BTRFS=/dev/sda5
FOLDER="/home/polv/.local/share/Trash"
N_FIRST=5
N_CURRENT=$(btrfs sub get-default / | grep -oP '(?<=ID )[0-9]+')

MNT="${FOLDER:1}"
MNT="${MNT//\//_}"

shopt -s dotglob

mkdir -p $FOLDER
btrfs sub set-default $N_FIRST /
mount $BTRFS /mnt
btrfs sub create /mnt/@/$MNT
chattr +C /mnt/@/$MNT
chown -R $USER /mnt/@/$MNT
mv $FOLDER/* /mnt/@/$MNT
btrfs sub set-default $N_CURRENT /
umount /mnt

# btrfs sub list /
# echo 'get the id of that newly created subvol and add the thing to /etc/fstab'
# echo 'when ready, type mount -a'

echo "$BTRFS $FOLDER   btrfs   rw,noatime,compress=zstd:15,ssd,space_cache,subvolid=$(btrfs sub list / | grep "@/$MNT" | grep -oP '(?<=ID )[0-9]+'),subvol=/@/$MNT,discard=async,nodatacow 0 0" >> /etc/fstab
mount -a
