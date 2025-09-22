#!/bin/bash

LAST_PLAYLIST=""
LAST_UPDATE_DATE=""
LAST_REFRESH_WEEK=""

while true; do
    HOUR=$(date +%H)
    WEEK=$(date +%V)
    TODAY=$(date +%Y-%m-%d)

    DJ_JSON="/var/www/live-info/dj/info.json"

    if [ "$HOUR" -ge 8 ] && [ "$HOUR" -lt 12 ]; then
        PLAYLIST="webradio/morning"
    elif [ "$HOUR" -ge 12 ] && [ "$HOUR" -lt 17 ]; then
        PLAYLIST="webradio/afternoon"
    elif [ "$HOUR" -ge 17 ] && [ "$HOUR" -lt 21 ]; then
        PLAYLIST="webradio/evening"
    elif [ "$HOUR" -ge 21 ] && [ "$HOUR" -lt 23 ]; then
        PLAYLIST="webradio/night"
    elif [ "$HOUR" -ge 23 ] || [ "$HOUR" -lt 1 ]; then
        if [ -s "$DJ_JSON" ]; then
            PLAYLIST="webradio/DJ"
        else
            PLAYLIST="webradio/after"
        fi
    elif [ "$HOUR" -ge 1 ] && [ "$HOUR" -lt 4 ]; then
	rm -f /var/www/live-info/dj/info.json
	PLAYLIST="webradio/after"
    else
        PLAYLIST="webradio/sleep"
    fi

    if [ "$PLAYLIST" != "$LAST_PLAYLIST" ]; then
        mpc update --wait
        if mpc status | grep -q "\[playing\]"; then
            mpc crop
        else
            mpc clear
        fi

        mpc add "$PLAYLIST"

        if [[ "$PLAYLIST" == "webradio/sleep" ]]; then
	    if [ "$LAST_UPDATE_DATE" != "$TODAY" ]; then
                if [ "$LAST_REFRESH_WEEK" != "$WEEK" ]; then
                    LAST_REFRESH_WEEK="$WEEK"
                    bash ~/refresh.sh &
                else
                    bash ~/update-playlist.sh &
                fi
               LAST_UPDATE_DATE="$TODAY"
            fi
       fi

	if [[ "$PLAYLIST" == "webradio/evening" ]]; then
	       bash ~/update-dj.sh &
	fi
        if [[ "$PLAYLIST" == "webradio/DJ" ]]; then
            mpc random off
	    find /home/alice/Music/webradio/after -type f -name '*.mp3' -print0 | shuf -z | xargs -0 mpc add
        else
            mpc random on
        fi

        mpc play
        LAST_PLAYLIST="$PLAYLIST"
    fi

    if [[ "$PLAYLIST" == "webradio/DJ" ]]; then
        if mpc current -f %file% | grep -q "/after/"; then
                rm -f /var/www/live-info/dj/info.json
        fi
    fi

    sleep 10
done

