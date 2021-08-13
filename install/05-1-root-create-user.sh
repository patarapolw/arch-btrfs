#!/bin/bash

USER=polv
BTRFS=/dev/sda5

if [ -z "$USER" ]; then
    read -r -p "Please choose an admin user to create: " USER
fi

UUID=$(blkid $BTRFS | grep -oP '(?<=UUID=")([^"]+)' | head -n 1)

# Create user
useradd -m -g wheel -s /bin/zsh $USER
passwd $USER

# If you plan to use `snapper -c home create-config /home`, consider adding these.
# - $HOME/.cache
# - $HOME/.var
# - $HOME/Downloads
# - $HOME/.local/share/Steam
# - $HOME/.local/share/containers
#
# As for how to rollback, see https://github.com/openSUSE/snapper/issues/664
#
NOSNAPSHOT_PATHS=(".cache" ".var" ".local/share/Steam" ".local/share/containers")
mount $BTRFS -o subvolid=5 /mnt

for vol in ${NOSNAPSHOT_PATHS[*]}
do
    vol=home/$USER/$vol
    mnt=${vol//\//_}
    mkdir -p /$vol
    chown $USER /$vol
    btrfs sub cr /mnt/@/$mnt
    chattr +C /mnt/@/$mnt
    chown $USER /mnt/@/$mnt
    echo "UUID=$UUID /$vol btrfs rw,noatime,compress=zstd:15,ssd,space_cache,subvolid=$(btrfs sub list / | grep "@/$mnt" | grep -oP '(?<=ID )[0-9]+'),subvol=/@/$mnt,discard=async,nodatacow 0 0" >> /etc/fstab
done

umount /mnt
mount -a
