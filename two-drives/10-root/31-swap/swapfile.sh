#!/bin/bash -e

MEMSIZE=$(awk '/^Mem/ {print $2}' <(free -m))
if [ "$MEMSIZE" -ge "8192" ]; then
    RAMSIZE=8192
else
    RAMSIZE="$MEMSIZE"
fi

cd /.swap
truncate -s 0 ./swapfile
chattr +C ./swapfile
btrfs property set ./swapfile compression none

dd if=/dev/zero of=/.swap/swapfile bs=1M count=$RAMSIZE status=progress
chmod 600 ./swapfile
mkswap ./swapfile
swapon ./swapfile

printf '\n/.swap/swapfile\tnone\tswap\tdefaults\t0\t0\n' >> /etc/fstab
mount -a
