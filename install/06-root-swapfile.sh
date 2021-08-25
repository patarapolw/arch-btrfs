#!/bin/bash

MEMSIZE=$(awk '/^Mem/ {print $2}' <(free -m))
if [ "$MEMSIZE" -ge "8192" ]; then
    ZRAMSIZE=8192
else 
    ZRAMSIZE="$MEMSIZE"
fi

cd /.swap
truncate -s 0 ./swapfile
chattr +C ./swapfile
btrfs property set ./swapfile compression none

dd if=/dev/zero of=/.swap/swapfile bs=1M count=$MEMSIZE status=progress
chmod 600 ./swapfile
mkswap ./swapfile
swapon ./swapfile

printf '\n/.swap/swapfile\tnone\tswap\tdefaults\t0\t0\n' >> /etc/fstab
mount -a
