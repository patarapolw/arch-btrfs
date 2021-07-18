#!/bin/bash

# Selecting the kernel flavor to install. 
kernel_selector () {
    echo "List of kernels:"
    echo "1) Stable — Vanilla Linux kernel and modules, with a few patches applied."
    echo "2) Hardened — A security-focused Linux kernel."
    echo "3) Longterm — Long-term support (LTS) Linux kernel and modules."
    echo "4) Zen Kernel — Optimized for desktop usage."
    read -r -p "Insert the number of the corresponding kernel: " choice
    echo "$choice will be installed"
    case $choice in
        1 ) kernel=linux
            ;;
        2 ) kernel=linux-hardened
            ;;
        3 ) kernel=linux-lts
            ;;
        4 ) kernel=linux-zen
            ;;
        * ) echo "You did not enter a valid selection."
            kernel_selector
    esac
}

# Checking the microcode to install.
CPU=$(grep vendor_id /proc/cpuinfo)
if [[ $CPU == *"AuthenticAMD"* ]]
then
    microcode=amd-ucode
else
    microcode=intel-ucode
fi

kernel_selector

# Pacstrap (setting up a base sytem onto the new root).
echo "Installing the base system (it may take a while)."
pacstrap /mnt base base-devel ${kernel} ${kernel}-headers ${microcode} linux-firmware grub grub-btrfs snapper efibootmgr sudo networkmanager apparmor nano firewalld ntfs-3g reiserfsprogs reflector snap-pac snap-sync noto-fonts noto-fonts-cjk noto-fonts-emoji noto-fonts-extra git go

# Generating /etc/fstab.
echo "Generating a new fstab."
genfstab -U /mnt >> /mnt/etc/fstab

sed -i -E '/subvol=\/@\/.snapshots\/1\/snapshot/s/,subvol.+/ 0 0/g' /mnt/etc/fstab

# Setting hostname.
read -r -p "Please enter the hostname: " hostname
echo "$hostname" > /mnt/etc/hostname

# Setting up locales.
read -r -p "Please insert the locale you use in this format (xx_XX): " locale
echo "$locale.UTF-8 UTF-8"  > /mnt/etc/locale.gen
echo "LANG=$locale.UTF-8" > /mnt/etc/locale.conf

# Setting up keyboard layout.
# read -r -p "Please insert the keyboard layout you use: " kblayout
# echo "KEYMAP=$kblayout" > /mnt/etc/vconsole.conf

# Setting hosts file.
echo "Setting hosts file."
cat >> /mnt/etc/hosts <<EOF
127.0.0.1   localhost
::1         localhost
127.0.1.1   $hostname.localdomain   $hostname
EOF

# Configuring /etc/mkinitcpio.conf
echo "Configuring /etc/mkinitcpio for ZSTD compression and LUKS hook."
sed -i '/COMPRESSION="zstd"/s/^#//g' /mnt/etc/mkinitcpio.conf
# sed -i 's,modconf block filesystems keyboard,keyboard modconf block encrypt filesystems,g' /mnt/etc/mkinitcpio.conf

# Enabling LUKS in GRUB and setting the UUID of the LUKS container.
# UUID=$(blkid $cryptroot | cut -f2 -d'"')
# sed -i 's/#\(GRUB_ENABLE_CRYPTODISK=y\)/\1/' /mnt/etc/default/grub

echo "" >> /mnt/etc/default/grub
echo -e "# Booting with BTRFS subvolume\nGRUB_BTRFS_OVERRIDE_BOOT_PARTITION_DETECTION=true" >> /mnt/etc/default/grub

#sed -i 's# part_msdos##g' /mnt/etc/default/grub

# This is required for enabling AppArmor.
sed -i '/GRUB_CMDLINE_LINUX_DEFAULT=/s/"$/ lsm=lockdown,yama,apparmor"/g' /mnt/etc/default/grub

sed -i '/GRUB_DISABLE_RECOVERY=/s/false/true/g' /mnt/etc/default/grub

sed -i 's#rootflags=subvol=${rootsubvol}##g' /mnt/etc/grub.d/10_linux
sed -i 's#rootflags=subvol=${rootsubvol}##g' /mnt/etc/grub.d/20_linux_xen

# # Adding keyfile to the initramfs to avoid double password.
# dd bs=512 count=4 if=/dev/random of=/mnt/cryptkey/.root.key iflag=fullblock
# chmod 000 /mnt/cryptkey/.root.key
# cryptsetup -v luksAddKey /dev/disk/by-partlabel/cryptroot /mnt/cryptkey/.root.key
# sed -i "s#quiet#cryptdevice=UUID=$UUID:cryptroot root=$BTRFS lsm=lockdown,yama,apparmor,bpf cryptkey=rootfs:/cryptkey/.root.key#g" /mnt/etc/default/grub
# sed -i 's#FILES=()#FILES=(/cryptkey/.root.key)#g' /mnt/etc/mkinitcpio.conf

# # Security kernel settings.
# echo "kernel.kptr_restrict = 2" > /mnt/etc/sysctl.d/51-kptr-restrict.conf
# echo "kernel.kexec_load_disabled = 1" > /mnt/etc/sysctl.d/51-kexec-restrict.conf
# cat << EOF >> /mnt/etc/sysctl.d/10-security.conf
# fs.protected_hardlinks = 1
# fs.protected_symlinks = 1
# net.core.bpf_jit_harden = 2
# kernel.yama.ptrace_scope = 3
# kernel.unprivileged_userns_clone = 1
# EOF

# # Randomize Mac Address.
# bash -c 'cat > /mnt/etc/NetworkManager/conf.d/00-macrandomize.conf' <<-'EOF'
# [device]
# wifi.scan-rand-mac-address=yes
# [connection]
# wifi.cloned-mac-address=random
# ethernet.cloned-mac-address=random
# connection.stable-id=${CONNECTION}/${BOOT}
# EOF

# chmod 600 /mnt/etc/NetworkManager/conf.d/00-macrandomize.conf

# # Disable Connectivity Check.
# bash -c 'cat > /mnt/etc/NetworkManager/conf.d/20-connectivity.conf' <<-'EOF'
# [connectivity]
# uri=http://www.archlinux.org/check_network_status.txt
# interval=0
# EOF

# chmod 600 /mnt/etc/NetworkManager/conf.d/20-connectivity.conf
