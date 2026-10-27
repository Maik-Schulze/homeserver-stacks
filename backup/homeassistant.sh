#!/bin/bash
set -euo pipefail
source /root/.restic-env

restic backup --tag homeassistant /srv/backups/homeassistant
restic forget --tag homeassistant --keep-daily 7 --keep-weekly 4 --keep-monthly 6 --prune

echo "$(date '+%F %T') Home-Assistant-Backup ok"
