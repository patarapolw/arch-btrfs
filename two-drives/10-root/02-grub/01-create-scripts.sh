#!/bin/bash -e

GRUB_INST=/usr/local/bin/grub-install.sh
GRUB_UPDATE=/usr/local/bin/grub-update.sh

BOOTLOADER_ID=ARCH
BOOT_TARGET=

if [ -z "$BOOT_TARGET" ]; then
    read -r -p "Please enter the boot target: " BOOT_TARGET
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

/usr/bin/grub-mkconfig -o /boot/grub/grub.cfg
EOF

chmod +x $GRUB_UPDATE

#####
