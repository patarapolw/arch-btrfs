#!/bin/bash

fdisk -l

read -r -p "Please choose the partition name: " PART
parted $PART -- mklabel gpt

parted $PART -- mkpart ESP fat32 1MiB 512MiB
parted $PART -- mkpart primary 512MiB 100%

lsblk

read -r -p "Please choose the partition to format to EFI partition: " EFI
mkfs.vfat $EFI
