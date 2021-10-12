#!/bin/bash

CONTAINER=  # /dev/vda2 or /dev/sda2

if [ -z "$CONTAINER" ]; then
    read -r -p "Please choose the LUKS partition: " BTRFS
fi

# Configuring /etc/mkinitcpio.conf
sed -i '/HOOKS=(/s/)/ encrypt)/' /mnt/etc/mkinitcpio.conf

# Enabling LUKS in GRUB and setting the UUID of the LUKS container.
UUID="$(blkid $CONTAINER | grep -oP '(?<=UUID=")([^"]+)')"

# Adding keyfile to the initramfs to avoid double password.
dd bs=512 count=4 if=/dev/random of=/mnt/cryptkey/.root.key iflag=fullblock
chmod 000 /mnt/cryptkey/.root.key

cryptsetup -v luksAddKey $CONTAINER /mnt/cryptkey/.root.key

sed -i "/GRUB_CMDLINE_LINUX_DEFAULT=/s,quiet,cryptdevice=UUID=$UUID:cryptroot,g" /mnt/etc/default/grub
sed -i '/GRUB_CMDLINE_LINUX_DEFAULT=/s,"$, cryptkey=rootfs:/cryptkey/.root.key",g' /mnt/etc/default/grub
sed -i 's/#\(GRUB_ENABLE_CRYPTODISK=y\)/\1/' /mnt/etc/default/grub

sed -i 's#FILES=()#FILES=(/cryptkey/.root.key)#g' /mnt/etc/mkinitcpio.conf
