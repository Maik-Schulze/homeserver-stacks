#!/bin/bash
set -euo pipefail
source /root/.restic-env

restic backup --tag homeassistant /srv/backups/homeassistant
restic forget --tag homeassistant --keep-daily 7 --keep-weekly 4 --keep-monthly 6 --prune

# Meldet Uptime Kuma, dass das Backup durchgelaufen ist
source /srv/stacks/backup/kuma-push.env
curl -fsS -m 10 --retry 3 "$KUMA_PUSH_URL/$KUMA_PUSH_HOMEASSISTANT?status=up&msg=OK" > /dev/null || true

echo "$(date '+%F %T') Home-Assistant-Backup ok"
