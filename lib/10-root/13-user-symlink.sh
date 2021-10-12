#!/bin/bash -e

USER=$(yq -r '.users | to_entries | .[].key | select(. != "root")' $CFG | head -n1 | envsubst)
STATIC_MOUNT=/media/HOME

if [[ -z "$USER" ]]; then
    exit 1
fi

if [[ -z "$STATIC_MOUNT" ]]; then
    exit 1
fi

STATIC_FOLDERS=(
    # Standard folders
    "Desktop"
    "Documents"
    "Downloads"
    "Music"
    "Pictures"
    "Public"
    "Videos"

    # Additional folders
    "Nextcloud"
    "Projects"
    "vmware"
    "VirtualBox VMs"
)

mkdir -p /home/$USER

for vol in "${STATIC_FOLDERS[@]}"
do
    mkdir -p "$STATIC_MOUNT/$vol"
    rm -r "$HOME/$vol"
    ln -s "$STATIC_MOUNT/$vol" /home/$USER
done

chown -R $USER $STATIC_MOUNT/* 2>/dev/null
chown -R root $STATIC_MOUNT/@/.snapshot
