#!/bin/bash

kernel=         # linux, linux-zen, linux-hardened; for example
microcode=      # amd-ucode or intel-ucode
hostname=       # any random makeup names
# locale=en_US  # uncomment this, if you want en_US; or en_GB is nice for metric units
kblayout=       # Can be omitted
# LC_MONETARY=  # "en_US.UTF-8 UTF-8"   # Override en_GB to en_US here, for US dollar

if [ -z "$hostname" ]; then
    read -r -p "Please enter the hostname: " hostname
fi

if [ -z "$locale" ]; then
    read -r -p "Please insert the locale you use in this format (xx_XX): " locale
fi


if [ -z "$microcode" ]; then
    # Checking the microcode to install.
    CPU=$(grep vendor_id /proc/cpuinfo)
    if [[ $CPU == *"AuthenticAMD"* ]]
    then
        microcode=amd-ucode
    else
        microcode=intel-ucode
    fi
fi

if [ -z "$kernel" ]; then
    # Selecting the kernel flavor to install. 
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
fi

# Optional. Pacman mirror fixing
# reflect --latest 5 --sort rate --save /etc/pacman.d/mirrorlist

# Pacstrap (setting up a base sytem onto the new root).
echo "Installing the base system (it may take a while)."
pacstrap /mnt base base-devel "${kernel}" "${kernel}-firmware" "${microcode}" refind grub grub-btrfs snapper efibootmgr sudo networkmanager apparmor nano firewalld ntfs-3g reflector snap-pac noto-fonts noto-fonts-cjk noto-fonts-emoji noto-fonts-extra git rsync zsh zsh-completions

# Generating /etc/fstab.
echo "Generating a new fstab."
genfstab -U /mnt >> /mnt/etc/fstab
mount -a /mnt

# Setting hostname.
echo "$hostname" >> /mnt/etc/hostname

# Setting hosts file.
echo "Setting hosts file."
cat >> /mnt/etc/hosts <<EOF
127.0.0.1   localhost
::1         localhost
127.0.1.1   $hostname.localdomain   $hostname
EOF

# Setting up locales.
echo "$locale.UTF-8 UTF-8"  >> /mnt/etc/locale.gen
echo "LANG=$locale.UTF-8" >> /mnt/etc/locale.conf

if [ ! -z "$LC_MONETARY" ]; then
    echo "$LC_MONETARY"  >> /mnt/etc/locale.gen
    echo "LC_MONETARY=${LC_MONETARY// .*$//}" >> /mnt/etc/locale.conf
fi

if [ ! -z "$kblayout" ]; then
    echo "KEYMAP=$kblayout" > /mnt/etc/vconsole.conf
fi

# Configuring /etc/mkinitcpio.conf
sed -i '/COMPRESSION="zstd"/s/^#//g' /mnt/etc/mkinitcpio.conf

# Blacklisting kernel modules
curl https://raw.githubusercontent.com/Whonix/security-misc/master/etc/modprobe.d/30_security-misc.conf >> /mnt/etc/modprobe.d/30_security-misc.conf
chmod 600 /mnt/etc/modprobe.d/*

# Security kernel settings.
curl https://raw.githubusercontent.com/Whonix/security-misc/master/etc/sysctl.d/30_security-misc.conf >> /mnt/etc/sysctl.d/30_security-misc.conf
sed -i 's/kernel.yama.ptrace_scope=2/kernel.yama.ptrace_scope=3/g' /mnt/etc/sysctl.d/30_security-misc.conf
curl https://raw.githubusercontent.com/Whonix/security-misc/master/etc/sysctl.d/30_silent-kernel-printk.conf >> /mnt/etc/sysctl.d/30_silent-kernel-printk.conf
chmod 600 /mnt/etc/sysctl.d/*

# IO udev rules
curl https://gitlab.com/garuda-linux/themes-and-settings/settings/garuda-common-settings/-/raw/master/etc/udev/rules.d/50-sata.rules > /mnt/etc/udev/rules.d/50-sata.rules
curl https://gitlab.com/garuda-linux/themes-and-settings/settings/garuda-common-settings/-/raw/master/etc/udev/rules.d/60-ioschedulers.rules > /etc/udev/rules.d/60-ioschedulers.rules
chmod 600 /mnt/etc/udev/rules.d/*

# Randomize Mac Address.
bash -c 'cat > /mnt/etc/NetworkManager/conf.d/00-macrandomize.conf' <<-'EOF'
[device]
wifi.scan-rand-mac-address=yes
[connection]
wifi.cloned-mac-address=random
ethernet.cloned-mac-address=random
connection.stable-id=${CONNECTION}/${BOOT}
EOF

chmod 600 /mnt/etc/NetworkManager/conf.d/00-macrandomize.conf

# Disable Connectivity Check.
bash -c 'cat > /mnt/etc/NetworkManager/conf.d/20-connectivity.conf' <<-'EOF'
[connectivity]
uri=http://www.archlinux.org/check_network_status.txt
interval=0
EOF

chmod 600 /mnt/etc/NetworkManager/conf.d/20-connectivity.conf
