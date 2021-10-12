#!/bin/bash -e

HOME=
CFG=${CFG:-"$(git rev-parse --show-toplevel)/config.yaml"}
LABEL=${LABEL:-$(cat $CFG | yq '.mount."/home".label')}

if [[ -z $HOME ]]; then
    exit 1
fi

mkfs.btrfs -f -L $LABEL $HOME
mkdir -p /mnt/media/$LABEL
mount $HOME /mnt/media/$LABEL

btrfs sub cr /mnt/media/$LABEL/@

mkdir -p /mnt/home
mount -o "ssd,noatime,space_cache,autodefrag,compress=zstd:15,discard=async,subvol=@" $HOME "/mnt/home"
