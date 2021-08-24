#!/bin/bash

# TODO: doesn't revert to Secure Boot Enabled on my machine.
exit 1

GRUB_INST=/usr/local/bin/my-grub-install.sh
GRUB_UPDATE=/usr/local/bin/my-grub-update.sh

BOOTLOADER_ID=ARCH
BOOT_TARGET=/dev/nvme0n1
# IS_ENCRYPT=1

if [ ! -z $USER ] && [ $USER != "root" ]; then
    exit 1
fi

if [ -z "$(bootctl status | grep 'Setup Mode: setup')" ]; then
    exit 1
fi

#####
# GRUB_INST CREATOR

cat << EOF > $GRUB_INST
#!/bin/bash
grub-install --target=x86_64-efi --efi-directory=/boot/efi --bootloader-id=$BOOTLOADER_ID --modules="normal test efi_gop efi_uga search echo linux all_video gfxmenu gfxterm_background gfxterm_menu gfxterm loadenv configfile tpm gzio part_gpt btrfs" --disable-shim-lock $BOOT_TARGET
EOF

if [ "$IS_ENCRYPT" = "1" ]; then
    sed -i '/grub-install /s,btrfs",cryptodisk luks gcry_rijndael gcry_sha256 btrfs",' $GRUB_INST
fi

chmod +x $GRUB_INST

#####

#####
# GRUB_UPDATE CREATOR

cat << EOF > $GRUB_UPDATE
#!/bin/bash
/usr/bin/sbsign --key /etc/efi-keys/DB.key --cert /etc/efi-keys/DB.crt --output /boot/efi/EFI/$BOOTLOADER_ID/grubx64.efi /boot/efi/EFI/$BOOTLOADER_ID/grubx64.efi
/usr/bin/grub-mkconfig -o /boot/grub/grub.cfg
EOF

chmod +x $GRUB_UPDATE

#####

rm -rf /etc/pacman.d/hooks
rm -rf /usr/local/share/libalpm/scripts
rm -rf /etc/efi-keys
rm -rf /etc/secureboot/keys/{db,dbx,KEK,PK}

pacman -S --needed sbsigntools efitools openssl

mkdir -p /etc/pacman.d/hooks
mkdir -p /usr/local/share/libalpm/scripts
mkdir -p /etc/efi-keys
mkdir -p /etc/secureboot/keys/{db,dbx,KEK,PK}

# chattr +C /etc/efi-keys
# chattr +C /etc/secureboot/keys/{db,dbx,KEK,PK}

cd /etc/efi-keys
curl -L -O https://www.rodsbooks.com/efi-bootloaders/mkkeys.sh
chmod +x mkkeys.sh
./mkkeys.sh

chmod -R g-rwx /etc/efi-keys
chmod -R o-rwx /etc/efi-keys

for vmlinuz in $(find /boot -name 'vmlinuz-linux*')
do
    sbsign --key DB.key --cert DB.crt --output $vmlinuz $vmlinuz
done

cp /usr/share/libalpm/hooks/90-mkinitcpio-install.hook /etc/pacman.d/hooks/90-mkinitcpio-install.hook
sed -i 's#Exec = /usr/share/libalpm/scripts/mkinitcpio-install#Exec = /usr/local/share/libalpm/scripts/mkinitcpio-install#g' /etc/pacman.d/hooks/90-mkinitcpio-install.hook

cp /usr/share/libalpm/scripts/mkinitcpio-install /usr/local/share/libalpm/scripts/mkinitcpio-install
sed -i 's#install -Dm644 "${line}" "/boot/vmlinuz-${pkgbase}"#sbsign --key /etc/efi-keys/DB.key --cert /etc/efi-keys/DB.crt --output "/boot/vmlinuz-${pkgbase}" "${line}"#g' /usr/local/share/libalpm/scripts/mkinitcpio-install

ln -s /etc/efi-keys/DB.auth /etc/secureboot/keys/db/DB.auth
ln -s /etc/efi-keys/KEK.auth /etc/secureboot/keys/KEK/KEK.auth
ln -s /etc/efi-keys/PK.auth /etc/secureboot/keys/PK/PK.auth

chattr -i /sys/firmware/efi/efivars/{PK,KEK,db}*
sbkeysync --verbose --pk

# If sbkeysync does not work, see https://www.reddit.com/r/archlinux/comments/m8bmpc/struggling_to_get_secure_boot_working/
# chattr -i /sys/firmware/efi/efivars/{PK,KEK,db}*
# efi-updatevar -e -f KEK.esl KEK
# efi-updatevar -e -f DB.esl db
# efi-updatevar -f PK.auth PK

chmod -R g-rwx /etc/secureboot
chmod -R o-rwx /etc/secureboot

$GRUB_UPDATE

cat << EOF > /etc/pacman.d/hooks/grub-secureboot.hook
[Trigger]
Operation=Install
Operation=Upgrade
Type=Package
Target=grub

[Action]
Description=Update grubx64.efi
Depends=grub
When=PostTransaction
NeedsTargets
Exec=/bin/bash $GRUB_UPDATE
EOF

chmod 600 /etc/pacman.d/hooks/*
