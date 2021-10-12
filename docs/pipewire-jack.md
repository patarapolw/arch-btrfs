Apparently, pipewire works very well with JACK, with little setup. Some packages to install includes

```sh
sudo pacman -S pipewire pipewire-alsa pipewire-jack pipewire-pulse qsynth freepats-general-midi soundfont-fluid
yay -S pipewire-jack-dropin
```

And some of the soundfonts setup in qsynth, to point to `/usr/share/soundfonts`.

This is tested on real hardware, in KDE.
