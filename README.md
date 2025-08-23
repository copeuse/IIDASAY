INTERNET IS DYING AND SO ARE YOU

dependence : icecast mpd mpc yt-dlp caddy

add basic info in icecast during install, hostname = your local IP

add this mountpoint in /etc/mpd.conf:

	audio_output {
	    type        "shout"
	    name        "whatever"
	    host        "yourLocalIP"
	    port        "8000"		      
	    mount       "/mystream.mp3"     
	    password    "hackme"             
	    encoder     "lame"                
	    bitrate     "128"                 
	    format      "44100:16:2"
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
		 reverse_proxy yourLocalIP:8000
		}
	}

in fetch-info.sh replace my domain with your domain, the same you put in caddy

	DOMAIN="radio.spaceghost.pink"  # ← REPLACE BY YOUR PUBLIC DOMAIN

enable systemd for icecast, mpd, caddy then create and enable a service for radio-start.sh and fetch-info.sh

your stream should be available at https://radio.domain.public/mystream.mp3
you should find URL and cover of the current track at https://radio.domain.public/nowplaying.json

my index.html works for https://radio.spaceghost.pink but i guess u can just copy my js and change URL, just know that, the whole js is mostly vibe coded as i rly didnt wanted to learn javascript 

force refresh : nohup ~/refresh.sh > ~/refresh.log 2>&1 & disown

