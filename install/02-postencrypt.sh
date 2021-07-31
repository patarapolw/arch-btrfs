#!/bin/bash

exit 1

cryptroot=
BTRFS=

# Configuring /etc/mkinitcpio.conf
sed -i '/HOOKS=(/s/)/ encrypt)/' /mnt/etc/mkinitcpio.conf

# Enabling LUKS in GRUB and setting the UUID of the LUKS container.
exit 1  # TODO:
UUID=$(blkid $cryptroot | cut -f2 -d'"')

# Adding keyfile to the initramfs to avoid double password.
dd bs=512 count=4 if=/dev/random of=/mnt/cryptkey/.root.key iflag=fullblock
chmod 000 /mnt/cryptkey/.root.key

exit 1  # TODO:
cryptsetup -v luksAddKey /dev/disk/by-partlabel/cryptroot /mnt/cryptkey/.root.key

exit 1  # TODO:
sed -i "/GRUB_CMDLINE_LINUX_DEFAULT=/s/quiet/quiet cryptdevice=UUID=$UUID:cryptroot root=$BTRFS/g" /mnt/etc/default/grub
sed -i '/GRUB_CMDLINE_LINUX_DEFAULT=/s/"$/ cryptkey=rootfs:/cryptkey/.root.key"/g' /mnt/etc/default/grub
sed -i 's/#\(GRUB_ENABLE_CRYPTODISK=y\)/\1/' /mnt/etc/default/grub

sed -i 's#FILES=()#FILES=(/cryptkey/.root.key)#g' /mnt/etc/mkinitcpio.conf
