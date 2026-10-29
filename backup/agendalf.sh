#!/bin/bash
set -euo pipefail
source /root/.restic-env

docker exec agendalf python manage.py backup_db
restic backup --tag agendalf /srv/appdata/agendalf
restic forget --tag agendalf --keep-daily 14 --keep-weekly 8 --keep-monthly 12 --prune

# Meldet Uptime Kuma, dass das Backup durchgelaufen ist
source /srv/stacks/backup/kuma-push.env
curl -fsS -m 10 --retry 3 "$KUMA_PUSH_URL/$KUMA_PUSH_AGENDALF?status=up&msg=OK" > /dev/null || true

echo "$(date '+%F %T') Agendalf-Backup ok"
