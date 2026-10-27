#!/bin/bash
set -euo pipefail
source /root/.restic-env

docker exec agendalf python manage.py backup_db
restic backup --tag agendalf /srv/appdata/agendalf
restic forget --tag agendalf --keep-daily 14 --keep-weekly 8 --keep-monthly 12 --prune

echo "$(date '+%F %T') Agendalf-Backup ok"
