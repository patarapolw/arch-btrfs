#!/bin/bash -e

ROOT=$(git rev-parse --show-toplevel)
SQUASHFS=/tmp/arch-btrfs.squashfs
MOUNT_POINT=/tmp/mnt
CFG=config.yaml

mkdir -p $MOUNT_POINT
STATE_FILE=$MOUNT_POINT/.state

if [[ ! -f $STATE_FILE ]]; then
    mksquashfs $ROOT $SQUASHFS
    mount $SQUASHFS $MOUNT_POINT -t squashfs -o loop

    echo 'init' > $STATE_FILE
fi

cd $MOUNT_POINT

BTRFS=$(cat config.yaml | yq '.mount."/".device')
ESP=$(cat config.yaml | yq '.mount."/boot/efi".device')

if [[ $(tail -n1 $STATE_FILE) == 'init' ]]; then
    if $(cat config.yaml | yq '.mount."/boot/efi".format'); then
        mkfs.vfat $ESP
    fi

    LABEL=$(cat config.yaml | yq '.mount."/".label') ./lib/01-format/01-format-arch.sh
fi
