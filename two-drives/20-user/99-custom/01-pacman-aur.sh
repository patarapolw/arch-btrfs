#!/bin/bash -e

# sudo printf '[multilib]\nInclude = /etc/pacman.d/mirrorlist\n' >> /etc/pacman.conf

APPS=(
    # copyq
    conky

    # https://wiki.archlinux.org/title/Fcitx#Desktop_Environment_Autostart
    fcitx fcitx-configtool fcitx-anthy fcitx-cloudpinyin fcitx-table-other
    fonts-tlwg ttf-sipa-dip ttf-th-sarabun-new

    # https://wiki.archlinux.org/title/Podman#Rootless_Podman
    docker

    virt-manager qemu iptables-nft dnsmasq

    linux-headers

    virtualbox
    # virtualbox-host-modules-arch
    virtualbox-host-dkms

    pipewire-jack-dropin pipewire-alsa pavucontrol

    # https://github.com/bulletmark/libinput-gestures
    libinput-gestures wmctrl xdotool
    libwnck

    # https://wiki.archlinux.org/title/Timidity%2B%2B#SoundFonts
    # timidity++ freepats-general-midi soundfont-fluid qsynth rosegarden frescobaldi lilypond

    visual-studio-code-bin
    bitwarden
    chromium
    gnome-disk-utility gnome-keyring
    discord

    python-pip
    go

    deno ttf-droid

    openssh

    nextcloud-client
    archlinux-artwork

    rustup
    tree

    python-poetry
    python-pipenv

    gparted
)

paru -Syu --needed "${APPS[@]}"

sudo usermod -aG libvirt,kvm,audio,input,docker $USER
