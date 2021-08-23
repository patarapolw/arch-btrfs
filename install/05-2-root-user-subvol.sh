#!/bin/bash

USER=
BTRFS=      # /dev/sda2 or /dev/vda2

if [ -z "$USER" ]; then
    read -r -p "Please choose an admin user to create: " USER
fi

if [ -z "$BTRFS" ]; then
    read -r -p "Please choose BTRFS partiion: " BTRFS
fi

UUID=$(blkid "$BTRFS" | grep -oP '(?<=UUID=")([^"]+)' | head -n 1)

COW_PATHS=(
    ".var"
    ".local/share/Steam"
    ".local/share/containers"
    # "Downloads"               # Cannot send from Download to Trash
    # ".local/share/Trash"      # Cannot use Trash at all
)

NOCOW_PATHS=(
    ".cache"
    "vmware"
    "VirtualBox VMs"
)

elem_in() {
    local e m="$1"; shift
    for e in "$@"; do [[ "$m" == "$e" ]] && return 0; done
    return 1
}

mount $BTRFS -o subvolid=5 /mnt

for vol in "${COW_PATHS[@]}" "${NOCOW_PATHS[@]}"
do
    orig_vol="$vol"
    vol="home/$USER/$vol"

    mnt="${vol//\//_}"
    mnt="${mnt// /--}"

    mkdir -p "/$vol"
    chown "$USER" "/$vol"
    btrfs sub cr "/mnt/@/$mnt"

    if elem_in "$orig_vol" "${NOCOW_PATHS[@]}"; then
        chattr +C "/mnt/@/$mnt"
    fi

    chown $USER "/mnt/@/$mnt"
    rsync -axXv "/$vol/" "/mnt/@/$mnt/"

    printf "\nUUID=$UUID\t/%s\tbtrfs\trw,noatime,compress=zstd:15,ssd,space_cache,subvolid=$(btrfs sub list / | grep "@/$mnt" | grep -oP '(?<=ID )[0-9]+'),subvol=/@/%s,discard=async\t0\t0\n" "${vol// /\\040}" "$mnt" >> /etc/fstab
done

chown -R "$USER" "/home/$USER"

umount /mnt
mount -a
