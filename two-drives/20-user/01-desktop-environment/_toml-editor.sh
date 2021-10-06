#!/bin/bash

# Usage
# # export FILE=/etc/sddm.conf.d/default.conf
# # HEADER='[Theme]' SET='Current=elarun' ./10-toml-editor.sh > $FILE.new
# # mv $FILE.new $FILE

if [ -z "$FILE" ]; then
    >&2 echo 'FILE= is required'
    exit 1
fi

if [ -z "$HEADER" ]; then
    >&2 echo 'HEADER= is required'
    exit 1
fi

if [ -z "$SET" ]; then
    >&2 echo 'SET= is required'
    exit 1
fi

getkey() {
    echo "$1" | sed -e 's/^# *//' | cut -d'=' -f1
}

while IFS= read -r line; do
    if [ "${line:0:1}" = '[' ]; then
        is_header="$([ "$line" = "$HEADER" ] && echo 1)"
    fi

    if [ ! -z "$is_header" ] && [ "$(getkey $line)" = "$(getkey $SET)" ]; then
        echo "$SET"
    else
        echo "$line"
    fi
done < "$FILE"
