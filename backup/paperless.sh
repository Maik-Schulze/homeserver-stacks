#!/bin/bash
set -euo pipefail
source /root/.restic-env

# Vollstaendiger Export mit Datenbankinhalt und Dateien, laesst sich mit document_importer wieder einspielen
docker exec paperless document_exporter ../export --delete --no-progress-bar
restic backup --tag paperless /srv/appdata/paperless/export
restic forget --tag paperless --keep-daily 14 --keep-weekly 8 --keep-monthly 12 --prune

# Meldet Uptime Kuma, dass das Backup durchgelaufen ist
source /srv/stacks/backup/kuma-push.env
curl -fsS -m 10 --retry 3 "$KUMA_PUSH_URL/$KUMA_PUSH_PAPERLESS?status=up&msg=OK" > /dev/null || true

echo "$(date '+%F %T') Paperless-Backup ok"
