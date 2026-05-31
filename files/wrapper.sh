#!/bin/bash
# wrapper.sh
set -euo pipefail

echo "Starting Cubic Odyssey Dedicated Server via Xvfb and Wine"
cd /home/cubic/server_files/server

xvfb-run -a --server-args="-screen 0 1280x1024x24 -nolisten tcp" \
  wine CubicOdysseyServer.exe -log 2>&1 \
  | stdbuf -oL sed '/^[[:space:]]*#[[:space:]]*$/d'