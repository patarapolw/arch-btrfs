#!/bin/bash
#/usr/bin/arch-chroot /mnt

# Enabling auto-trimming service.
systemctl enable fstrim.timer

# Enabling NetworkManager service.
echo "Enabling NetworkManager"
systemctl enable NetworkManager

# Enabling AppArmor.
echo "Enabling AppArmor."
systemctl enable apparmor

# Enabling Firewalld.
echo "Enabling Firewalld."
systemctl enable firewalld

# Enabling Bluetooth Service (If you don't want bluetooth, disable it with GNOME, don't disable the service).
# systemctl enable bluetooth

# Enabling Reflector timer.
echo "Enabling Reflector."
systemctl enable reflector.timer

# Enabling Snapper automatic snapshots.
echo "Enabling Snapper and automatic snapshots entries."
systemctl enable snapper-timeline.timer
systemctl enable snapper-cleanup.timer
systemctl enable grub-btrfs.path

# # Setting umask to 077.
# sed -i 's/022/077/g' /etc/profile
# echo "" >> /etc/bash.bashrc
# echo "umask 077" >> /etc/bash.bashrc

#Blacklist Firewire SBP2.
echo "blacklist firewire-sbp2" | sudo tee /etc/modprobe.d/blacklist.conf
