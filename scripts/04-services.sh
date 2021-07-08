#!/bin/bash

# Enabling auto-trimming service.
systemctl enable fstrim.timer --root=/mnt

# Enabling NetworkManager service.
echo "Enabling NetworkManager"
systemctl enable NetworkManager --root=/mnt

# Enabling AppArmor.
echo "Enabling AppArmor."
systemctl enable apparmor --root=/mnt

# Enabling Firewalld.
echo "Enabling Firewalld."
systemctl enable firewalld --root=/mnt

# Enabling Bluetooth Service (If you don't want bluetooth, disable it with GNOME, don't disable the service).
# systemctl enable bluetooth --root=/mnt

# Enabling Reflector timer.
echo "Enabling Reflector."
systemctl enable reflector.timer --root=/mnt

# Enabling Snapper automatic snapshots.
echo "Enabling Snapper and automatic snapshots entries."
systemctl enable snapper-timeline.timer --root=/mnt
systemctl enable snapper-cleanup.timer --root=/mnt
systemctl enable grub-btrfs.path --root=/mnt

# # Setting umask to 077.
# sed -i 's/022/077/g' /mnt/etc/profile
# echo "" >> /mnt/etc/bash.bashrc
# echo "umask 077" >> /mnt/etc/bash.bashrc

# #Blacklist Firewire SBP2.
# echo "blacklist firewire-sbp2" | sudo tee /mnt/etc/modprobe.d/blacklist.conf
