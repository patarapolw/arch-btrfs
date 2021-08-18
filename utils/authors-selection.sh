#!/bin/bash

sudo printf '[multilib]\nInclude = /etc/pacman.d/mirrorlist\n' >> /etc/pacman.conf

paru -Syu \
    copyq conky \
    # https://wiki.archlinux.org/title/Fcitx#Desktop_Environment_Autostart
    fcitx fcitx-configtool fcitx-anthy fcitx-cloudpinyin fcitx-table-others \
    font-tlwg ttf-sipa-dip tth-th-sarabun-new \
    # https://wiki.archlinux.org/title/Podman#Rootless_Podman
    podman podman-compose \
    virt-manager qemu iptables-nft dns-masq \
    linux-headers \
    virtualbox virtualbox-host-modules-arch \
    pipewire-jack-dropin pipewire-alsa pavucontrol \
    # https://github.com/bulletmark/libinput-gestures
    libinput-gestures \
    # https://wiki.archlinux.org/title/Timidity%2B%2B#SoundFonts
    timidity++ freepats-general-midi soundfont-fluid qsynth rosegarden frescobaldi lilypond \
    rstudio-bin r gcc-fortran qgis \
    visual-studio-code-bin \
    bitwarden-bin \
    chromium \
    gnome-disk-utility \
    discord steam playonlinux \
    onlyoffice-bin \
    python-pip \
    bpytop \
    go

sudo usermod -aG libvirt,audio,input $USER

curl -o- https://raw.githubusercontent.com/nvm-sh/nvm/v0.38.0/install.sh | bash
# source
nvm install 14

curl -sSL https://raw.githubusercontent.com/python-poetry/poetry/master/get-poetry.py | python -
# source
poetry config virtualenvs.in-project true
