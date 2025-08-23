#!/bin/bash

curl -sL "$(cat ~/colab.txt)" -o playlist.txt
PLAYLIST_FILE="playlist.txt"

BASE_DIR="$HOME/Music/webradio"

YTDLP="yt-dlp --force-ipv4 --ignore-errors --format bestaudio \
--extract-audio --audio-format mp3 --audio-quality 160K \
--embed-thumbnail --embed-metadata \
--write-info-json --write-thumbnail \
--download-archive $HOME/Archive"

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

        echo ">>> Téléchargement dans $folder : $line"
        $YTDLP --paths "$folder" --output "%(title)s -- %(uploader)s.%(ext)s" "$line"
    fi
done < "$PLAYLIST_FILE"
