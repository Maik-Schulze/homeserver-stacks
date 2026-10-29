#!/bin/bash
set -euo pipefail
source /root/.restic-env

# Netzwerkfreigabe \\homeserver\backup, ohne den Paperless Eingang (nur durchgereicht, steckt im Paperless Backup)
restic backup --tag share /srv/share --exclude /srv/share/Paperless --exclude /srv/share/lost+found
restic forget --tag share --keep-daily 14 --keep-weekly 8 --keep-monthly 12 --prune

echo "$(date '+%F %T') Freigabe-Backup ok"
