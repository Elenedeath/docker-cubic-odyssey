#!/usr/bin/env bash
set -euo pipefail

server_pid=""

cleanup() {
  echo "Shutdown signal received, stopping server..."

  if [[ -n "${server_pid}" ]] && kill -0 "${server_pid}" 2>/dev/null; then
    kill -TERM "${server_pid}" 2>/dev/null || true
    wait "${server_pid}" || true
  fi

  echo "Running final backup..."
  /home/cubic/scripts/backup.sh || true

  exit 0
}

trap cleanup SIGTERM SIGINT

/bin/bash /home/cubic/scripts/start.sh &
server_pid=$!

wait "${server_pid}"