After rebooting into the OS, please test

```sh
sudo snapper rollback
sudo reboot
sudo snapper list
sudo snapper rollback $n
```

About the Swap, I am currently testing [ZRAM](https://wiki.archlinux.org/title/Improving_performance#zram_or_zswap).

```sh
echo 'zram' > /etc/modules-load.d/zram.conf
echo 'options zram num_devices=1' > /etc/modprobe.d/zram.conf
echo 'KERNEL=="zram0", ATTR{disksize}="8192M" RUN="/usr/bin/mkswap /dev/zram0", TAG+="systemd"' > /etc/udev/rules.d/99-zram.rules
echo '/dev/zram0 none swap defaults 0 0' >> /etc/fstab
mount -a
```
