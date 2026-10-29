#!/bin/bash
set -euo pipefail
source /root/.restic-env

# Vollstaendiger Export mit Datenbankinhalt und Dateien, laesst sich mit document_importer wieder einspielen
docker exec paperless document_exporter ../export --delete --no-progress-bar
restic backup --tag paperless /srv/appdata/paperless/export
restic forget --tag paperless --keep-daily 14 --keep-weekly 8 --keep-monthly 12 --prune

echo "$(date '+%F %T') Paperless-Backup ok"
