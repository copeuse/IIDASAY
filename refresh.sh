#!/bin/bash

PLAYLIST_FILE="playlist.txt"

BASE_DIR="$HOME/Music/refresh"

YTDLP="yt-dlp --force-ipv4 --ignore-errors --format bestaudio \
--extract-audio --audio-format mp3 --audio-quality 160K \
--embed-thumbnail --embed-metadata \
--write-info-json --write-thumbnail \
--download-archive $HOME/Archive-refresh"

curl -sL "$(cat ~/colab.txt)" -o playlist.txt
rm -r ~/Music/refresh
rm ~/Archive-refresh
mkdir ~/Music/refresh

current_section=""
while IFS= read -r line; do
    
    [[ -z "$line" || "$line" =~ ^# ]] && continue

    if [[ "$line" =~ ^\[(.*)\]$ ]]; then
        current_section="${BASH_REMATCH[1]}"
        continue
    fi

    if [[ -n "$current_section" ]]; then
        folder="$BASE_DIR/$current_section"
        mkdir -p "$folder"

        echo ">>> Download in $folder : $line"
        $YTDLP --paths "$folder" --output "%(title)s -- %(uploader)s.%(ext)s" "$line"
    fi
done < "$PLAYLIST_FILE"

mpc clear
rm -r ~/Music/archive
rm -r ~/Archive
mv ~/Music/webradio ~/Music/archive
mv ~/Music/refresh ~/Music/webradio
mv ~/Archive-refresh ~/Archive
mpc update --wait

    HOUR=$(date +%H)
    TODAY=$(date +%Y-%m-%d)
    if [ "$HOUR" -ge 8 ] && [ "$HOUR" -lt 12 ]; then
        PLAYLIST="webradio/morning"
    elif [ "$HOUR" -ge 12 ] && [ "$HOUR" -lt 17 ]; then
        PLAYLIST="webradio/afternoon"
    elif [ "$HOUR" -ge 17 ] && [ "$HOUR" -lt 21 ]; then
        PLAYLIST="webradio/evening"
    elif [ "$HOUR" -ge 21 ] && [ "$HOUR" -lt 24 ]; then
        PLAYLIST="webradio/night"
    elif [ "$HOUR" -ge 0 ] && [ "$HOUR" -lt 4 ]; then
        PLAYLIST="webradio/after"
    else
        PLAYLIST="webradio/sleep"
    fi

mpc add "$PLAYLIST"
mpc random on
mpc play
