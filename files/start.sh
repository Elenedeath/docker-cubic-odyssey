#!/bin/bash
set -euo pipefail

# Location of server data and save data for docker
server_files="/home/cubic/server_files"

echo " "
echo "Server files location is set to : $server_files"
echo " "

mkdir -p /home/cubic/.steam
chmod -R 777 /home/cubic/.steam 2>/dev/null || true

echo " "
echo "Updating Cubic Odyssey Dedicated Server files..."
echo " "

if [ -n "${STEAM_USER:-}" ] && [ -n "${STEAM_PASS:-}" ]; then
    LOGIN_ARGS="+login ${STEAM_USER} ${STEAM_PASS}"
else
    LOGIN_ARGS="+login anonymous"
fi

steamcmd +login anonymous +quit || true

run_update() {
    steamcmd \
        +@ShutdownOnFailedCommand 1 \
        +@sSteamCmdForcePlatformType windows \
        +force_install_dir "$server_files" \
        $LOGIN_ARGS \
        "$@" \
        +quit
}

if [ -n "${BETANAME:-}" ]; then
    if [ -n "${BETAPASSWORD:-}" ]; then
        echo "Using beta $BETANAME with a password"
        update_cmd="+app_update 3858450 -beta $BETANAME -betapassword $BETAPASSWORD validate"
    else
        echo "Using beta $BETANAME without a password"
        update_cmd="+app_update 3858450 -beta $BETANAME validate"
    fi
else
    echo "No beta branch used."
    update_cmd="+app_update 3858450 validate"
fi

for i in 1 2 3; do
    if run_update "$update_cmd"; then
        break
    fi
    echo "SteamCMD failed on attempt $i, retrying in 5s..."
    sleep 5
done

if [ -f "$server_files/steam_appid.txt" ]; then
    echo "steam_appid: $(cat "$server_files/steam_appid.txt")"
else
    echo "steam_appid.txt not found yet"
fi

echo "Running setup script for the app.cfg file"
source /home/cubic/scripts/env2cfg.sh

echo
if [ -n "${NO_CRON:-}" ]; then
    echo "No Cron image used!"
fi

cd "$server_files" || exit 1
echo "Starting Cubic Odyssey Dedicated Server"
echo " "
echo "Launching wine Cubic Odyssey"
echo " "

exec /home/cubic/scripts/wrapper.sh