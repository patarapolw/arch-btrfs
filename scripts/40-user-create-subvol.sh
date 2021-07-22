#!/bin/bash

sudo snapper list
sudo btrfs sub list /

read -r -p "Please choose the BTRFS partition: " BTRFS
read -r -p "Please choose the folder to convert: " FOLDER
read -r -p "Please choose N_FIRST: " N_FIRST # 5
read -r -p "Please choose N_CURRENT: " N_CURRENT # 356

# export BTRFS=/dev/sda5
# export FOLDER="$HOME/.local/share/Steam"
# export N_FIRST=5
# export N_CURRENT=390

export MNT="${FOLDER:1}"
export MNT="${MNT//\//_}"

sudo bash -c "
    btrfs sub set-default $N_FIRST /
    mount $BTRFS /mnt
    btrfs sub create /mnt/@/$MNT
    chattr +C /mnt/@/$MNT
    mv $FOLDER/* $FOLDER/.* /mnt/@/$MNT
    btrfs sub set-default $N_CURRENT /
    umount /mnt

    btrfs sub list /
    echo 'get the id of that newly created subvol and add the thing to /etc/fstab'
    echo 'when ready, type sudo mount -a'
"
