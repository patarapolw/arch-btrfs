#!/bin/bash -e

echo "" >> /etc/default/grub
echo -e "# Booting with BTRFS subvolume\nGRUB_BTRFS_OVERRIDE_BOOT_PARTITION_DETECTION=true" >> /etc/default/grub

sed -i '/GRUB_CMDLINE_LINUX_DEFAULT=/s/"$/ lsm=lockdown,yama,apparmor,bpf"/g' /etc/default/grub
sed -i '/GRUB_DISABLE_RECOVERY=/s/false/true/g' /etc/default/grub

sed -i 's#rootflags=subvol=${rootsubvol}##g' /etc/grub.d/10_linux
sed -i 's#rootflags=subvol=${rootsubvol}##g' /etc/grub.d/20_linux_xen
