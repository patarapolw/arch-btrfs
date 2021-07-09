#!/bin/bash

read -r -p "Please choose the partition to format to BTRFS: " BTRFS

mkfs.btrfs $BTRFS
# mkfs.btrfs -f $BTRFS
mount $BTRFS /mnt

echo "Creating BTRFS subvolumes."

btrfs subvolume create /mnt/@
btrfs subvolume create /mnt/@/.snapshots
mkdir -p /mnt/@/.snapshots/1
btrfs subvolume create /mnt/@/.snapshots/1/snapshot

for vol in home root
do
    btrfs subvolume create /mnt/@/${vol//\//_}
    mkdir -p /mnt/$vol
done

for vol in boot root srv var/log var/crash var/cache var/tmp var/spool var/lib/libvirt/images var/lib/docker cryptkey
do
    btrfs subvolume create /mnt/@/${vol//\//_}
    chattr +C /mnt/@/${vol//\//_}
    mkdir -p /mnt/$vol
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

mount -o ssd,noatime,space_cache,compress=zstd:15 $BTRFS /mnt

for vol in home root boot .snapshots srv
do
    mount -o ssd,noatime,space_cache,autodefrag,compress=zstd:15,discard=async,subvol=@/${vol//\//_} $BTRFS /mnt/$vol
done

for vol in var/log var/crash var/cache var/tmp var/spool var/lib/libvirt/images var/lib/machines cryptkey
do
    mount -o ssd,noatime,space_cache,autodefrag,compress=zstd:15,discard=async,nodatacow,subvol=@/${vol//\//_} $BTRFS /mnt/$vol
done

read -r -p "Please choose the EFI partition: " ESP

mkdir -p /mnt/boot/efi
mount $ESP /mnt/boot/efi