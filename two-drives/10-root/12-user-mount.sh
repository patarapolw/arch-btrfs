#!/bin/bash -e

USER=polv
STATIC_MOUNT=/media/home

if [ -z "$USER" ]; then
    read -r -p "Please choose an admin user to create: " USER
fi

if [ -z "$STATIC_MOUNT" ]; then
    read -r -p "Please choose static mount: " STATIC_MOUNT
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
    "NextCloud"
    "Projects"
    "vmware"
    "VirtualBox VMs"
)

for vol in "${STATIC_FOLDERS[@]}"
do
    mkdir -p "$STATIC_MOUNT/$vol"
    ln -s "$STATIC_MOUNT/$vol" "$HOME/$vol"
done

# chown -R $USER $STATIC_MOUNT 2>/dev/null
