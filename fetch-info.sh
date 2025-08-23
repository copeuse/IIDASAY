#!/bin/bash

set -euo pipefail

DOMAIN="radio.spaceghost.pink"  # ← REPLACE BY YOUR PUBLIC DOMAIN
MUSIC_DIR="$HOME/Music"
WEB_ROOT="/var/www/live-info"

mkdir -p "$WEB_ROOT/covers"
mkdir -p "$WEB_ROOT/np"

while true; do

  FILE=$(mpc --format "%file%" current || true)

  if [[ -z "${FILE}" ]]; then
    echo "[INFO] Nothing is playing rn"
    jq -n --arg t "—" --arg u "" --arg c "" \
      '{title:$t, url:$u, cover:$c}' > "$WEB_ROOT/np/nowplaying.json"
    sleep 10
    continue
  fi

  BASENAME="${FILE%.*}"

  INFOFILE="$MUSIC_DIR/$BASENAME.info.json"
  COVERFILE_JPG="$MUSIC_DIR/$BASENAME.jpg"
  JSONOUT="$WEB_ROOT/np/nowplaying.json"

  echo "[DEBUG] FILE=$FILE"
  echo "[DEBUG] BASENAME=$BASENAME"
  echo "[DEBUG] INFOFILE=$INFOFILE"
  echo "[DEBUG] COVERFILE_JPG=$COVERFILE_JPG"

  if [[ ! -f "$INFOFILE" ]]; then
    echo "[WARN] Pas trouvé : $INFOFILE"
    jq -n --arg t "$(basename "$BASENAME")" --arg u "" --arg c "" \
      '{title:$t, url:$u, cover:$c}' > "$JSONOUT"
    sleep 10
    continue
  fi

  TITLE=$(jq -r '.title // ""' "$INFOFILE")
  URL=$(jq -r '.webpage_url // ""' "$INFOFILE")

  COVER_URL=""
    for ext in jpg jpeg png webp; do
      COVERFILE="$MUSIC_DIR/$BASENAME.$ext"
    if [[ -f "$COVERFILE" ]]; then
      WEB_COVER="$WEB_ROOT/covers/cover.$ext"
      cp -f "$COVERFILE" "$WEB_COVER"
      COVER_URL="https://$DOMAIN/covers/cover.$ext"
      break
    fi
  done

  jq -n --arg t "$TITLE" --arg u "$URL" --arg c "$COVER_URL" \
    '{title:$t, url:$u, cover:$c}' > "$JSONOUT"

  echo "[INFO] JSON mis à jour : $TITLE"
  sleep 10
done
