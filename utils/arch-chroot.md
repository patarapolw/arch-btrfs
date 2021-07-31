If you can't boot for any reasons, and need `Arch Linux live USB`, you can properly mount with

```sh
mount $BTRFS /mnt
# mount $BTRFS -o subvol=@/etc /mnt/etc  # if you have a subvol for etc
arch-chroot /mnt
mount -a
```
