#!/bin/bash -e

ROOT=$(git rev-parse --show-toplevel)
SQUASHFS=/tmp/arch-btrfs.squashfs
MOUNT_POINT=/tmp/mnt

export CFG="$ROOT/config.yaml"

mkdir -p $MOUNT_POINT
STATE_FILE="$MOUNT_POINT/.history"

touch $STATE_FILE

if [[ ! -f $SQUASHFS ]]; then
    mksquashfs $ROOT $SQUASHFS
    mount $SQUASHFS $MOUNT_POINT -t squashfs -o loop
fi

cd $MOUNT_POINT

if [[ "$(stat -c %d:%i /)" == "$(stat -c %d:%i /proc/1/root/.)" ]]; then
    if ! grep -qFx 'format' $STATE_FILE; then
        if yq -r '.mount."/boot/efi".format' $CFG; then
            mkfs.vfat $(yq -r '.mount."/boot/efi".device' $CFG)
            echo 'lib/01-format/01-format-esp.sh' >> $STATE_FILE
        fi

        ./lib/01-format/01-format-arch.sh
        echo 'lib/01-format/01-format-arch.sh' >> $STATE_FILE

        if yq -r '.mount."/home".device' $CFG; then
            ./lib/01-format/02-format-home.sh
            echo 'lib/01-format/02-format-home.sh' >> $STATE_FILE
        fi

        echo 'format' >> $STATE_FILE
    fi

    if ! grep -qFx 'pacstrap' $STATE_FILE; then
        ./lib/02-pacstrap/01-pacstrap.sh
        echo 'pacstrap' >> $STATE_FILE
    fi

    if ! grep -qFx 'pacstrap-security' $STATE_FILE; then
        ./lib/02-pacstrap/02-security.sh
        echo 'pacstrap-security' >> $STATE_FILE
    fi

    mkdir -p "/mnt/$MOUNT_POINT"

    echo "Please `cd /$MOUNT_POINT && ./install.sh` to continue"

    arch-chroot /mnt mkdir -p $(dirname /mnt/$SQUASHFS)
    arch-chroot /mnt cp $SQUASHFS /mnt/$SQUASHFS
    arch-chroot /mnt mount $SQUASHFS $MOUNT_POINT -t squashfs -o loop
    arch-chroot /mnt
elif [[ $(whoami) == "root" ]]; then
    if ! grep -qFx 'root-init' $STATE_FILE; then
        ./lib/10-root/01-init.sh
        echo 'root-init' >> $STATE_FILE
    fi

    if ! grep -qFx 'bootloader' $STATE_FILE; then
        ./lib/10-root/02-grub/00-edit.sh
        ./lib/10-root/02-grub/01-create-scripts.sh
        ./lib/10-root/02-grub/02-install.sh

        if yq -r '.bootloader.refind' $CFG; then
            refind-install
        fi

        echo 'bootloader' >> $STATE_FILE
    fi

    if ! grep -qFx 'user-create' $STATE_FILE; then
        ./lib/10-root/10-user-create.sh
        echo 'user-create' >> $STATE_FILE
    fi

    if ! grep -qFx 'user-subvol' $STATE_FILE; then
        ./lib/10-root/11-user-subvol.sh
        echo 'user-subvol' >> $STATE_FILE
    fi

    if ! grep -qFx 'user-mount' $STATE_FILE; then
        ./lib/10-root/12-user-mount.sh
        echo 'user-mount' >> $STATE_FILE
    fi

    if ! grep -qFx 'user-symlink' $STATE_FILE; then
        ./lib/10-root/13-user-symlink.sh
        echo 'user-symlink' >> $STATE_FILE
    fi
fi
