
from atproto import Client
import time
import datetime
import json
import os

# --- CONFIG ---
from pathlib import Path

creds_path = Path.home() / "bluesky-bot" / "mdp.json"
with open(creds_path, "r", encoding="utf-8") as f:
    creds = json.load(f)
HANDLE = creds["username"]
APP_PASSWORD = creds["password"]

POLL_INTERVAL = 10  # secondes

# --- INIT ---
client = Client()
client.login(HANDLE, APP_PASSWORD)
print(f"Bot connecté en tant que {client.me.handle}")


def get_byte_offsets(text: str, substring: str):
    """
    Retourne (start, end) en byte offsets UTF-8 pour substring dans text.
    """
    char_index = text.find(substring)
    if char_index == -1:
        return None

    before = text[:char_index].encode("utf-8")
    upto = text[:char_index + len(substring)].encode("utf-8")

    return (len(before), len(upto))


def build_reply_post(notif):
    """
    Construit le post à envoyer en réponse à la notification.
    - DJ info.json (23h-1h) : texte seul, pas de lien
    - Now Playing : texte + lien cliquable via facets
    """
    dj_file = "/var/www/live-info/dj/info.json"
    np_file = "/var/www/live-info/np/nowplaying.json"
    now = datetime.datetime.now().hour

    text = ""
    facets = []

    # --- DJ condition ---
    if os.path.exists(dj_file) and (now >= 23 or now < 1):
        try:
            with open(dj_file, "r", encoding="utf-8") as f:
                data = json.load(f)
            pseudo = data.get("pseudo", "DJ inconnu")
            texte = data.get("texte", "")
            text = f"np : {pseudo} is currently choosing the music : {texte}"
            # Pas de lien pour DJ
        except Exception as e:
            print("Erreur lecture DJ info:", e)
            text = "np : DJ info unavailable"

    # --- Now Playing condition ---
    elif os.path.exists(np_file):
        try:
            with open(np_file, "r", encoding="utf-8") as f:
                data = json.load(f)
            title = data.get("title", "Titre inconnu")
            url = data.get("url", "")
            text = f"now playing on IDASAY: {title} ({url})"

            # Facet pour IDASAY
            idasay_offsets = get_byte_offsets(text, "IDASAY")
            if idasay_offsets:
                facets.append({
                    "index": {"byteStart": idasay_offsets[0], "byteEnd": idasay_offsets[1]},
                    "features": [{
                        "$type": "app.bsky.richtext.facet#link",
                        "uri": "https://internet-is-dying-and-so-are-you.com"
                    }]
                })

            # Facet pour URL
            if url:
                url_offsets = get_byte_offsets(text, url)
                if url_offsets:
                    facets.append({
                        "index": {"byteStart": url_offsets[0], "byteEnd": url_offsets[1]},
                        "features": [{
                            "$type": "app.bsky.richtext.facet#link",
                            "uri": url
                        }]
                    })

        except Exception as e:
            print("Erreur lecture Now Playing:", e)
            text = "now playing info unavailable"

    else:
        text = "Aucune info de lecture disponible"

    # --- Retourner le record prêt à poster ---
    record = {
        "text": text,
        "facets": facets,
        "reply": {
            "parent": {"uri": notif.uri, "cid": notif.cid},
            "root": {"uri": notif.uri, "cid": notif.cid}
        },
        "createdAt": datetime.datetime.now(datetime.timezone.utc).isoformat()
    }
    return record


while True:
    try:
        result = client.app.bsky.notification.list_notifications()
        notifications = result.notifications

        for notif in notifications:
            if notif.is_read:
                continue

            if notif.reason == "mention":
                print(f"Nouvelle mention de {notif.author.handle}: {notif.record.text}")

                try:
                    reply_post = build_reply_post(notif)

                    client.app.bsky.feed.post.create(
                        repo=client.me.did,
                        record=reply_post
                    )
                    print("→ Réponse envoyée ✅")

                    client.app.bsky.notification.update_seen(
                        {"seenAt": datetime.datetime.now(datetime.timezone.utc).isoformat()}
                    )

                except Exception as e:
                    print("Erreur en postant la réponse :", e)

        time.sleep(POLL_INTERVAL)

    except Exception as e:
        print("Erreur générale :", e)
        time.sleep(30)
