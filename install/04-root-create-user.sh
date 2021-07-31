#!/bin/bash

# USER=

if [ ! -z "$USER" ]; then
    read -r -p "Please choose an admin user to create: " USER
fi

# Create user
useradd -m -g wheel -s /bin/zsh $USER
passwd $USER

# If you plan to use `snapper -c home create-config /home`, consider adding these.
# - $HOME/.cache
# - $HOME/.var
# - $HOME/Downloads
# - $HOME/.local/share/Steam
# - $HOME/.local/share/containers
# - $HOME/.local/share/Trash
#
# As for how to rollback, see https://github.com/openSUSE/snapper/issues/664
#
NOSNAPSHOT_PATHS=(".cache", ".var", ".local/share/Steam", ".local/share/containers", ".local/share/Trash")

for vol in $NOSNAPSHOT_PATHS
do
    vol=home/$USER/$vol
    mkdir -p /$vol
    mount -o ssd,noatime,space_cache,autodefrag,compress=zstd:15,discard=async,nodatacow,subvol=@/${vol//\//_} $BTRFS /$vol
done

mount -a
