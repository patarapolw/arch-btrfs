#!/bin/bash

TZ=                 # Asia/Bangkok for me. You can search with tab completion in /usr/share/zoneinfo
BOOTLOADER_ID=ARCH
BOOT_TARGET=        # /dev/sda or /dev/sda
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

# Snapper configuration
umount /.snapshots
rm -r /.snapshots
snapper --no-dbus -c root create-config /
snapper --no-dbus -c home create-config /home
btrfs subvolume delete /.snapshots
mkdir /.snapshots
mount -a
chmod 750 /.snapshots

if [ -z "$BOOTLOADER_ID" ]; then
    read -r -p "Please choose a bootloader-id: " BOOTLOADER_ID
fi

if [ -z "$BOOT_TARGET" ]; then
    read -r -p "Please choose target: " BOOT_TARGET
fi

# Installing GRUB.
echo "Installing GRUB on /boot."

GRUB_MODULES="normal test efi_gop efi_uga search echo linux all_video gfxmenu gfxterm_background gfxterm_menu gfxterm loadenv configfile gzio part_gpt btrfs"

if [ IS_ENCRYPT = "1" ]; then
    grub-install --target=x86_64-efi --efi-directory=/boot/efi --bootloader-id="$BOOTLOADER_ID" --modules="${GRUB_MODULES// btrfs$/ cryptodisk luks gcry_rijndael gcry_sha256 btrfs}" --disable-shim-lock "$BOOT_TARGET"
else
    grub-install --target=x86_64-efi --efi-directory=/boot/efi --bootloader-id="$BOOTLOADER_ID" --modules="$GRUB_MODULES" --disable-shim-lock "$BOOT_TARGET"
fi

# Creating grub config file.
echo "Creating GRUB config file."
grub-mkconfig -o /boot/grub/grub.cfg

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
