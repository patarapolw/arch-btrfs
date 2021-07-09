#!/bin/bash

sudo snapper list
sudo btrfs sub list /

read -r -p "Please choose the BTRFS partition: " BTRFS
read -r -p "Please choose the folder to convert: " FOLDER
read -r -p "Please choose N_FIRST: " N_FIRST
read -r -p "Please choose N_LAST: " N_LAST

sudo bash -c "
    btrfs sub set-default $N_FIRST /
    mount $BTRFS /mnt
    btrfs sub create /mnt/@/${${FOLDER:1}//\//_}
    chattr +C /mnt/@/${${FOLDER:1}//\//_}
    btrfs sub set-default $N_LAST /
    cp -r $FOLDER $FOLDER/. /mnt/@/${${FOLDER:1}//\//_}
    umount /mnt

    btrfs sub list /
    echo 'get the id of that newly created subvol and add the thing to /etc/fstab'
    echo 'when ready, type sudo mount -a'
"
