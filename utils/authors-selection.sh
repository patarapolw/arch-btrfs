#!/bin/bash

APPS=(
    # copyq
    conky
    # https://wiki.archlinux.org/title/Fcitx#Desktop_Environment_Autostart
    fcitx fcitx-configtool fcitx-anthy fcitx-cloudpinyin fcitx-table-other
    fonts-tlwg ttf-sipa-dip ttf-th-sarabun-new ttf-droid
    # https://wiki.archlinux.org/title/Podman#Rootless_Podman
    podman podman-compose
    virt-manager qemu iptables-nft dnsmasq edk2-ovmf
    linux-headers
    virtualbox virtualbox-host-modules-arch
    pipewire-jack-dropin pipewire-alsa pavucontrol
    # https://github.com/bulletmark/libinput-gestures
    libinput-gestures wmctrl
    # https://wiki.archlinux.org/title/Timidity%2B%2B#SoundFonts
    timidity++ freepats-general-midi soundfont-fluid qsynth rosegarden frescobaldi lilypond
    visual-studio-code-bin
    bitwarden-bin
    chromium
    gnome-disk-utility gnome-keyring transmission-gtk baobab
    discord steam playonlinux
    libreoffice-fresh
    python-pip
    bpytop
    go deno
)

paru -Syu --needed "${APPS[@]}"

sudo usermod -aG libvirt,kvm,audio,input $USER

curl -o- https://raw.githubusercontent.com/nvm-sh/nvm/v0.38.0/install.sh | bash
# source
# nvm install 14

curl -sSL https://raw.githubusercontent.com/python-poetry/poetry/master/get-poetry.py | python -
# source
# poetry config virtualenvs.in-project true
