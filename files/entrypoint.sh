#!/bin/bash
# entrypoint.sh
set -euo pipefail

export USER=cubic
export HOME=/home/cubic

mkdir -p /home/cubic/backups
touch /home/cubic/.container_env
chown cubic:cubic /home/cubic/.container_env

cat > /home/cubic/.container_env <<EOF
export HOME=/home/cubic
export USER=cubic
export BACKUP_RETENTION="${BACKUP_RETENTION:-10}"
EOF

cat > /etc/cron.d/cubic-backup <<EOF
SHELL=/bin/bash
BASH_ENV=/home/cubic/.container_env
PATH=/usr/local/sbin:/usr/local/bin:/usr/sbin:/usr/bin:/sbin:/bin
${BACKUP_CRON_SCHEDULE:-0 * * * *} cubic /home/cubic/scripts/backup.sh >> /proc/1/fd/1 2>> /proc/1/fd/2
EOF

chmod 0644 /etc/cron.d/cubic-backup

rm -f /var/run/crond.pid
cron

server_pid=""

shutdown_handler() {
    echo "Received shutdown signal, running final backup..."
    /home/cubic/scripts/backup.sh || true

    if [[ -n "${server_pid}" ]] && kill -0 "${server_pid}" 2>/dev/null; then
        echo "Stopping Cubic Odyssey server..."
        kill -TERM "${server_pid}" 2>/dev/null || true
        wait "${server_pid}" || true
    fi

    exit 0
}

trap shutdown_handler SIGTERM SIGINT

echo "Starting main server process..."
/bin/bash /home/cubic/scripts/start.sh &
server_pid=$!

wait "${server_pid}"