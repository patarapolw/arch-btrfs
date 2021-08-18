#!/bin/bash

echo 'zram' > /etc/modules-load.d/zram.conf
echo 'options zram num_devices=1' > /etc/modprobe.d/zram.conf
echo 'KERNEL=="zram0", ATTR{disksize}="8192M" RUN="/usr/bin/mkswap /dev/zram0", TAG+="systemd"' >/etc/udev/rules.d/99-zram.rules
printf '/dev/zram0\tnone\tswap\tdefaults\t0\t0\n' >> /etc/fstab
mount -a
