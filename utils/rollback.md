## For `/` (root) snapshots

```sh
sudo snapper list
sudo snapper rollback $n
sudo reboot
```

If you can't install or update because of lock file, you may need to delete it.

```sh
sudo rm /var/lib/pacman/db.lck
```

## For non-root snapshots, e.g. `/home`

If you plan to use `snapper -c home create-config /home`, consider adding these, but use a full path for $HOME (i.e. home/$USER)
- $HOME/.cache
- $HOME/.var
- $HOME/Downloads
- $HOME/.local/share/Steam
- $HOME/.local/share/containers
- $HOME/.local/share/Trash

As for how to rollback, see https://github.com/openSUSE/snapper/issues/664

You simply edit `/etc/fstab`.

```sh
# UUID=153398e6-a79c-4a4f-9650-bc435b6a4182	/home     	btrfs     	rw,noatime,compress=zstd:15,ssd,space_cache,subvolid=258,subvol=/@/home,discard=async	0 0
UUID=153398e6-a79c-4a4f-9650-bc435b6a4182	/home     	btrfs     	rw,noatime,compress=zstd:15,ssd,space_cache,subvolid=928,subvol=/@/home/.snapshots/1/snapshot,discard=async	0 0
```
