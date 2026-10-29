#!/bin/bash
set -euo pipefail
source /root/.restic-env

# Netzwerkfreigabe \\homeserver\backup, ohne den Paperless Eingang (nur durchgereicht, steckt im Paperless Backup)
restic backup --tag share /srv/share --exclude /srv/share/Paperless --exclude /srv/share/lost+found
restic forget --tag share --keep-daily 14 --keep-weekly 8 --keep-monthly 12 --prune

# Meldet Uptime Kuma, dass das Backup durchgelaufen ist
source /srv/stacks/backup/kuma-push.env
curl -fsS -m 10 --retry 3 "$KUMA_PUSH_URL/$KUMA_PUSH_SHARE?status=up&msg=OK" > /dev/null || true

echo "$(date '+%F %T') Freigabe-Backup ok"
