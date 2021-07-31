The tool used for backing up from BTRFS to another BTRFS is `snap-sync`. It is as simple as running

```sh
sudo snap-sync
```

And it is interactive.

However, this command fails for me after some repeated runs, so I have to use the good old rsync.

```sh
rsync -axXv --exclude-from=$HOME/.rsync/excluded.txt ~/ $EXT_HD_PATH/ (--dry-run)
```
