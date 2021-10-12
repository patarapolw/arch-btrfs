#!/bin/zsh -e

BTRFS=  # real partition e.g. /dev/vda2, /dev/sda2, or /dev/mapper/cryptroot
ESP=    # /dev/vda1, /dev/sda1
CFG=${CFG:-"$(git rev-parse --show-toplevel)/config.yaml"}
LABEL=${LABEL:-$(cat $CFG | yq '.mount."/".label')}

if [[ -z "$BTRFS" ]]; then
    exit 1
fi

if [[ -z "$ESP" ]]; then
    exit 1
fi

mkfs.btrfs ${$(cat $CFG | yq '.mount."/".device'):+"-f"} -L "$LABEL" "$BTRFS"
mount "$BTRFS" /mnt

echo "Creating BTRFS subvolumes."

btrfs subvolume create /mnt/@

elem_in() {
    local e m="$1"; shift
    for e in "$@"; do [[ "$m" == "$e" ]] && return 0; done
    return 1
}

for vol in $(cat $CFG | yq '.mount."/".subvolmes.cow[],.mount."/".subvolmes.nocow[]')
do
    btrfs subvolume create "/mnt/@${vol//\//_}"

    if elem_in $vol $(cat $CFG | yq '.mount."/".subvolmes.nocow[]'); then
        chattr +C "/mnt/@${vol//\//_}"
    fi
done

btrfs subvolume create /mnt/@/.snapshots
mkdir -p /mnt/@/.snapshots/1
btrfs subvolume create /mnt/@/.snapshots/1/snapshot
btrfs subvolume set-default "$(btrfs subvolume list /mnt | grep "@/.snapshots/1/snapshot" | grep -oP '(?<=ID )[0-9]+')" /mnt

cat << EOF >> /mnt/@/.snapshots/1/info.xml
<?xml version="1.0"?>
<snapshot>
    <type>single</type>
    <num>1</num>
    <date>1970-01-01 0:00:00</date>
    <description>First Root Filesystem</description>
    <cleanup>number</cleanup>
</snapshot>
EOF

chmod 600 /mnt/@/.snapshots/1/info.xml

umount /mnt

echo "Mounting the newly created subvolumes."

mount -o ssd,noatime,space_cache,compress=zstd:15 "$BTRFS" /mnt

for vol in $(cat $CFG | yq '.mount."/".subvolmes.cow[],.mount."/".subvolmes.nocow[]')
do
    mkdir -p "/mnt/$vol"
    mount -o "ssd,noatime,space_cache,autodefrag,compress=zstd:15,discard=async,subvol=@${vol//\//_}" $BTRFS "/mnt/$vol"
done

mkdir -p /mnt/boot/efi
mount $ESP /mnt/boot/efi
