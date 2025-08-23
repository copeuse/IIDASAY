

dependence : icecast mpd mpc ytdlp caddy

just add basic info in icecast and add this mountpoint in /etc/mpd.conf:

	audio_output {
	    type        "shout"
	    name        "whatever"
	    host        "same as icecast, local IP"
	    port        "8000"		      # port par défaut
	    mount       "/mon-stream.mp3"     # mets l’extension .mp3
	    password    "hackme"              # meme mdp que icecast
	    encoder     "lame"                # ou "shine" si LAME n’est pas dispo
	    bitrate     "128"                 # ou, alternativement: quality "2" (VBR)
	    format      "44100:16:2"          # échantillonnage fixe requis
	}

set this as your music directiory in /etc/mpd.conf 

	music_directory         "~/Music"


create dir ~/Music/webradio

create dir /var/www/live-info give permission to your current user and caddy

config caddy /etc/caddy/Caddyfile :

	radio.domain.public {
		handle_path /covers/* {
		 root * /var/www/live-info/covers
		 file_server
	          header {
	             Access-Control-Allow-Origin *
	             Access-Control-Allow-Methods "GET, OPTIONS"
	             Access-Control-Allow-Headers "Content-Type"
	             Cache-Control: no-cache, no-store, must-revalidate
	          }
		}
		handle_path /np/* {
		 root * /var/www/live-info/np
		 file_server
	          header {
	             Access-Control-Allow-Origin *
	             Access-Control-Allow-Methods "GET, OPTIONS"
	             Access-Control-Allow-Headers "Content-Type"
	             Cache-Control: no-cache, no-store, must-revalidate
	          }
		}
		handle {
		 reverse_proxy IPLOCAL:8000
		}
	}

enable systemd for icecast, mpd, caddy, and create and enable a service for radio-start.sh and fetch-info.sh

force refresh : nohup ~/refresh.sh > ~/refresh.log 2>&1 & disown

