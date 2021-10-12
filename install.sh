#!/bin/bash -e

STEPS_ROOT=two-drives
MOUNT_POINT=/tmp/mnt

mkdir -p $MOUNT_POINT

STATE_FILE=$MOUNT_POINT/.state

if [[ ! -f $STATE_FILE ]]; then
    mksquashfs $(git rev-parse --show-toplevel) /tmp/arch-btrfs.squashfs
    mount /tmp/arch-btrfs.squashfs $MOUNT_POINT -t squashfs -o loop

    echo 'init' > $STATE_FILE
fi

if [[ $(cat $STATE_FILE) == 'init' ]]; then
fi
