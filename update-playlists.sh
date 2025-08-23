#!/bin/bash

# Fichier contenant les playlists
PLAYLIST_FILE="playlist.txt"

# Répertoire de base pour la musique
BASE_DIR="$HOME/Music/webradio"

# Commande yt-dlp de base
YTDLP="yt-dlp --force-ipv4 --ignore-errors --format bestaudio \
--extract-audio --audio-format mp3 --audio-quality 160K \
--embed-thumbnail --embed-metadata \
--write-info-json --write-thumbnail \
--download-archive $HOME/Archive"

# Parsing du fichier playlists.txt
current_section=""
while IFS= read -r line; do
    # Ignorer les lignes vides ou commentaires
    [[ -z "$line" || "$line" =~ ^# ]] && continue

    # Détection des sections
    if [[ "$line" =~ ^\[(.*)\]$ ]]; then
        current_section="${BASH_REMATCH[1]}"
        continue
    fi

    # Si on est dans une section, télécharger le lien
    if [[ -n "$current_section" ]]; then
        folder="$BASE_DIR/$current_section"
        mkdir -p "$folder"

        echo ">>> Téléchargement dans $folder : $line"
        $YTDLP --paths "$folder" --output "%(title)s -- %(uploader)s.%(ext)s" "$line"
    fi
done < "$PLAYLIST_FILE"
