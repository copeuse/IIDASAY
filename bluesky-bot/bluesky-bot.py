#!/usr/bin/env python3
import os
import json
from atproto import Client
import datetime

# Identifiants du bot

from pathlib import Path

creds_path = Path.home() / "bluesky-bot" / "mdp.json"
with open(creds_path, "r", encoding="utf-8") as f:
    creds = json.load(f)
USERNAME = creds["username"]
PASSWORD = creds["password"]

# Chemin du JSON
JSON_PATH = "/var/www/live-info/dj/info.json"
MAX_LEN = 251
IDASAY_URL = "https://internet-is-dying-and-so-are-you.com"

def get_byte_offsets(text: str, substring: str):
    """
    Retourne (start, end) en byte offsets UTF-8 pour substring dans text.
    """
    char_index = text.find(substring)
    if char_index == -1:
        return None
    before = text[:char_index].encode("utf-8")
    upto = text[:char_index + len(substring)].encode("utf-8")
    return len(before), len(upto)

def main():
    if not os.path.exists(JSON_PATH):
        print("Pas de JSON trouvé, rien à poster.")
        return

    # Charger le fichier JSON
    with open(JSON_PATH, "r", encoding="utf-8") as f:
        data = json.load(f)

    pseudo = data.get("pseudo", "unknown")
    texte = data.get("texte", "")

    if len(texte) + len(pseudo) > MAX_LEN:
        max_texte_len = MAX_LEN - len(pseudo) - 3
        texte = texte[:max_texte_len] + "..."

    # Construire le message
    message = f"tonight at 11pm on IDASAY, {pseudo} chooses the music! : {texte}"

    # Facets pour rendre "IDASAY" cliquable
    facets = []
    offsets = get_byte_offsets(message, "IDASAY")
    if offsets:
        facets.append({
            "index": {"byteStart": offsets[0], "byteEnd": offsets[1]},
            "features": [{
                "$type": "app.bsky.richtext.facet#link",
                "uri": IDASAY_URL
            }]
        })

    # Connexion à Bluesky
    client = Client()
    client.login(USERNAME, PASSWORD)

    # Poster
    record = {
        "text": message,
        "facets": facets,
        "createdAt": datetime.datetime.now(datetime.timezone.utc).isoformat()
    }

    client.app.bsky.feed.post.create(
        repo=client.me.did,
        record=record
    )

    print("Post envoyé:\n", message)

if __name__ == "__main__":
    main()
