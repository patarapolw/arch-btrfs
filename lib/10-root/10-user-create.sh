#!/bin/bash -e

CFG="$(git rev-parse --show-toplevel)/config.yaml"
USER=$(yq -r '.users | to_entries | .[].key | select(. != "root")' $CFG | head -n1 | envsubst)

if [[ -z "$USER" ]]; then
    exit 1
fi

# Create user
useradd -m -g wheel -s /bin/zsh "$USER"
passwd "$USER"
