#!/bin/bash
set -euo pipefail
source /root/.restic-env

SRC=/srv/appdata/vaultwarden/data
STAGE=/srv/backups/vaultwarden

# Lokaler Zwischenstand, wird bei jedem Lauf neu erstellt
rm -rf "$STAGE"
mkdir -p "$STAGE"
chmod 700 "$STAGE"

# Konsistenter Snapshot der Datenbank, auch während Vaultwarden läuft
sqlite3 "$SRC/db.sqlite3" ".backup '$STAGE/db.sqlite3'"

cp -a "$SRC/rsa_key.pem" "$STAGE/"
for d in attachments sends; do
    if [ -d "$SRC/$d" ]; then cp -a "$SRC/$d" "$STAGE/"; fi
done
if [ -f "$SRC/config.json" ]; then cp -a "$SRC/config.json" "$STAGE/"; fi

# Verschlüsselt auf die Storage Box
restic backup --tag vaultwarden "$STAGE"

# Aufbewahrung: 14 Tage, 8 Wochen, 12 Monate
restic forget --tag vaultwarden --keep-daily 14 --keep-weekly 8 --keep-monthly 12 --prune

# Meldet Uptime Kuma, dass das Backup durchgelaufen ist
source /srv/stacks/backup/kuma-push.env
curl -fsS -m 10 --retry 3 "$KUMA_PUSH_URL/$KUMA_PUSH_VAULTWARDEN?status=up&msg=OK" > /dev/null || true

echo "$(date '+%F %T') Vaultwarden-Backup ok"
