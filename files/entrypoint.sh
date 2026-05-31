#!/bin/bash
# entrypoint.sh
set -euo pipefail

mkdir -p /home/cubic/server_files/config /home/cubic/server_files/server /home/cubic/backups /home/cubic/.steam
chown -R cubic:cubic /home/cubic
chmod -R u+rwX /home/cubic

# start cron as root if needed here

exec su -s /bin/bash cubic -c '/home/cubic/scripts/start.sh'