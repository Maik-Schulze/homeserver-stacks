#!/bin/bash
set -euo pipefail
source /root/.restic-env

# Online Kopie der SQLite Datenbank, die App verweigert das Ueberschreiben einer vorhandenen Datei
rm -f /srv/appdata/tenkant-miss/backups/tenkant-miss.db
docker exec tenkant-miss dotnet TenkantMiss.dll backup /backups/tenkant-miss.db
# Die laufende Datenbank selbst ist als Datei nicht konsistent, gesichert wird die Kopie
restic backup --tag tenkant-miss --exclude '/srv/appdata/tenkant-miss/data/*.db*' /srv/appdata/tenkant-miss
# Nur 30 Tage, damit geloeschte Kinder wie in der README beschrieben auch aus den Backups verschwinden
restic forget --tag tenkant-miss --keep-daily 30 --prune

# Meldet Uptime Kuma, dass das Backup durchgelaufen ist
source /srv/stacks/backup/kuma-push.env
curl -fsS -m 10 --retry 3 "$KUMA_PUSH_URL/$KUMA_PUSH_TENKANT?status=up&msg=OK" > /dev/null || true

echo "$(date '+%F %T') tenkant-miss-Backup ok"
