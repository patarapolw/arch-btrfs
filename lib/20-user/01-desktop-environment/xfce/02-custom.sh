#!/bin/bash -e

export FILE=/etc/lightdm/lightdm.conf
TMP=lightdm.conf
HEADER='[Seat:*]' SET='greeter-session=lightdm-slick-greeter' ../_toml-editor.sh > /tmp/$TMP
sudo mv /tmp/$TMP $FILE

sudo cat <<EOF > /usr/share/thumbnailers/folder.thumbnailer
[Thumbnailer Entry]
Version=1.0
Encoding=UTF-8
Type=X-Thumbnailer
Name=Folder Thumbnailer
MimeType=inode/directory;
Exec=/usr/local/bin/folder-thumbnailer %s %i %o %u
EOF

sudo cat <<EOF > /usr/local/bin/folder-thumbnailer
#!/bin/bash

convert -thumbnail "$1" "$2/.thumbnail" "$3" 1>/dev/null 2>&1 ||\
convert -thumbnail "$1" "$2/folder.jpg" "$3" 1>/dev/null 2>&1 ||\
convert -thumbnail "$1" "$2/.folder.jpg" "$3" 1>/dev/null 2>&1 ||\
convert -thumbnail "$1" "$2/folder.png" "$3" 1>/dev/null 2>&1 ||\
convert -thumbnail "$1" "$2/cover.jpg" "$3" 1>/dev/null 2>&1 ||\
rm -f "$HOME/.cache/thumbnails/normal/$(echo -n "$4" | md5sum | cut -d " " -f1).png" ||\
rm -f "$HOME/.thumbnails/normal/$(echo -n "$4" | md5sum | cut -d " " -f1).png" ||\
rm -f "$HOME/.cache/thumbnails/large/$(echo -n "$4" | md5sum | cut -d " " -f1).png" ||\
rm -f "$HOME/.thumbnails/large/$(echo -n "$4" | md5sum | cut -d " " -f1).png" ||\
exit 1
EOF

sudo chmod a+x /usr/local/bin/folder-thumbnailer
