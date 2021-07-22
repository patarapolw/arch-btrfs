#!/bin/bash
#/usr/bin/arch-chroot /mnt

# Setting up timezone.
ln -sf /usr/share/zoneinfo/$(curl -s http://ip-api.com/line?fields=timezone) /etc/localtime

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

read -r -p "Please choose a bootloader-id: " BOOTLOADER_ID
read -r -p "Please choose target: " TARGET

# # Installing GRUB.
# echo "Installing GRUB on /boot."
# grub-install --target=x86_64-efi --efi-directory=/boot/efi --bootloader-id=$BOOTLOADER_ID --modules="normal test efi_gop efi_uga search echo linux all_video gfxmenu gfxterm_background gfxterm_menu gfxterm loadenv configfile gzio part_gpt cryptodisk luks gcry_rijndael gcry_sha256 btrfs" --disable-shim-lock

# Installing GRUB.
echo "Installing GRUB on /boot."
grub-install --target=x86_64-efi --efi-directory=/boot/efi --bootloader-id=$BOOTLOADER_ID --modules="normal test efi_gop efi_uga search echo linux all_video gfxmenu gfxterm_background gfxterm_menu gfxterm loadenv configfile gzio part_gpt btrfs" --disable-shim-lock $TARGET

# Creating grub config file.
echo "Creating GRUB config file."
grub-mkconfig -o /boot/grub/grub.cfg

# Setting root password.
echo "Setting root password"
passwd

read -r -p "Please choose an admin user to create: " USER

# Create user
echo "Creating user $USER"
useradd -m -g wheel -s /bin/zsh $USER
passwd $USER

echo '%wheel ALL=(ALL) ALL' >> /etc/sudoers
echo 'Defaults lecture=always' >> /etc/sudoers
# echo 'Defaults timestamp_timeout=0' >> /etc/sudoers
visudo -c

sed -i '/Color/s/^#//' /etc/pacman.conf

echo 'set softwrap' >> /etc/nanorc
echo 'include "/usr/share/nano/*.nanorc"' >> /etc/nanorc
