#!/bin/bash
# cubic-wrapper.sh

# Location of server executable
SERVER_EXE="${server_files}/server/CubicOdysseyServer.exe"
wine_pid=""

cleanup() {
    echo "Received shutdown signal, stopping Cubic Odyssey server..."
    # Send SIGTERM to wine process
    if [ -n "$wine_pid" ] && kill -0 "$wine_pid" 2>/dev/null; then
        kill -TERM "$wine_pid" 2>/dev/null
    # Wait for process to exit (with timeout)
        wait_timeout=30
        while kill -0 "$wine_pid" 2>/dev/null && [ "$wait_timeout" -gt 0 ]; do
            sleep 1
            wait_timeout=$((wait_timeout - 1))
        done
    # Force kill if still running
        if kill -0 "$wine_pid" 2>/dev/null; then
            echo "Server did not shutdown gracefully, forcing exit..."
            kill -KILL "$wine_pid" 2>/dev/null
        fi
    fi

    rm -f /tmp/.X*-lock 2>/dev/null
    rm -rf /tmp/.X11-unix 2>/dev/null

    echo "Server shutdown complete"
    exit 0
}

# Trap signals
trap cleanup SIGINT SIGTERM

# Start Xvfb and Wine
rm -f /tmp/.X*-lock 2>/dev/null
rm -rf /tmp/.X11-unix 2>/dev/null

if [ ! -f "$SERVER_EXE" ]; then
    echo "Server executable not found: $SERVER_EXE"
    exit 1
fi

export WINEPREFIX=/home/cubic/.wine
unset WINEARCH
export XDG_RUNTIME_DIR=/tmp/runtime-cubic
mkdir -p "$XDG_RUNTIME_DIR"
chmod 700 "$XDG_RUNTIME_DIR"

echo "Using WINEPREFIX=$WINEPREFIX"
which wine
wine --version

echo "Initializing Wine prefix via Xvfb"
rm -rf "$WINEPREFIX"
xvfb-run -a --server-args="-screen 0 1280x1024x24 -nolisten tcp" wineboot -i
wineserver -w

echo "Starting Cubic Odyssey Dedicated Server via Xvfb and Wine"
xvfb-run -a --server-args="-screen 0 1280x1024x24 -nolisten tcp" \
    wine "$SERVER_EXE" -log 2>&1 &
wine_pid=$!

# Handle unexpected exits
wait "$wine_pid"
exit_code=$?

if [ "$exit_code" -ne 0 ]; then
    echo "Server process exited unexpectedly"
    exit "$exit_code"
fi
