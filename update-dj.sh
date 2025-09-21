#!/bin/bash

curl -sL "$(cat ~/colab2.txt)" -o dj.txt
DJ_FILE="$HOME/dj.txt"
DJ_DIR="$HOME/Music/webradio/DJ"
LAST_FILE="$HOME/last.txt"
INFO_PATH="/var/www/live-info/dj"
rm -r "$DJ_DIR"
mkdir -p "$DJ_DIR"

if [[ -f "$LAST_FILE" ]]; then
    LAST_DJ=$(cat "$LAST_FILE")
else
    LAST_DJ=0
fi

NEXT_DJ=$(grep -oP '^\[\K[0-9]+(?=\])' "$DJ_FILE" | sort -n | awk -v last="$LAST_DJ" '$1 > last {print $1; exit}')

if [[ -z "$NEXT_DJ" ]]; then
    echo "Pas de nouveau DJ à jouer. Playlist evening normale."
    exit 0
fi

echo "Préparation du DJ [$NEXT_DJ]"

SECTION=$(awk -v n="$NEXT_DJ" '
    $0=="["n"]"{flag=1;next} 
    /^\[/{flag=0} 
    flag && $0 !~ /^#/ && $0 !~ /^;/' "$DJ_FILE")

PSEUDO=$(echo "$SECTION" | grep '^pseudo=' | cut -d'=' -f2-)
RESEAUX=$(echo "$SECTION" | grep '^reseaux=' | cut -d'=' -f2-)
PLAYLIST=$(echo "$SECTION" | grep '^playlist=' | cut -d'=' -f2-)
TEXTE=$(echo "$SECTION" | grep '^texte=' | cut -d'=' -f2-)

if [[ -n "$PLAYLIST" ]]; then
    yt-dlp --force-ipv4 --ignore-errors --format bestaudio --extract-audio --audio-format mp3 --audio-quality 160K --embed-thumbnail --embed-metadata -o "$DJ_DIR/%(autonumber)s-%(title)s.%(ext)s" "$PLAYLIST"
fi

cat > "$INFO_PATH/info.json" <<EOF
{
    "pseudo": "$PSEUDO",
    "reseaux": "$RESEAUX",
    "texte": "$TEXTE",
    "playlist": "$PLAYLIST"
}
EOF

echo "$NEXT_DJ" > "$LAST_FILE"

echo "DJ [$NEXT_DJ] prêt et playlist téléchargée."
