#!/bin/bash

# lsblk

BTRFS=  # real partition, or /dev/mapper/cryptroot
ESP=

if [ -z "$BTRFS" ]; then
    read -r -p "Please choose the partition to format to BTRFS: " BTRFS
fi

if [ -z "$ESP" ]; then
    read -r -p "Please choose the EFI partition: " ESP
fi

mkfs.btrfs -L ARCH "$BTRFS"
mount "$BTRFS" /mnt

echo "Creating BTRFS subvolumes."

btrfs subvolume create /mnt/@
btrfs subvolume create /mnt/@/.snapshots
mkdir -p /mnt/@/.snapshots/1
btrfs subvolume create /mnt/@/.snapshots/1/snapshot

COW_VOLS=(home root boot srv cryptkey var/log var/crash var/spool var/lib/docker var/lib/containers)
NOCOW_VOLS=(var/tmp var/cache var/lib/libvirt/images)

elem_in() {
    local e m="$1"; shift
    for e in "$@"; do [[ "$m" == "$e" ]] && return 0; done
    return 1
}

for vol in "${COW_VOLS[@]}" "${NOCOW_VOLS[@]}"
do
    btrfs subvolume create "/mnt/@/${vol//\//_}"
    mkdir -p "/mnt/$vol"

    if elem_in "$vol" "${NOCOW_VOLS[@]}"; then
        chattr +C "/mnt/@/${vol//\//_}"
    fi
done

btrfs subvolume set-default "$(btrfs subvolume list /mnt | grep "@/.snapshots/1/snapshot" | grep -oP '(?<=ID )[0-9]+')" /mnt

cat << EOF >> /mnt/@/.snapshots/1/info.xml
<?xml version="1.0"?>
<snapshot>
    <type>single</type>
    <num>1</num>
    <date>2021-01-01 0:00:00</date>
    <description>First Root Filesystem</description>
    <cleanup>number</cleanup>
</snapshot>
EOF

chmod 600 /mnt/@/.snapshots/1/info.xml

umount /mnt

echo "Mounting the newly created subvolumes."

mount -o ssd,noatime,space_cache,compress=zstd:15 "$BTRFS" /mnt

for vol in .snapshots "${COW_VOLS[@]}" "${NOCOW_VOLS[@]}"
do
    mkdir -p "/mnt/$vol"
    mount -o "ssd,noatime,space_cache,autodefrag,compress=zstd:15,discard=async,subvol=@/${vol//\//_}" "$BTRFS" "/mnt/$vol"
done

mkdir -p /mnt/boot/efi
mount $ESP /mnt/boot/efi
