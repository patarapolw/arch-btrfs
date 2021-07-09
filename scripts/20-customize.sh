#!/bin/bash

read -r -p "Please choose a user: " USER

echo 'include /usr/share/nano/default.nanorc
include /usr/share/nano/sh.nanorc' >> /home/$USER/.nanorc

sed -i 's/#Color/Color/g' /etc/pacman.conf
