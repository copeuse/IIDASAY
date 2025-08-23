#!/bin/bash

LAST_PLAYLIST=""
LAST_UPDATE_DATE=""
LAST_REFRESH_MONTH=""

while true; do
    HOUR=$(date +%H)
    MONTH=$(date +%m)
    TODAY=$(date +%Y-%m-%d)   # date du jour
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

        # exécuter la mise à jour une seule fois par jour
        if [ "$LAST_UPDATE_DATE" != "$TODAY" ]; then
            curl -sL "$(cat ~/colab.txt)" -o playlist.txt
            bash ~/update-playlist.sh &
            LAST_UPDATE_DATE="$TODAY"
        fi

	if [ "$LAST_REFRESH_MONTH" != "$MONTH" ]; then 
	    LAST_REFRESH_MONTH="$MONTH" 
            bash ~/refresh.sh & 
	fi

    fi

    # recharge la playlist seulement si elle a changé
    if [ "$PLAYLIST" != "$LAST_PLAYLIST" ]; then
	mpc update --wait
	if mpc status | grep -q "\[playing\]"; then
            mpc crop
        else
            mpc clear
        fi
        mpc add "$PLAYLIST"
        mpc random on
        mpc play
        LAST_PLAYLIST="$PLAYLIST"
    fi

    sleep 300   # vérifie toutes les 5 minutes
done
