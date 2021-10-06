#!/bin/bash -e

BTRFS=  # real partition e.g. /dev/vda2, /dev/sda2, or /dev/mapper/cryptroot
ESP=    # /dev/vda1, /dev/sda1
LABEL=ARCH

if [ -z "$BTRFS" ]; then
    read -r -p "Please choose the partition to format to BTRFS: " BTRFS
fi

if [ -z "$ESP" ]; then
    read -r -p "Please choose the EFI partition: " ESP
fi

mkfs.btrfs -f -L "$LABEL" "$BTRFS"
mount "$BTRFS" /mnt

echo "Creating BTRFS subvolumes."

btrfs subvolume create /mnt/@

COW_VOLS=(
    boot
    root
    srv
    var/log
    var/crash
    var/spool
    var/lib/docker
    var/lib/containers
)
NOCOW_VOLS=(
    var/tmp
    var/cache
    var/lib/libvirt/images
    .swap  # If you need Swapfile, create in this folder
)

elem_in() {
    local e m="$1"; shift
    for e in "$@"; do [[ "$m" == "$e" ]] && return 0; done
    return 1
}

for vol in "${COW_VOLS[@]}" "${NOCOW_VOLS[@]}"
do
    btrfs subvolume create "/mnt/@${vol//\//_}"

    if elem_in "$vol" "${NOCOW_VOLS[@]}"; then
        chattr +C "/mnt/@${vol//\//_}"
    fi
done

umount /mnt

echo "Mounting the newly created subvolumes."

mount -o ssd,noatime,space_cache,compress=zstd:15 "$BTRFS" /mnt

for vol in "${COW_VOLS[@]}" "${NOCOW_VOLS[@]}"
do
    mkdir -p "/mnt/$vol"
    mount -o "ssd,noatime,space_cache,autodefrag,compress=zstd:15,discard=async,subvol=@${vol//\//_}" "$BTRFS" "/mnt/$vol"
done

mkdir -p /mnt/boot/efi
mount $ESP /mnt/boot/efi
