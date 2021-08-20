# Arch Linux BTRFS installation and utility scripts

## Introduction

This is my fork of [Arch-Setup-Script](https://github.com/tommytran732/Arch-Setup-Script), a collection of **scripts** made in order to boostrap a basic **Arch Linux** environment with **automated snapshots** with Snapper, recommended **security** measures, and optional **encryption** with LUKS.

This fork focuses on editing, in order to create a system that suits your needs. (Feel free to fork and edit the repo; before cloning to the installation media.)

Furthermore, I added some common [utility scripts](/utils/).

## How does it work?

1. Download an Arch Linux ISO from [here](https://archlinux.org/download/)
2. Flash the ISO onto an [USB Flash Drive](https://wiki.archlinux.org/index.php/USB_flash_installation_medium).
3. Boot the live environment.
4. Connect to the internet. (You may need to `rfkill unblock wifi` or `rfkill unblock all`.)
5. `pacman -Syy git && git clone --depth=1 https://github.com/patarapolw/arch-btrfs/`
   - If `pacman` mirrors are dead, run `man reflector`, and type the first example (probably `reflect --latest 5 --sort rate --save /etc/pacman.d/mirrorlist`)
6. `cd arch-btrfs/install && ls`
7. Run the `*.sh` one by one, according to your needs.
8. You may have to `git clone` again, after `arch-chroot`.

## Snapper behavior

The partition layout I use allows us to replicate the behavior found in openSUSE 🦎

1. Snapper rollback <number> works! You will no longer need to manually rollback from a live USB like you would with the @ and @home layout suggested in the Arch Wiki.
2. You can boot into a readonly snapshot! `display-manager`, `NetworkManager` and other services will start normally so you can get in and verify that everything works before rolling back.
3. Automatic snapshots on pacman install/update operations
4. Directories such as /boot, /boot/efi, /var/log, /var/crash, /var/tmp, /var/spool, /var/lib/libvirt/images, /var/lib/docker are excluded from the snapshots as they either should be persistent or are just temporary files. /cryptkey is excluded as we do not want the encryption key to be included in the snapshots, which could be sent to another device as a backup.
5. GRUB will boot into the default BTRFS snapshot set by snapper. Like on OpenSUSE, your running system will always be a read-write snapshot in @/.snapshots/X/snapshot. 

## Changes to the original project

1. Separated scripts. Aimed to be editable and customizable.
2. Encryption is optional. Simply skip `./install/*-encrypt.sh`
3. Desktop environment by your choice.
   - Tested:
     - GNOME
     - KDE Plasma
     - LXQt
     - MATE
     - Cinnamon
     - XFCE
4. Home folder snapshots. However, this is experimental and might not be perfect. As well as, you cannot rollback home folder directly. (See https://github.com/openSUSE/snapper/issues/664)
5.  Post-installation utilities and how-tos.

### Partitions layout 

| Partition/Subvolume | Label                        | Mountpoint               | Notes                       |
|---------------------|------------------------------|--------------------------|-----------------------------|
| 1                   | ESP                          | /boot/efi                | Unencrypted FAT32           |
| 2                   | @/.snapshots/X/snapshot      | /                        | Encrypted BTRFS             |
| 3                   | @/boot                       | /boot/                   | Encrypted BTRFS             |
| 4                   | @/root                       | /root                    | Encrypted BTRFS             |
| 5                   | @/home                       | /home                    | Encrypted BTRFS             |
| 6                   | @/.snapshots                 | /.snapshots              | Encrypted BTRFS             |
| 7                   | @/srv                        | /srv                     | Encrypted BTRFS             |
| 8                   | @/var_log                    | /var/log                 | Encrypted BTRFS             |
| 9                   | @/var_crash                  | /var/crash               | Encrypted BTRFS             |
| 10                  | @/var_cache                  | /var/cache               | Encrypted BTRFS (nodatacow) |
| 11                  | @/var_tmp                    | /var/tmp                 | Encrypted BTRFS (nodatacow) |
| 12                  | @/var_spool                  | /var/spool               | Encrypted BTRFS             |
| 13                  | @/var_lib_libvirt_images     | /var/lib/libvirt/images  | Encrypted BTRFS (nodatacow) |
| 14                  | @/var_lib_docker             | /var/lib/docker          | Encrypted BTRFS             |
| 15                  | @/var_lib_containers         | /var/lib/containers      | Encrypted BTRFS             |

Also, these subfolders in `$HOME` (`~/xxx`) will be subvolumed, to enable `$HOME` snapshoting.

```sh
COW_PATHS=(
    ".var"
    ".local/share/Steam"
    ".local/share/containers"
    # "Downloads"
    # ".local/share/Trash"
)

NOCOW_PATHS=(
    ".cache"
    "VirtualBox VMs"
)
```

## Testing in VM

### virt-manager / qemu

As far as I have tested, UEFI needs to be enabled. Also, installing `spice-vdagent` is helpful, but may not work in some DE's.

### VirtualBox

Of course you can use VirtualBox guest addition ISO, but you will also need to `systemctl enable vboxservice`.
