#!/bin/bash -e

CFG="$(git rev-parse --show-toplevel)/config.yaml"

HOME=$(yq -r '.mount."/home".device' $CFG)
LABEL=$(yq -r '.mount."/home".label' $CFG)

if [[ -z $HOME ]]; then
    exit 1
fi

mkfs.btrfs -f -L $LABEL $HOME
mkdir -p /mnt/media/$LABEL
mount $HOME /mnt/media/$LABEL

btrfs sub cr /mnt/media/$LABEL/@

mkdir -p /mnt/home
mount -o "ssd,noatime,space_cache,autodefrag,compress=zstd:15,discard=async,subvol=@" $HOME "/mnt/home"
