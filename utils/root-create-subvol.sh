#!/bin/bash

# snapper list
# btrfs sub list /

# Please confirm that @/ subvolid is 5.

# USER=
BTRFS=$(df -T / | grep btrfs | tail -n 1 | cut -d" " -f1)
FOLDER=

if [ ! -z "$BTRFS" ]; then
    exit 1
fi

if [ ! -z "$FOLDER" ]; then
    read -r -p "Please enter folder path: " FOLDER
fi

if [ ! -z "$USER" ]; then
    USER=root
fi

if [ FOLDER[1] = "~" ]; then
    if [ USER = "root" ]; then
        FOLDER="/root${FOLDER:1}"
    else
        if [ ! -z "$USER" ]; then
            read -r -p "Please enter username: " USER
        fi

        FOLDER="/home/${USER}${FOLDER:1}"
        USER=$(echo $FOLDER | cut -d"/" -f2)
    fi
fi

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
