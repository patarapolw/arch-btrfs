#!/bin/zsh -e

ROOT=$(git rev-parse --show-toplevel)
SQUASHFS=/tmp/arch-btrfs.squashfs
MOUNT_POINT=/tmp/mnt

export CFG=config.yaml

mkdir -p $MOUNT_POINT
STATE_FILE=$MOUNT_POINT/.history

if [[ ! -f $STATE_FILE ]]; then
    mksquashfs $ROOT $SQUASHFS
    mount $SQUASHFS $MOUNT_POINT -t squashfs -o loop

    echo 'init' > $STATE_FILE
fi

cd $MOUNT_POINT

export BTRFS=$(cat config.yaml | yq '.mount."/".device')
export ESP=$(cat config.yaml | yq '.mount."/boot/efi".device')

if [[ $(tail -n1 $STATE_FILE) == 'init' ]]; then
    if $(cat config.yaml | yq '.mount."/boot/efi".format'); then
        mkfs.vfat $ESP
        echo 'lib/01-format/01-format-esp.sh' >> $STATE_FILE
    fi

    ./lib/01-format/01-format-arch.sh
    echo 'lib/01-format/01-format-arch.sh' >> $STATE_FILE

    if $(cat config.yaml | yq '.mount."/home".device'); then
        ./lib/01-format/02-format-home.sh
        echo 'lib/01-format/02-format-home.sh' >> $STATE_FILE
    fi

    echo '01-format' >> $STATE_FILE
fi

if [[ $(tail -n1 $STATE_FILE) == '01-format' ]]; then
fi
