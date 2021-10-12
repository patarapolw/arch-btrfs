#!/bin/bash -e

CFG="$(git rev-parse --show-toplevel)/config.yaml"

kernel=$(yq '.config.kernel' $CFG)          # linux, linux-zen, linux-hardened; for example
microcode=$(yq '.config.microcode' $CFG)    # amd-ucode or intel-ucode
hostname=$(yq '.config.hostname' $CFG)      # any random makeup names
locale=$(yq '.config.locale' $CFG)          # uncomment this, if you want en_US; or en_GB is nice for metric units
kblayout=$(yq '.config.kblayout' $CFG)      # Can be omitted

if [ -z "$hostname" ]; then
    exit 1
fi

if [ -z "$locale" ]; then
    exit 1
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
    exit 1
fi

# Optional. Pacman mirror fixing
# reflect --latest 5 --sort rate --save /etc/pacman.d/mirrorlist

# Pacstrap (setting up a base sytem onto the new root).
echo "Installing the base system (it may take a while)."

PKGS=(
    base
    base-devel
    "${kernel}"
    "${kernel}-firmware"
    "${microcode}"

    # Bootloader
    grub
    grub-btrfs
    efibootmgr

    snapper
    sudo
    networkmanager
    apparmor
    nano
    firewalld

    reflector
    snap-pac
    git
    rsync

    # Shell
    zsh
    zsh-completions

    # Fonts
    noto-fonts
    noto-fonts-cjk
    noto-fonts-emoji
    noto-fonts-extra

    # Probably not needed in the future Linux >=5.15
    # ntfs-3g
)

pacstrap /mnt "${PKGS[@]}"

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
echo "Setting locale files."
cat <<EOF | uniq >> /mnt/etc/locale.gen
$locale.UTF-8 UTF-8
$(cat $CFG | yq -r '.config.LC | to_entries | .[].value | select(.))
EOF

echo "LANG=$locale.UTF-8" >> /mnt/etc/locale.conf
echo $(cat $CFG | yq -r '.config.LC | to_entries | .[] | select(.value) | .value = (.value | split(" ") | .[0]) | .key + "=" + .value') >> /mnt/etc/locale.conf

if [ ! -z "$kblayout" ]; then
    echo "KEYMAP=$kblayout" > /mnt/etc/vconsole.conf
fi

# Configuring /etc/mkinitcpio.conf
sed -i '/COMPRESSION="zstd"/s/^#//g' /mnt/etc/mkinitcpio.conf
