#!/bin/bash -e

MEMSIZE=$(awk '/^Mem/ {print $2}' <(free -m))
if [ "$MEMSIZE" -ge "8192" ]; then
    RAMSIZE=8192
else
    RAMSIZE="$MEMSIZE"
fi

echo 'zram' > /etc/modules-load.d/zram.conf
echo 'options zram num_devices=1' > /etc/modprobe.d/zram.conf
echo 'KERNEL=="zram0", ATTR{disksize}="'"$RAMSIZE"'" RUN="/usr/bin/mkswap /dev/zram0", TAG+="systemd"' >/etc/udev/rules.d/99-zram.rules
printf '\n/dev/zram0\tnone\tswap\tdefaults\t0\t0\n' >> /etc/fstab
mount -a

# If it doesn't work, try Swapfile creation
