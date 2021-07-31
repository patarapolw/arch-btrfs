For browsing snapshots, and probably copying from the old snapshot to the new snapshot; the instructions are

```sh
# snapper list
# btrfs sub list /

# Please confirm that @/ subvolid is 5.

mount $BTRFS -o subvolid=5 /mnt

# You can also use `rsync -axXv` for `cp -r`, but you probably shouldn't just `mv` or `rm`.
cp /mnt/@/.snapshots/$n1/snapshot/$PATH_TO_FILE /mnt/@/.snapshots/$n2/snapshot/$PATH_TO_FILE
```

For non-root snapshots, like `@/home`, the process is similar, but you will need a different subvolid, add probably different paths.

There is also a GUI for this -- `snapper-gui`.
