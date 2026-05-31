#!/bin/bash
# wrapper.sh
set -euo pipefail

echo "Starting Cubic Odyssey Dedicated Server via Xvfb and Wine"
cd /home/cubic/server_files/server
exec xvfb-run -a --server-args="-screen 0 1280x1024x24 -nolisten tcp" \
  wine CubicOdysseyServer.exe -log