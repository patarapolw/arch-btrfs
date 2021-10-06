#!/bin/bash -e

TZ=                 # Asia/Bangkok for me. You can search with tab completion in /usr/share/zoneinfo
# IS_ENCRYPT=1      # If you need encryption modules to be installed for GRUB

if [ -z "$TZ" ]; then
    TZ="$(curl -s http://ip-api.com/line?fields=timezone)"
fi

# Setting up timezone.
ln -sf "/usr/share/zoneinfo/$TZ" /etc/localtime

# Setting up clock.
hwclock --systohc

# Generating locales.
echo "Generating locales."
locale-gen

# Generating a new initramfs.
echo "Creating a new initramfs."
chmod 600 /boot/initramfs-linux*
mkinitcpio -P

snapper --no-dbus -c root create-config /
snapper --no-dbus -c home create-config /home

# Setting root password.
echo "Setting root password"
passwd

echo '%wheel ALL=(ALL) ALL' >> /etc/sudoers
echo 'Defaults lecture=always' >> /etc/sudoers
echo 'Defaults timestamp_timeout=1' >> /etc/sudoers
visudo -c

sed -i '/Color/s/^#//' /etc/pacman.conf

echo 'set linenumbers' >> /etc/nanorc
echo 'set softwrap' >> /etc/nanorc
echo 'include "/usr/share/nano/*.nanorc"' >> /etc/nanorc
